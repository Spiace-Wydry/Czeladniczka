-- Apprentices reuse profiles.paid ("szukam płatnej praktyki") and profiles.available_now ("mogę zacząć od zaraz"),
-- so masters get the same "Płatna praktyka" / "Od zaraz" filters as apprentices.
drop function search_apprentices(text, int, int);

create function search_apprentices(
  q text default null, p_craft_id int default null, max_km int default null,
  p_paid boolean default false, p_available_now boolean default false
) returns table (
  id uuid, full_name text, age int, craft_label text, city_name text,
  distance_km int, availability text, goal text
) language sql stable security invoker set search_path = public as $$
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
      and (not p_paid or a.paid)
      and (not p_available_now or a.available_now)
      and (q is null or a.full_name ilike '%' || q || '%' or cr.label ilike '%' || q || '%'
           or a.bio ilike '%' || q || '%' or array_to_string(a.skills, ' ') ilike '%' || q || '%')
  ) s
  where max_km is null or s.distance_km <= max_km
  order by s.distance_km nulls last, s.full_name
$$;
