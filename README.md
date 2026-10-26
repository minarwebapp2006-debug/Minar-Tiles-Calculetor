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
