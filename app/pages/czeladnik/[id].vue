<script setup lang="ts">
const route = useRoute()
const id = route.params.id as string
const supabase = useSupabaseClient()
const { me } = useMe()
const isMaster = computed(() => me.value?.role === 'master')

const { data: a } = await useAsyncData(`apprentice-${id}`, async () =>
  (await supabase.from('profiles').select('*, crafts(label), cities(name)').eq('id', id).eq('role', 'apprentice').maybeSingle()).data)
if (!a.value) throw createError({ statusCode: 404, fatal: true })

const inviting = ref(false)
const message = ref('')
const sent = ref(false)
const error = ref('')

async function invite() {
  error.value = ''
  const { error: e } = await supabase.from('requests')
    .insert({ apprentice_id: id, master_id: me.value!.id, kind: 'invite', motivation: message.value || null })
  if (e) error.value = e.code === '23505' ? 'Masz już oczekujące zgłoszenie z tą osobą.' : 'Nie udało się wysłać zaproszenia.'
  else sent.value = true
}
</script>

<template>
  <main v-if="a" class="page" :class="{ 'has-bar': isMaster }">
    <header class="ycap pale">
      <div class="top">
        <button class="round" aria-label="Wróć" @click="$router.back()">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3B2716" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 5l-7 7 7 7" /></svg>
        </button>
        <span class="top-title">Profil czeladnika</span>
        <span class="spacer" />
      </div>
      <div class="id">
        <Avatar :name="a.full_name" :size="84" tone="moss" />
        <div class="id-text">
          <h1>{{ a.full_name }}</h1>
          <span class="sub">{{ a.age ? `${a.age} lat · ` : '' }}{{ a.cities?.name }}</span>
          <span v-if="a.crafts" class="seeking">Szuka mistrza: {{ a.crafts.label.toLowerCase() }}</span>
        </div>
      </div>
    </header>

    <div class="page-body body">
      <section v-if="a.bio" class="sec">
        <h2 class="section-title">O mnie</h2>
        <p class="text">{{ a.bio }}</p>
      </section>

      <section class="sec">
        <h2 class="section-title">Czego szukam</h2>
        <dl class="table">
          <div><dt>Rzemiosło</dt><dd>{{ a.crafts?.label || '—' }}</dd></div>
          <div><dt>Forma nauki</dt><dd>{{ a.learning_form || '—' }}</dd></div>
          <div><dt>Dostępność</dt><dd>{{ a.availability || '—' }}</dd></div>
          <div><dt>Dojazd</dt><dd>{{ a.max_distance_km ? `do ${a.max_distance_km} km` : '—' }}</dd></div>
          <div><dt>Cel</dt><dd class="good">{{ a.goal || '—' }}</dd></div>
        </dl>
      </section>

      <section v-if="a.skills.length" class="sec">
        <h2 class="section-title">Co już potrafię</h2>
        <div class="chips"><span v-for="s in a.skills" :key="s" class="dchip">{{ s }}</span></div>
      </section>

      <template v-if="isMaster && inviting && !sent">
        <label class="field">Wiadomość (opcjonalnie) <textarea v-model="message" maxlength="1000" /></label>
        <p v-if="error" class="error">{{ error }}</p>
      </template>
    </div>

    <div v-if="isMaster" class="bar">
      <p v-if="sent" class="done">Zaproszenie wysłane</p>
      <button v-else-if="inviting" class="btn btn-yellow" @click="invite">Wyślij zaproszenie</button>
      <button v-else class="btn btn-yellow" @click="inviting = true">Zaproś do warsztatu</button>
    </div>
  </main>
</template>

<style scoped>
.top { display: flex; align-items: center; justify-content: space-between; }
.top-title { font-weight: 800; font-size: 15px; }
.spacer { width: 48px; }
.id { display: flex; align-items: center; gap: 16px; }
.id-text { display: flex; flex-direction: column; gap: 4px; min-width: 0; }
.id-text h1 { font-size: 28px; line-height: 1.1; }
.sub { font-size: 14px; font-weight: 600; color: var(--soft); }
.seeking { align-self: flex-start; margin-top: 4px; padding: 5px 11px; border-radius: 13px; background: var(--brown); color: var(--cream); font-size: 12px; font-weight: 800; }
.body { padding-top: 20px; }
.sec { display: flex; flex-direction: column; gap: 10px; }
.sec:first-child { gap: 8px; }
.table > div { padding: 12px 16px; }
.text { margin: 0; font-size: 15px; line-height: 1.55; }
.done { flex: 1; margin: 0; min-height: 56px; display: flex; align-items: center; justify-content: center; border-radius: 28px;
  background: var(--sage); color: var(--moss-ink); font-weight: 800; font-size: 16px; }
</style>
