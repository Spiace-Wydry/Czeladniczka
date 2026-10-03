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
  <main v-if="m && sent" class="sent">
    <span class="sent-icon">
      <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="#3B2716" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12l5 5 9-10" /></svg>
    </span>
    <h1>Zgłoszenie wysłane!</h1>
    <p>Mistrz {{ m.full_name.split(' ')[0] }} dostał Twoją wiadomość. Damy Ci znać, gdy odpowie.</p>
    <NuxtLink to="/szukaj" class="btn btn-yellow">Szukaj dalej</NuxtLink>
    <NuxtLink to="/zgloszenia" class="link">Moje zgłoszenia</NuxtLink>
  </main>

  <main v-else-if="m" class="page" :class="{ 'has-bar': m.accepting }">
    <form id="apply" class="form" @submit.prevent="send">
      <div class="title">
        <button type="button" class="round light" aria-label="Wróć" @click="$router.back()">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3B2716" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 5l-7 7 7 7" /></svg>
        </button>
        <h1>Zgłoszenie do mistrza</h1>
      </div>

      <div class="who">
        <Avatar :name="m.full_name" :size="48" />
        <span class="who-text"><b>{{ m.full_name }}</b><span>{{ m.crafts?.label }}<template v-if="m.duration"> · praktyka {{ m.duration }}</template></span></span>
      </div>

      <p v-if="!m.accepting" class="muted">Ten mistrz obecnie nie przyjmuje uczniów.</p>

      <template v-else>
        <fieldset>
          <legend>Twoje doświadczenie</legend>
          <div class="chips">
            <button v-for="l in levels" :key="l.id" type="button" class="chip" :class="{ on: form.level === l.id }" :aria-pressed="form.level === l.id" @click="form.level = l.id">{{ l.label }}</button>
          </div>
        </fieldset>

        <fieldset>
          <legend>Kiedy możesz zacząć?</legend>
          <div class="chips">
            <button v-for="s in starts" :key="s.id" type="button" class="chip" :class="{ on: form.start === s.id }" :aria-pressed="form.start === s.id" @click="form.start = s.id">{{ s.label }}</button>
          </div>
        </fieldset>

        <label class="field">Dlaczego chcesz poznać ten fach?
          <textarea v-model="form.motivation" rows="4" required maxlength="1000"
            placeholder="Napisz kilka zdań o sobie i o tym, czego chcesz się nauczyć…" />
        </label>
        <label class="check"><input v-model="form.exam_prep" type="checkbox"> Chcę przygotować się do egzaminu czeladniczego</label>

        <p v-if="error" class="error">{{ error }}</p>
      </template>
    </form>

    <div v-if="m.accepting" class="bar plain">
      <button form="apply" class="btn" :disabled="busy">Wyślij zgłoszenie</button>
    </div>
  </main>
</template>

<style scoped>
.form { padding: 36px 20px 0; display: flex; flex-direction: column; gap: 18px; }
.title { display: flex; align-items: center; gap: 12px; }
.title h1 { font-size: 24px; }
.who { display: flex; align-items: center; gap: 12px; padding: 12px; border-radius: 18px; background: var(--yellow); }
.who-text { display: flex; flex-direction: column; gap: 2px; }
.who-text b { font-weight: 800; }
.who-text span { font-size: 13px; font-weight: 600; }
fieldset { border: 0; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
legend { font-weight: 800; font-size: 15px; margin-bottom: 10px; padding: 0; }
.field textarea { resize: none; min-height: 0; }
.sent { max-width: 480px; margin: 0 auto; min-height: 100dvh; padding: 0 28px 40px; display: flex; flex-direction: column; align-items: center;
  justify-content: center; gap: 18px; text-align: center; background: var(--moss); color: var(--cream); }
.sent-icon { display: flex; width: 112px; height: 112px; border-radius: 50%; background: var(--yellow); align-items: center; justify-content: center; }
.sent h1 { font-size: 34px; line-height: 1.1; }
.sent p { margin: 0; font-size: 16px; line-height: 1.5; max-width: 300px; }
.sent .btn { margin-top: 12px; width: auto; padding: 0 32px; }
.link { display: flex; align-items: center; min-height: 44px; color: var(--cream); font-weight: 700; }
.link:hover { color: var(--light); }
</style>
