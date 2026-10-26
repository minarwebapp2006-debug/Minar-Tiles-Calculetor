# Minar Tiles Calculator

Static web app (HTML/CSS/JS) with Supabase login and cloud sync. No build step.

## Files
- `index.html`: main calculator app
- `login.html`: login / sign-up page
- `manifest.json`, `sw.js`: PWA install and offline cache
- `assets/`: fonts and icons
- `vercel.json`: Vercel headers and clean URLs

## Local run
    python -m http.server 8000
Open http://localhost:8000/login.html

## Deploy
Push to GitHub, then import the repo in Vercel (Framework: Other, no build command).

## Supabase
Project URL and anon key are set in the `SUPABASE_URL` and `SUPABASE_ANON_KEY` constants in both `index.html` and `login.html`. Never place a `service_role` key in this repo.

## Supabase setup (one time)
1. Open supabase.com, project `fvmenotxbkrugqzhrkim`.
2. SQL Editor → New query → paste the whole of `supabase/supabase-setup.sql` → Run.
3. Authentication → Providers → Email: keep "Confirm email" OFF.
4. Authentication → URL Configuration: set Site URL and Redirect URLs to your Vercel/domain (`https://yourdomain/**`).
5. Open the app's login page and sign up yourself first. The first signed-up user becomes App Owner.

## Publish checklist
- [ ] `assets/` folder is in the repo root
- [ ] `index.html`, `login.html`, `manifest.json`, `sw.js`, `vercel.json` are in the repo root
- [ ] Supabase SQL run once
- [ ] Vercel project deployed (Framework: Other, no build command)
- [ ] Custom domain added in Vercel and in Supabase URL settings
