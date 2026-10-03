insert into cities (name, lat, lng) values
('Warszawa',52.2297,21.0122),('Kraków',50.0647,19.9450),('Łódź',51.7592,19.4560),('Wrocław',51.1079,17.0385),
('Poznań',52.4064,16.9252),('Gdańsk',54.3520,18.6466),('Szczecin',53.4285,14.5528),('Bydgoszcz',53.1235,18.0084),
('Lublin',51.2465,22.5684),('Białystok',53.1325,23.1688),('Katowice',50.2649,19.0238),('Gdynia',54.5189,18.5305),
('Częstochowa',50.8118,19.1203),('Radom',51.4027,21.1471),('Toruń',53.0138,18.5984),('Kielce',50.8661,20.6286),
('Rzeszów',50.0412,21.9991),('Gliwice',50.2945,18.6714),('Olsztyn',53.7784,20.4801),('Opole',50.6751,17.9213),
('Zielona Góra',51.9356,15.5062),('Gorzów Wielkopolski',52.7368,15.2288),('Płock',52.5468,19.7064),('Elbląg',54.1561,19.4045),
('Tarnów',50.0121,20.9858),('Kalisz',51.7611,18.0910),('Koszalin',54.1944,16.1722),('Legnica',51.2070,16.1619),
('Nowy Sącz',49.6218,20.6970),('Siedlce',52.1676,22.2902),('Piła',53.1513,16.7378),('Suwałki',54.1118,22.9309),
('Zamość',50.7231,23.2520),('Łomża',53.1781,22.0590),('Konin',52.2230,18.2511),('Ostrołęka',53.0845,21.5754),
('Skierniewice',51.9547,20.1580),('Sochaczew',52.2295,20.2383),('Żyrardów',52.0488,20.4456),('Łowicz',52.1069,19.9445),
('Grodzisk Mazowiecki',52.1094,20.6336),('Błonie',52.1979,20.6170),('Pruszków',52.1708,20.8128),('Piaseczno',52.0815,21.0237),
('Wyszków',52.5928,21.4580),('Mińsk Mazowiecki',52.1793,21.5715),('Ciechanów',52.8811,20.6197),('Płońsk',52.6234,20.3755),
('Gostynin',52.4290,19.4616),('Kutno',52.2307,19.3644),('Zakopane',49.2992,19.9496),('Sopot',54.4416,18.5601);

insert into crafts (slug, label, icon, bg, ink) values
('stolarstwo','Stolarstwo','M2 7h20v3H2zM5 10v10M19 10v10M5 15h14','#FBEBC0','#7A4E2D'),
('kowalstwo','Kowalstwo','M3 9h14l4-3v6h-4l-2 3H7l-2-3H3zM9 15v4M13 15v4M7 19h8','#DCE8CF','#2F5A2C'),
('murarstwo','Murarstwo','M3 5h18v14H3zM3 10h18M3 14.5h18M9 5v5M15 10v4.5M9 14.5V19','#F1DCC8','#7A4E2D'),
('elektryka','Elektryka','M13 2L5 14h6l-1 8 8-12h-6z','#FBEBC0','#7A4E2D'),
('hydraulika','Hydraulika','M3 9h11a4 4 0 0 1 4 4v2h-4v-2H3zM9 9V6M6 6h6M16 18v2','#DCE8CF','#2F5A2C'),
('slusarstwo','Ślusarstwo','M15 3a5 5 0 0 0-4.6 6.9L3 17.3V21h3.7l7.4-7.4A5 5 0 1 0 15 3z','#F1DCC8','#7A4E2D'),
('tapicerstwo','Tapicerstwo','M4 11V8a3 3 0 0 1 3-3h10a3 3 0 0 1 3 3v3M2 11h20v6H2zM5 17v3M19 17v3','#FBEBC0','#7A4E2D'),
('krawiectwo','Krawiectwo','M3 6a3 3 0 1 0 6 0a3 3 0 1 0-6 0M3 18a3 3 0 1 0 6 0a3 3 0 1 0-6 0M20 4L8.12 15.88M14.47 14.48L20 20M8.12 8.12L12 12','#DCE8CF','#2F5A2C');

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
from auth.users;

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
