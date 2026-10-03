<script setup lang="ts">
const supabase = useSupabaseClient()
const { me, logout } = useMe()
const isMaster = me.value!.role === 'master'

const [{ data: cities }, { data: crafts }] = await Promise.all([
  useAsyncData('cities', async () => (await supabase.from('cities').select('id, name').order('name')).data ?? []),
  useAsyncData('crafts', async () => (await supabase.from('crafts').select('*').order('id')).data ?? []),
])

const p = me.value!
const form = reactive({
  full_name: p.full_name, city_id: p.city_id, bio: p.bio ?? '', skills: p.skills.join(', '), craft_id: p.craft_id,
  title: p.title ?? '', years_in_trade: p.years_in_trade, trained_count: p.trained_count, accepting: p.accepting,
  paid: p.paid, available_now: p.available_now, duration: p.duration ?? '', schedule: p.schedule ?? '',
  ends_with: p.ends_with ?? 'Egzamin czeladniczy',
  age: p.age, learning_form: p.learning_form ?? '', availability: p.availability ?? '',
  max_distance_km: p.max_distance_km, goal: p.goal ?? '',
})
const status = ref('')
const busy = ref(false)

async function save() {
  busy.value = true
  status.value = ''
  // v-model.number leaves '' for empty inputs; Postgres int needs null
  const num = (v: unknown) => (v === '' || v == null ? null : Number(v))
  const { data, error } = await supabase.from('profiles')
    .update({
      ...form,
      skills: form.skills.split(',').map((s) => s.trim()).filter(Boolean),
      years_in_trade: num(form.years_in_trade), trained_count: num(form.trained_count),
      age: num(form.age), max_distance_km: num(form.max_distance_km),
    })
    .eq('id', p.id).select().single()
  busy.value = false
  if (error) status.value = 'Nie udało się zapisać profilu.'
  else { me.value = data; status.value = 'Zapisano.' }
}
</script>

<template>
  <main class="page">
    <header class="ycap">
      <div class="hello">
        <Avatar :name="p.full_name" :size="64" :tone="isMaster ? 'walnut' : 'moss'" />
        <div class="titles">
          <h1 class="h1">Mój profil</h1>
          <NuxtLink :to="isMaster ? `/mistrz/${p.id}` : `/czeladnik/${p.id}`" class="see">Zobacz, jak widzą Cię inni →</NuxtLink>
        </div>
      </div>
    </header>
    <form class="page-body" @submit.prevent="save">

      <label class="field">Imię i nazwisko <input v-model="form.full_name" required minlength="2" maxlength="80" placeholder="np. Jan Kowalski"></label>
      <label class="field">Miejscowość
        <select v-model="form.city_id" required>
          <option :value="null" disabled>Wybierz miejscowość</option>
          <option v-for="c in cities" :key="c.id" :value="c.id">{{ c.name }}</option>
        </select>
      </label>
      <label class="field">{{ isMaster ? 'Rzemiosło' : 'Szukam mistrza w rzemiośle' }}
        <select v-model="form.craft_id" required>
          <option :value="null" disabled>Wybierz rzemiosło</option>
          <option v-for="c in crafts" :key="c.id" :value="c.id">{{ c.label }}</option>
        </select>
      </label>
      <label class="field">O mnie <textarea v-model="form.bio" maxlength="2000" placeholder="Napisz kilka zdań o sobie — doświadczenie, czym się zajmujesz, czego szukasz." /></label>
      <label class="field">{{ isMaster ? 'Czego nauczę (oddziel przecinkami)' : 'Co już potrafię (oddziel przecinkami)' }}
        <input v-model="form.skills" :placeholder="isMaster ? 'np. Obróbka drewna, Renowacja mebli' : 'np. Wkrętarka i szlifierka, Proste projekty'">
      </label>

      <template v-if="isMaster">
        <label class="field">Tytuł <input v-model="form.title" placeholder="np. Mistrz stolarski" maxlength="80"></label>
        <div class="two">
          <label class="field">Lat w zawodzie <input v-model.number="form.years_in_trade" type="number" min="0" max="80" placeholder="np. 15"></label>
          <label class="field">Wyszkolonych <input v-model.number="form.trained_count" type="number" min="0" max="1000" placeholder="np. 5"></label>
        </div>
        <label class="field">Czas praktyki <input v-model="form.duration" placeholder="np. 3–6 miesięcy" maxlength="80"></label>
        <label class="field">Grafik <input v-model="form.schedule" placeholder="np. pn–pt, 8:00–14:00" maxlength="80"></label>
        <label class="field">Na koniec <input v-model="form.ends_with" maxlength="80" placeholder="np. Egzamin czeladniczy"></label>
        <div class="checks">
          <label class="check"><input v-model="form.accepting" type="checkbox"> Przyjmuję uczniów</label>
          <label class="check"><input v-model="form.paid" type="checkbox"> Płatna praktyka</label>
          <label class="check"><input v-model="form.available_now" type="checkbox"> Od zaraz</label>
        </div>
      </template>

      <template v-else>
        <div class="two">
          <label class="field">Wiek <input v-model.number="form.age" type="number" min="14" max="99" placeholder="np. 19"></label>
          <label class="field">Dojazd do (km) <input v-model.number="form.max_distance_km" type="number" min="1" max="500" placeholder="np. 20"></label>
        </div>
        <label class="field">Forma nauki <input v-model="form.learning_form" placeholder="np. Praktyka w warsztacie" maxlength="80"></label>
        <label class="field">Dostępność <input v-model="form.availability" placeholder="np. pn–pt, od zaraz" maxlength="80"></label>
        <label class="field">Cel <input v-model="form.goal" placeholder="np. Egzamin czeladniczy" maxlength="80"></label>
        <label class="check"><input v-model="form.paid" type="checkbox"> Szukam płatnej praktyki</label>
        <label class="check"><input v-model="form.available_now" type="checkbox"> Mogę zacząć od zaraz</label>
      </template>

      <p v-if="status" :class="status === 'Zapisano.' ? 'tag' : 'error'">{{ status }}</p>
      <button class="btn" :disabled="busy">Zapisz</button>
      <button type="button" class="btn btn-outline" @click="logout">Wyloguj się</button>
    </form>
  </main>
</template>

<style scoped>
.hello { display: flex; align-items: center; gap: 16px; }
.titles { display: flex; flex-direction: column; gap: 4px; min-width: 0; }
.see { font-size: 14px; font-weight: 700; display: inline-flex; align-items: center; min-height: 44px; margin: -10px 0; }
.two { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 12px; }
.checks { display: flex; flex-direction: column; gap: 10px; }
</style>
