-- Reference data ---------------------------------------------------------
create table cities (
  id int generated always as identity primary key,
  name text not null unique,
  lat double precision not null,
  lng double precision not null
);

create table crafts (
  id int generated always as identity primary key,
  slug text not null unique,
  label text not null,
  icon text not null,   -- SVG path, 24x24 viewBox, stroked
  bg text not null,
  ink text not null
);

-- Profiles -----------------------------------------------------------------
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  role text not null check (role in ('apprentice', 'master')),
  full_name text not null check (length(full_name) between 2 and 80),
  city_id int references cities,
  bio text check (length(bio) <= 2000),
  skills text[] not null default '{}',
  craft_id int references crafts,
  -- master
  title text,
  years_in_trade int check (years_in_trade between 0 and 80),
  trained_count int check (trained_count between 0 and 1000),
  accepting boolean not null default true,
  paid boolean not null default false,
  available_now boolean not null default false,
  duration text,
  schedule text,
  ends_with text,
  -- apprentice
  age int check (age between 14 and 99),
  learning_form text,
  availability text,
  max_distance_km int check (max_distance_km between 1 and 500),
  goal text,
  created_at timestamptz not null default now()
);

create function handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, role, full_name, city_id)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'role', 'apprentice'),
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    nullif(new.raw_user_meta_data->>'city_id', '')::int
  );
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

-- Saved masters ------------------------------------------------------------
create table saved_masters (
  apprentice_id uuid not null references profiles on delete cascade,
  master_id uuid not null references profiles on delete cascade,
  created_at timestamptz not null default now(),
  primary key (apprentice_id, master_id)
);

-- Requests (applications + invites) ---------------------------------------
create table requests (
  id bigint generated always as identity primary key,
  apprentice_id uuid not null references profiles on delete cascade,
  master_id uuid not null references profiles on delete cascade,
  kind text not null check (kind in ('application', 'invite')),
  level text check (level in ('zero', 'hobby', 'szkola')),
  start text check (start in ('zaraz', 'miesiac', 'wakacje')),
  motivation text check (length(motivation) <= 1000),
  exam_prep boolean not null default false,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'declined')),
  created_at timestamptz not null default now()
);
create unique index requests_one_pending on requests (apprentice_id, master_id) where status = 'pending';

-- Reviews --------------------------------------------------------------------
create table reviews (
  apprentice_id uuid not null references profiles on delete cascade,
  master_id uuid not null references profiles on delete cascade,
  stars int not null check (stars between 1 and 5),
  text text check (length(text) <= 1000),
  created_at timestamptz not null default now(),
  primary key (apprentice_id, master_id)
);

-- RLS ------------------------------------------------------------------------
alter table cities enable row level security;
alter table crafts enable row level security;
alter table profiles enable row level security;
alter table saved_masters enable row level security;
alter table requests enable row level security;
alter table reviews enable row level security;

create policy "cities readable" on cities for select using (true);
create policy "crafts readable" on crafts for select using (true);

create policy "profiles readable" on profiles for select to authenticated using (true);
create policy "own profile update" on profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());
-- id, role and created_at can never be changed by users
revoke update on profiles from authenticated, anon;
grant update (full_name, city_id, bio, skills, craft_id, title, years_in_trade, trained_count, accepting, paid,
  available_now, duration, schedule, ends_with, age, learning_form, availability, max_distance_km, goal)
  on profiles to authenticated;

create policy "own saved" on saved_masters for all to authenticated
  using (apprentice_id = auth.uid()) with check (apprentice_id = auth.uid());

create policy "parties read requests" on requests for select to authenticated
  using (auth.uid() in (apprentice_id, master_id));
create policy "sender creates request" on requests for insert to authenticated
  with check (
    status = 'pending'
    and exists (select 1 from profiles where id = apprentice_id and role = 'apprentice')
    and exists (select 1 from profiles where id = master_id and role = 'master')
    and ((kind = 'application' and apprentice_id = auth.uid())
      or (kind = 'invite' and master_id = auth.uid()))
  );
create policy "recipient answers request" on requests for update to authenticated
  using (status = 'pending' and auth.uid() = case kind when 'application' then master_id else apprentice_id end)
  with check (status in ('accepted', 'declined'));
revoke update on requests from authenticated, anon;
grant update (status) on requests to authenticated;

create policy "reviews readable" on reviews for select to authenticated using (true);
create policy "reviewer with accepted request" on reviews for insert to authenticated
  with check (
    apprentice_id = auth.uid()
    and exists (select 1 from requests r
      where r.apprentice_id = reviews.apprentice_id and r.master_id = reviews.master_id and r.status = 'accepted')
  );

-- Search -------------------------------------------------------------------
create function distance_km(lat1 double precision, lng1 double precision, lat2 double precision, lng2 double precision)
returns int language sql immutable as $$
  select round(12742 * asin(sqrt(
    power(sin(radians(lat2 - lat1) / 2), 2)
    + cos(radians(lat1)) * cos(radians(lat2)) * power(sin(radians(lng2 - lng1) / 2), 2)
  )))::int
$$;

create function search_masters(
  q text default null, p_craft_id int default null, max_km int default null,
  p_paid boolean default false, p_available_now boolean default false
) returns table (
  id uuid, full_name text, title text, craft_label text, city_name text,
  distance_km int, rating_avg numeric, review_count int, accepting boolean, duration text
) language sql stable security invoker as $$
  with me as (
    select c.lat, c.lng from profiles p join cities c on c.id = p.city_id where p.id = auth.uid()
  )
  select * from (
    select m.id, m.full_name, m.title, cr.label, ci.name,
      distance_km(me.lat, me.lng, ci.lat, ci.lng) as distance_km,
      r.avg, r.cnt::int, m.accepting, m.duration
    from profiles m
    left join crafts cr on cr.id = m.craft_id
    left join cities ci on ci.id = m.city_id
    left join me on true
    left join lateral (select round(avg(stars), 1) as avg, count(*) as cnt from reviews where master_id = m.id) r on true
    where m.role = 'master'
      and (p_craft_id is null or m.craft_id = p_craft_id)
      and (not p_paid or m.paid)
      and (not p_available_now or m.available_now)
      and (q is null or m.full_name ilike '%' || q || '%' or cr.label ilike '%' || q || '%'
           or m.title ilike '%' || q || '%' or array_to_string(m.skills, ' ') ilike '%' || q || '%')
  ) s
  where max_km is null or s.distance_km <= max_km
  order by s.distance_km nulls last, s.full_name
$$;

create function search_apprentices(
  q text default null, p_craft_id int default null, max_km int default null
) returns table (
  id uuid, full_name text, age int, craft_label text, city_name text,
  distance_km int, availability text, goal text
) language sql stable security invoker as $$
  with me as (
    select c.lat, c.lng from profiles p join cities c on c.id = p.city_id where p.id = auth.uid()
  )
  select * from (
    select a.id, a.full_name, a.age, cr.label, ci.name,
      distance_km(me.lat, me.lng, ci.lat, ci.lng) as distance_km,
      a.availability, a.goal
    from profiles a
    left join crafts cr on cr.id = a.craft_id
    left join cities ci on ci.id = a.city_id
    left join me on true
    where a.role = 'apprentice'
      and (p_craft_id is null or a.craft_id = p_craft_id)
      and (q is null or a.full_name ilike '%' || q || '%' or cr.label ilike '%' || q || '%'
           or a.bio ilike '%' || q || '%' or array_to_string(a.skills, ' ') ilike '%' || q || '%')
  ) s
  where max_km is null or s.distance_km <= max_km
  order by s.distance_km nulls last, s.full_name
$$;
