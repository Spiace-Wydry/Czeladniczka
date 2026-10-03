-- Demo users. The on_auth_user_created trigger creates their profiles.
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change)
select '00000000-0000-0000-0000-000000000000', u.id, 'authenticated', 'authenticated', u.email,
  extensions.crypt('password123', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}',
  jsonb_build_object('role', u.role, 'full_name', u.full_name, 'city_id', (select id from cities where name = u.city)),
  now(), now(), '', '', '', ''
from (values
  ('a0000000-0000-0000-0000-000000000001'::uuid, 'henryk@example.com',   'master',     'Henryk Nowak',        'Sochaczew'),
  ('a0000000-0000-0000-0000-000000000002'::uuid, 'maria@example.com',    'master',     'Maria Wójcik',        'Łowicz'),
  ('a0000000-0000-0000-0000-000000000003'::uuid, 'zbigniew@example.com', 'master',     'Zbigniew Kowal',      'Żyrardów'),
  ('a0000000-0000-0000-0000-000000000004'::uuid, 'marek@example.com',    'master',     'Marek Wiśniewski',    'Błonie'),
  ('a0000000-0000-0000-0000-000000000005'::uuid, 'andrzej@example.com',  'master',     'Andrzej Mazur',       'Grodzisk Mazowiecki'),
  ('a0000000-0000-0000-0000-000000000006'::uuid, 'teresa@example.com',   'master',     'Teresa Lis',          'Warszawa'),
  ('b0000000-0000-0000-0000-000000000001'::uuid, 'kacper@example.com',   'apprentice', 'Kacper Zieliński',    'Sochaczew'),
  ('b0000000-0000-0000-0000-000000000002'::uuid, 'julia@example.com',    'apprentice', 'Julia Kamińska',      'Łowicz'),
  ('b0000000-0000-0000-0000-000000000003'::uuid, 'oskar@example.com',    'apprentice', 'Oskar Lewandowski',   'Żyrardów')
) as u(id, email, role, full_name, city);

insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select gen_random_uuid(), id, id::text, jsonb_build_object('sub', id::text, 'email', email), 'email', now(), now(), now()
from auth.users where email like '%@example.com';

-- Master details
update profiles p set craft_id = (select id from crafts where slug = v.craft), title = v.title, years_in_trade = v.years,
  trained_count = v.trained, paid = v.paid, available_now = v.now, duration = v.duration, schedule = v.schedule,
  ends_with = 'Egzamin czeladniczy', skills = v.skills, bio = v.bio
