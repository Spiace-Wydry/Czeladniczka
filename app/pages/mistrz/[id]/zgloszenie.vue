<script setup lang="ts">
const route = useRoute()
const id = route.params.id as string
const supabase = useSupabaseClient()
const { me } = useMe()

const { data: m } = await useAsyncData(`master-mini-${id}`, async () =>
  (await supabase.from('profiles').select('full_name, duration, accepting, crafts(label)').eq('id', id).eq('role', 'master').maybeSingle()).data)
if (!m.value) throw createError({ statusCode: 404, fatal: true })

const levels = [{ id: 'zero', label: 'Zaczynam od zera' }, { id: 'hobby', label: 'Hobbystycznie' }, { id: 'szkola', label: 'Szkoła zawodowa' }]
const starts = [{ id: 'zaraz', label: 'Od zaraz' }, { id: 'miesiac', label: 'Za miesiąc' }, { id: 'wakacje', label: 'W wakacje' }]
const form = reactive({ level: 'zero', start: 'zaraz', motivation: '', exam_prep: false })
const sent = ref(false)
const error = ref('')
const busy = ref(false)

async function send() {
  busy.value = true
  error.value = ''
  const { error: e } = await supabase.from('requests')
    .insert({ apprentice_id: me.value!.id, master_id: id, kind: 'application', ...form })
  busy.value = false
  if (e) error.value = e.code === '23505' ? 'Masz już oczekujące zgłoszenie do tego mistrza.' : 'Nie udało się wysłać zgłoszenia.'
  else sent.value = true
}
</script>

<template>
  <main v-if="m" class="screen">
    <div v-if="sent" class="stack done">
      <h1 class="h1">Zgłoszenie wysłane!</h1>
      <p>Mistrz {{ m.full_name.split(' ')[0] }} dostał Twoją wiadomość. Damy Ci znać, gdy odpowie.</p>
      <NuxtLink to="/szukaj" class="btn">Szukaj dalej</NuxtLink>
      <NuxtLink to="/zgloszenia" class="btn btn-outline">Moje zgłoszenia</NuxtLink>
    </div>

    <p v-else-if="!m.accepting" class="muted">Ten mistrz obecnie nie przyjmuje uczniów.</p>

    <form v-else class="stack" @submit.prevent="send">
      <button type="button" class="back" aria-label="Wróć" @click="$router.back()">←</button>
      <h1 class="h1">Zgłoszenie do mistrza</h1>
      <div class="card row">
        <Avatar :name="m.full_name" />
        <div><b>{{ m.full_name }}</b><div class="muted">{{ m.crafts?.label }} · praktyka {{ m.duration }}</div></div>
      </div>

      <h2 class="section-title">Twoje doświadczenie</h2>
      <div class="chips">
        <button v-for="l in levels" :key="l.id" type="button" class="chip" :class="{ on: form.level === l.id }" @click="form.level = l.id">{{ l.label }}</button>
      </div>

      <h2 class="section-title">Kiedy możesz zacząć?</h2>
      <div class="chips">
        <button v-for="s in starts" :key="s.id" type="button" class="chip" :class="{ on: form.start === s.id }" @click="form.start = s.id">{{ s.label }}</button>
      </div>

      <label class="field section-label">Dlaczego chcesz poznać ten fach?
        <textarea v-model="form.motivation" required maxlength="1000" />
      </label>
      <label class="check"><input v-model="form.exam_prep" type="checkbox"> Chcę przygotować się do egzaminu czeladniczego</label>

      <p v-if="error" class="error">{{ error }}</p>
      <button class="btn btn-yellow" :disabled="busy">Wyślij zgłoszenie</button>
    </form>
  </main>
</template>

<style scoped>
.back { width: 44px; height: 44px; border-radius: 22px; border: 0; background: #fff; font-size: 20px; cursor: pointer; color: var(--brown); }
.done { margin-top: 30vh; text-align: center; }
.section-label { font: 700 21px 'Zilla Slab', Georgia, serif; margin-top: 12px; }
</style>
