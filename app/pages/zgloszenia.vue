<script setup lang="ts">
const supabase = useSupabaseClient()
const { me } = useMe()
const isMaster = computed(() => me.value?.role === 'master')

const { data: rows, refresh } = await useAsyncData('requests', async () =>
  (await supabase.from('requests')
    .select('id, kind, status, level, start, motivation, exam_prep, created_at, apprentice:profiles!apprentice_id(id, full_name), master:profiles!master_id(id, full_name)')
    .order('created_at', { ascending: false })).data ?? [])

type Row = NonNullable<typeof rows.value>[number]
// Received = someone else initiated it towards me
const isReceived = (r: Row) => (r.kind === 'application') === isMaster.value
const other = (r: Row) => (isMaster.value ? r.apprentice : r.master)
const otherLink = (r: Row) => (isMaster.value ? `/czeladnik/${r.apprentice?.id}` : `/mistrz/${r.master?.id}`)
const received = computed(() => rows.value?.filter(isReceived) ?? [])
const sent = computed(() => rows.value?.filter((r) => !isReceived(r)) ?? [])

const STATUS: Record<string, string> = { pending: 'Oczekuje', accepted: 'Przyjęte', declined: 'Odrzucone' }
const LEVEL: Record<string, string> = { zero: 'Zaczynam od zera', hobby: 'Hobbystycznie', szkola: 'Szkoła zawodowa' }
const START: Record<string, string> = { zaraz: 'Od zaraz', miesiac: 'Za miesiąc', wakacje: 'W wakacje' }

const error = ref('')
async function answer(id: number, status: 'accepted' | 'declined') {
  error.value = ''
  const { error: e } = await supabase.from('requests').update({ status }).eq('id', id)
  if (e) error.value = 'Nie udało się zapisać odpowiedzi.'
  await refresh()
}
</script>

<template>
  <main class="screen">
    <h1 class="h1">Zgłoszenia</h1>
    <p v-if="error" class="error">{{ error }}</p>

    <template v-for="group in [{ title: 'Otrzymane', list: received }, { title: 'Wysłane', list: sent }]" :key="group.title">
      <h2 class="section-title">{{ group.title }}</h2>
      <div class="stack">
        <div v-for="r in group.list" :key="r.id" class="card stack tight">
          <div class="row between">
            <NuxtLink :to="otherLink(r)" class="row who">
              <Avatar :name="other(r)?.full_name ?? '?'" :size="40" />
              <b>{{ other(r)?.full_name }}</b>
            </NuxtLink>
            <span class="tag" :class="{ yellow: r.status === 'pending' }">{{ STATUS[r.status] }}</span>
          </div>
          <span class="muted">
            {{ r.kind === 'invite' ? 'Zaproszenie do warsztatu' : 'Prośba o naukę' }} · {{ new Date(r.created_at).toLocaleDateString('pl-PL') }}
          </span>
          <span v-if="r.kind === 'application'" class="muted">
            {{ r.level ? LEVEL[r.level] : '' }} · {{ r.start ? START[r.start] : '' }}<template v-if="r.exam_prep"> · egzamin czeladniczy</template>
          </span>
          <p v-if="r.motivation" class="text">{{ r.motivation }}</p>
          <div v-if="isReceived(r) && r.status === 'pending'" class="row">
            <button class="btn" @click="answer(r.id, 'accepted')">Przyjmij</button>
            <button class="btn btn-outline" @click="answer(r.id, 'declined')">Odrzuć</button>
          </div>
        </div>
        <p v-if="!group.list.length" class="muted">Brak.</p>
      </div>
    </template>
  </main>
</template>

<style scoped>
.between { justify-content: space-between; }
.tight { gap: 6px; }
.who { text-decoration: none; gap: 10px; }
.text { margin: 0; }
</style>
