-- Applications only to masters who accept students
drop policy "sender creates request" on requests;
create policy "sender creates request" on requests for insert to authenticated
  with check (
    status = 'pending'
    and exists (select 1 from profiles where id = apprentice_id and role = 'apprentice')
    and exists (select 1 from profiles where id = master_id and role = 'master')
    and ((kind = 'application' and apprentice_id = auth.uid())
      or (kind = 'invite' and master_id = auth.uid()))
    and (kind = 'invite' or exists (select 1 from profiles where id = master_id and accepting))
  );

-- Explicit grants (don't rely on default Data API exposure)
grant select on cities, crafts to anon, authenticated;
grant select on profiles, saved_masters, requests, reviews to authenticated;
grant insert, delete on saved_masters to authenticated;
grant insert on requests, reviews to authenticated;

alter function distance_km(double precision, double precision, double precision, double precision) set search_path = public;
alter function search_masters(text, int, int, boolean, boolean) set search_path = public;
alter function search_apprentices(text, int, int) set search_path = public;

revoke execute on function handle_new_user() from public, anon, authenticated;
