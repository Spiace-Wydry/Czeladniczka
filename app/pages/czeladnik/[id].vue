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
  <main v-if="a" class="screen">
    <div class="row">
      <button class="back" aria-label="Wróć" @click="$router.back()">←</button>
      <b>Profil czeladnika</b>
    </div>

    <div class="card row head">
      <Avatar :name="a.full_name" :size="72" :dark="false" />
      <div class="stack tight">
        <h1 class="h2">{{ a.full_name }}</h1>
        <span class="muted">{{ a.age ? `${a.age} lat · ` : '' }}{{ a.cities?.name }}</span>
        <span v-if="a.crafts" class="tag yellow">Szuka mistrza: {{ a.crafts.label.toLowerCase() }}</span>
      </div>
    </div>

    <template v-if="a.bio">
      <h2 class="section-title">O mnie</h2>
      <p>{{ a.bio }}</p>
    </template>

    <h2 class="section-title">Czego szukam</h2>
    <dl class="kv card">
      <dt>Rzemiosło</dt><dd>{{ a.crafts?.label || '—' }}</dd>
      <dt>Forma nauki</dt><dd>{{ a.learning_form || '—' }}</dd>
      <dt>Dostępność</dt><dd>{{ a.availability || '—' }}</dd>
      <dt>Dojazd</dt><dd>{{ a.max_distance_km ? `do ${a.max_distance_km} km` : '—' }}</dd>
      <dt>Cel</dt><dd>{{ a.goal || '—' }}</dd>
    </dl>

    <template v-if="a.skills.length">
      <h2 class="section-title">Co już potrafię</h2>
      <div class="chips"><span v-for="s in a.skills" :key="s" class="tag">{{ s }}</span></div>
    </template>

    <div v-if="isMaster" class="stack actions">
      <p v-if="sent" class="tag">Zaproszenie wysłane</p>
      <template v-else-if="inviting">
        <label class="field">Wiadomość (opcjonalnie) <textarea v-model="message" maxlength="1000" /></label>
        <p v-if="error" class="error">{{ error }}</p>
        <button class="btn btn-yellow" @click="invite">Wyślij zaproszenie</button>
      </template>
      <button v-else class="btn btn-yellow" @click="inviting = true">Zaproś do warsztatu</button>
    </div>
  </main>
</template>

<style scoped>
.back { width: 44px; height: 44px; border-radius: 22px; border: 0; background: #fff; font-size: 20px; cursor: pointer; color: var(--brown); }
.head { margin-top: 16px; }
.tight { gap: 4px; }
.actions { margin-top: 24px; }
</style>
