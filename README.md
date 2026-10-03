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

After changing the schema: add a migration in `supabase/migrations/`, run `supabase db reset`, then `npm run db:types`.

## Deploy (later)

1. Create a Supabase Cloud project, `supabase link --project-ref <ref>`, `supabase db push`.
2. Enable email confirmation in the project's Auth settings.
3. Import the repo in Vercel and set `SUPABASE_URL` and `SUPABASE_KEY`.
