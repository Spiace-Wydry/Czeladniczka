# Czeladniczka — MVP design

Source design: https://claude.ai/artifact/5me1TKwXJR2Gm2QtqYBBbL (7 mobile screens + style guide, Polish UI).

> Implementation deviations (Nuxt 4 SPA, reduced component list, ~50 cities, no `available_now` for apprentice search) are recorded in `docs/superpowers/plans/2026-10-03-czeladniczka-mvp.md`.

Czeladniczka connects apprentices (czeladnik/czeladniczka) with craft masters (mistrz). Apprentices search masters, save them, and apply; masters browse apprentices and invite them; either side accepts/declines. Apprentices with an accepted request can review the master.

## Stack

- Nuxt 3 + `@nuxtjs/supabase`, pages query Supabase directly; authorization via Postgres RLS.
- Supabase (local via `supabase start` in Docker; later Supabase Cloud).
- Plain CSS with design tokens as CSS variables; fonts Zilla Slab (700) + Manrope (500–800) from Google Fonts.
- Deploy target: Vercel (Nuxt auto-preset). Deployment itself is out of scope for this build.
- No automated tests (explicit decision for speed). Verification = manual run-through of the core flow against local Supabase with seed users.

## Scope

In: email+password auth with role at signup, profiles (master/apprentice), master search with distance + toggles, saved masters, requests (applications + invites) with accept/decline, reviews (1–5 stars + text).

Out (v2+): chat ("Napisz" buttons hidden, Wiadomości tab replaced by Zgłoszenia), avatar/photo upload, notifications, admin panel, i18n.

## Data model (`supabase/migrations/`)

All tables have RLS enabled.

**`cities`** — `id`, `name`, `lat`, `lng`. Seeded (~100 Polish towns). Read: authenticated + anon (signup form).

**`crafts`** — `id`, `slug`, `label`, `icon` (SVG path), `bg`, `ink`. Seeded with the 8 design crafts (Stolarstwo, Kowalstwo, Murarstwo, Elektryka, Hydraulika, Ślusarstwo, Tapicerstwo, Krawiectwo). Read: everyone.

**`profiles`** — `id` = `auth.users.id`.
- Common: `role` (`'apprentice' | 'master'`, CHECK), `full_name`, `city_id`, `bio`, `skills text[]`, `created_at`.
- Master: `craft_id`, `title`, `years_in_trade`, `trained_count`, `accepting bool`, `paid bool`, `available_now bool`, `duration`, `schedule`, `ends_with`.
- Apprentice: `age`, `craft_id` (sought craft), `learning_form`, `availability`, `max_distance_km`, `goal`.
- `skills` = "Czego Cię nauczę" for masters, "Co już potrafię" for apprentices.
- Created by trigger on `auth.users` insert from signup metadata (`role`, `full_name`, `city_id`).
- RLS: authenticated can read all; user can update only own row; `role` not changeable after creation.

**`saved_masters`** — PK (`apprentice_id`, `master_id`). RLS: apprentice reads/inserts/deletes own rows.

**`requests`** — `id`, `apprentice_id`, `master_id`, `kind` (`'application' | 'invite'`), `level` (`'zero' | 'hobby' | 'szkola'`, nullable for invites), `start` (`'zaraz' | 'miesiac' | 'wakacje'`, nullable for invites), `motivation text`, `exam_prep bool`, `status` (`'pending' | 'accepted' | 'declined'`, default pending), `created_at`.
- Partial unique index: one `pending` request per (`apprentice_id`, `master_id`).
- RLS: both parties read; insert only by sender (apprentice for application, master for invite) with `status = 'pending'`; update of `status` only by recipient.

**`reviews`** — PK (`apprentice_id`, `master_id`), `stars` (CHECK 1–5), `text`, `created_at`. RLS: everyone authenticated reads; insert only by the apprentice themself when an `accepted` request exists between the pair.

**Functions (SQL, `security invoker`)**
- `search_masters(q text, craft_id int, max_km int, paid bool, available_now bool)` → master cards: id, full_name, title, craft label, city name, distance_km (haversine from caller's city), rating_avg, review_count, accepting, duration. `q` matches name/craft/skills (ILIKE). Null params = no filter. Ordered by distance.
- `search_apprentices(q, craft_id, max_km, available_now)` → mirror for masters.
- Ratings computed in these queries and on the profile page — no stored rating.

## Routes (`pages/`)

| Route | Screen | Access |
|---|---|---|
| `/` | Powitanie; role buttons → `/signup?role=apprentice|master`, "Zaloguj się" → `/login` | public; logged-in → `/szukaj` |
| `/signup` | email, password, name, city (role from query) | public |
| `/login` | email, password | public |
| `/szukaj` | apprentice: Szukaj mistrza (greeting, search, toggle chips Do 20 km / Płatna praktyka / Od zaraz, craft grid, master list). master: same layout listing apprentices | auth |
| `/mistrz/[id]` | Profil mistrza: stats (rating, trained, years), skills, terms, save toggle, "Poproś o naukę", reviews list + review form when eligible | auth |
| `/mistrz/[id]/zgloszenie` | Zgłoszenie form → "Zgłoszenie wysłane!" state | apprentice |
| `/czeladnik/[id]` | Profil czeladnika; "Zaproś do warsztatu" (master only) | auth |
| `/zapisane` | saved masters | apprentice |
| `/zgloszenia` | sent + received requests, accept/decline on received pending | auth |
| `/profil` | edit own profile (role-specific fields), log out | auth |

Bottom nav (`AppNav`): Szukaj · Zapisane · Zgłoszenia · Profil (masters: no Zapisane).

`middleware/auth.global.ts` enforces auth/role per table above.

## Components

`AppNav`, `MasterCard`, `ApprenticeCard`, `Chip`, `CraftTile`, `Avatar` (initials), `RequestCard`. Data access inline via `useSupabaseClient()`; types from `supabase gen types typescript --local`.

## Styling

Tokens in `assets/main.css`: yellow `#F4C542`, honey `#E0A422`, cream bg `#FFF7E2`, light yellow `#FBEBC0`, dark brown text `#3B2716`, walnut `#7A4E2D`, moss `#3E6B3A`, sage `#DCE8CF`. Radii: buttons 28px, cards 20px, tiles 18–20px, chips 14px; touch targets ≥ 44px. Mobile-first, content column max ~480px centered on desktop.

## Error handling

- Native form validation (`required`, `minlength`, `maxlength`); DB constraints + RLS are the real guard.
- Supabase errors shown inline under the form, in Polish. Unique-violation on requests → "Masz już oczekujące zgłoszenie do tego mistrza."
- Missing profile → 404 via `error.vue`. No session → `/login`.

## Seed (`supabase/seed.sql`)

Cities, crafts, ~6 masters (incl. Henryk Nowak, stolarstwo, Sochaczew) and 3 apprentices (Kacper Zieliński, Julia, Oskar) from the design, with known passwords (`password123`) for manual testing.

## Environments

- Local: `supabase start` + `npm run dev`; `.env` with `SUPABASE_URL`, `SUPABASE_KEY` from `supabase status`. Email confirmation off.
- Production (later): Supabase Cloud project, `supabase link && supabase db push`, Vercel import with the two env vars, email confirmation on.
