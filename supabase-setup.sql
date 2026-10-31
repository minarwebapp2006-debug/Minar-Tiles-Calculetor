-- ============================================================
-- Minar Tiles Calculator - Supabase one-time setup
-- Supabase -> SQL Editor -> New query -> paste ALL -> Run.
-- Safe to run again (idempotent).
-- ============================================================

-- 1) Access system: app_users + owner/approval functions
create table if not exists public.app_users (
     user_id uuid primary key references auth.users(id) on delete cascade,
     email text not null default '',
     status text not null default 'pending' check (status in ('pending','approved','locked','kicked','rejected')),
     is_owner boolean not null default false,
     created_at timestamptz not null default now(),
     updated_at timestamptz not null default now()
   );
   alter table public.app_users enable row level security;

   create or replace function public.is_app_owner() returns boolean
   language sql stable security definer set search_path = public as $$
     select exists (select 1 from public.app_users where user_id = auth.uid() and is_owner and status = 'approved');
   $$;
   create or replace function public.is_app_approved() returns boolean
   language sql stable security definer set search_path = public as $$
     select exists (select 1 from public.app_users where user_id = auth.uid() and status = 'approved');
   $$;
   grant execute on function public.is_app_owner() to authenticated;
   grant execute on function public.is_app_approved() to authenticated;

   drop policy if exists "own row read" on public.app_users;
   create policy "own row read" on public.app_users for select to authenticated using (user_id = auth.uid());
   drop policy if exists "owner read all" on public.app_users;
   create policy "owner read all" on public.app_users for select to authenticated using (public.is_app_owner());
   drop policy if exists "owner update others" on public.app_users;
   create policy "owner update others" on public.app_users for update to authenticated
     using (public.is_app_owner() and is_owner = false) with check (is_owner = false);

   create or replace function public.register_app_user() returns public.app_users
   language plpgsql security definer set search_path = public as $$
   declare r public.app_users; first_user boolean;
   begin
     if auth.uid() is null then raise exception 'not authenticated'; end if;
     lock table public.app_users in share row exclusive mode;
     select * into r from public.app_users where user_id = auth.uid();
     if found then return r; end if;
     select not exists (select 1 from public.app_users) into first_user;
     insert into public.app_users (user_id, email, status, is_owner)
     values (auth.uid(), coalesce(auth.jwt() ->> 'email', ''), case when first_user then 'approved' else 'pending' end, first_user)
     returning * into r;
     return r;
   end $$;
   revoke all on function public.register_app_user() from public, anon;
   grant execute on function public.register_app_user() to authenticated;

   -- ডেটা টেবিলও শুধু approved ইউজারের জন্য (pending/locked/kicked ইউজার ডেটা পাবে না)

-- 2) Cloud data table: cart, pending / delivery / confirmed orders, saved sizes & codes, note
create table if not exists public.app_data (
  user_id uuid not null references auth.users(id) on delete cascade,
  key text not null,
  value jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);
alter table public.app_data enable row level security;

drop policy if exists "own data" on public.app_data;
create policy "own data" on public.app_data for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- updated_at must change on every write so other devices notice new data
create or replace function public.app_data_touch() returns trigger
language plpgsql as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists app_data_touch on public.app_data;
create trigger app_data_touch before insert or update on public.app_data
  for each row execute function public.app_data_touch();

-- 3) Only approved users can read/write data (pending / locked / kicked get nothing)
drop policy if exists "approved only" on public.app_data;
create policy "approved only" on public.app_data as restrictive for all to authenticated
  using (public.is_app_approved()) with check (public.is_app_approved());