from (values
  ('a0000000-0000-0000-0000-000000000001'::uuid, 'stolarstwo', 'Mistrz stolarski', 30, 12, true, true, '3–6 miesięcy', 'pn–pt, 8:00–14:00',
    array['Obróbka drewna litego','Połączenia ciesielskie','Renowacja mebli','Wykańczanie i lakiery'],
    'Prowadzę warsztat stolarski od trzydziestu lat. Uczę porządnej roboty — od wyboru deski po ostatnią warstwę lakieru.'),
  ('a0000000-0000-0000-0000-000000000002'::uuid, 'tapicerstwo', 'Mistrzyni tapicerska', 22, 8, false, true, 'Weekendy', 'sob–nd, 9:00–15:00',
    array['Tapicerstwo tradycyjne','Sprężyny i pasy','Dobór tkanin'],
    'Odnawiam fotele i kanapy metodą tradycyjną. Chętnie przyjmę osobę na weekendowe zajęcia.'),
  ('a0000000-0000-0000-0000-000000000003'::uuid, 'kowalstwo', 'Mistrz kowalski', 25, 6, true, false, '6–12 miesięcy', 'pn–pt, 7:00–15:00',
    array['Kucie artystyczne','Balustrady i bramy','Hartowanie'],
    'Kuźnia z tradycjami. Uczę kowalstwa artystycznego od podstaw.'),
  ('a0000000-0000-0000-0000-000000000004'::uuid, 'elektryka', 'Mistrz elektryk', 18, 15, true, true, '6 miesięcy', 'pn–pt, 7:00–15:00',
    array['Instalacje domowe','Pomiary elektryczne','Rozdzielnice'],
    'Instalacje elektryczne w domach jednorodzinnych. Przygotowuję też do uprawnień SEP.'),
  ('a0000000-0000-0000-0000-000000000005'::uuid, 'hydraulika', 'Mistrz hydraulik', 20, 9, true, false, '3–6 miesięcy', 'pn–pt, 8:00–16:00',
    array['Instalacje wod-kan','Ogrzewanie podłogowe','Lutowanie miedzi'],
    'Hydraulika i ogrzewanie. Konkretna praca na budowach w okolicy.'),
  ('a0000000-0000-0000-0000-000000000006'::uuid, 'krawiectwo', 'Mistrzyni krawiecka', 27, 11, false, true, '4–8 miesięcy', 'pn–pt, 10:00–16:00',
    array['Szycie na miarę','Konstrukcja wykrojów','Przeróbki'],
    'Pracownia krawiecka w centrum Warszawy. Szyjemy na miarę i uczymy konstrukcji odzieży.')
) as v(id, craft, title, years, trained, paid, now, duration, schedule, skills, bio)
where p.id = v.id;

-- Apprentice details (text from the design boards)
update profiles p set craft_id = (select id from crafts where slug = v.craft), age = v.age, learning_form = v.form,
  availability = v.avail, max_distance_km = v.km, goal = v.goal, skills = v.skills, bio = v.bio
from (values
  ('b0000000-0000-0000-0000-000000000001'::uuid, 'stolarstwo', 19, 'Praktyka w warsztacie', 'pn–pt, od zaraz', 20, 'Egzamin czeladniczy',
    array['Wkrętarka i szlifierka','Proste projekty','Prawo jazdy kat. B'],
    'Skończyłem technikum, ale najlepiej czuję się przy pracy rękami. Od dwóch lat w garażu robię proste meble z palet i desek — półki, stolik, ławkę dla babci. Chcę nauczyć się tego porządnie, od mistrza.'),
  ('b0000000-0000-0000-0000-000000000002'::uuid, 'tapicerstwo', 21, 'Zajęcia przy projektach', 'Weekendy', 30, 'Własna pracownia renowacji',
    array['Szycie na maszynie','Zszywacz tapicerski','Dobór tkanin'],
    'Studiuję zaocznie, a w wolnym czasie ratuję stare fotele i krzesła z targów staroci. Uczę się z filmów, ale brakuje mi kogoś, kto pokaże, jak robić to tradycyjnie — sprężyny, pasy, naciąganie tkaniny.'),
  ('b0000000-0000-0000-0000-000000000003'::uuid, 'kowalstwo', 18, 'Praktyka w kuźni', 'Od wakacji, pełny etat', 40, 'Egzamin czeladniczy',
    array['Podstawy spawania','Rysunek techniczny','Siła i wytrwałość'],
    'W tym roku piszę maturę i wiem już, że nie chcę pracy za biurkiem. Fascynuje mnie metal — balustrady, bramy, kute ozdoby. Szukam kowala, który pozwoli mi stanąć przy kowadle i nauczy fachu od podstaw.')
) as v(id, craft, age, form, avail, km, goal, skills, bio)
where p.id = v.id;

-- Julia studied with Maria and left a review
insert into requests (apprentice_id, master_id, kind, level, start, motivation, status) values
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'application', 'hobby', 'zaraz',
   'Chcę nauczyć się tapicerstwa tradycyjnego.', 'accepted');
insert into reviews (apprentice_id, master_id, stars, text) values
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 5,
   'Pani Maria cierpliwie pokazała mi wszystko od sprężyn po obicie. Polecam!');
