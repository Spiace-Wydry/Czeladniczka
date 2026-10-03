# Czeladniczka

Apprentices find craft masters; masters find apprentices. Nuxt 4 + Supabase.

## Run locally

Requires Node 20+, Docker and the [Supabase CLI](https://supabase.com/docs/guides/cli).

```bash
npm install
supabase start                 # Postgres, Auth, Studio (http://127.0.0.1:54523) in Docker
cp .env.example .env           # paste the publishable/anon key from `supabase status`
supabase db reset              # applies migrations + seed
npm run dev                    # http://localhost:3000
```

Local Supabase ports are shifted in `supabase/config.toml` (API 54521, DB 54522, Studio 54523) to avoid clashing with other local Supabase projects.

Demo accounts (password `password123`): masters `henryk@`, `maria@`, `zbigniew@`, `marek@`, `andrzej@`, `teresa@`; apprentices `kacper@`, `julia@`, `oskar@` — all `@example.com`.

### Test on a phone (same Wi-Fi)

Supabase auth needs a secure context, so plain `http://<lan-ip>:3000` won't log in. Use HTTPS with Supabase proxied same-origin (dev only):

1. In `.env` set `SUPABASE_URL=https://<lan-ip>:3000/supabase` (find the IP with `ip -4 route get 1.1.1.1`).
2. `npm run dev:lan`, then open `https://<lan-ip>:3000` on the phone and accept the self-signed certificate warning.
3. Set `SUPABASE_URL` back to `http://127.0.0.1:54521` for normal `npm run dev`.

After changing the schema: add a migration in `supabase/migrations/`, run `supabase db reset`, then `npm run db:types`.

## Deploy (later)

1. Create a Supabase Cloud project, `supabase link --project-ref <ref>`, then on the FIRST push only:
   `supabase db push --include-seed`. Migrations create the schema and reference data (cities, crafts);
   `seed.sql` adds the demo accounts (password `password123`) — this is a showcase deployment, so they're wanted.
   Later pushes: plain `supabase db push` (the seed isn't idempotent; re-running it fails on existing users).
2. In Auth → Sign In / Providers → Email, turn OFF "Confirm email" so sign-up logs straight in (the app handles both modes).
3. Import the repo in Vercel and set `SUPABASE_URL` and `SUPABASE_KEY`.
4. In Supabase Auth → URL Configuration set "Site URL" to the Vercel domain and add it (plus preview URLs if wanted) to "Redirect URLs".
