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
  <main class="page">
    <header class="ycap"><h1 class="h1">Zgłoszenia</h1></header>
    <div class="page-body">
      <p v-if="error" class="error">{{ error }}</p>

      <section v-for="group in [{ title: 'Otrzymane', list: received }, { title: 'Wysłane', list: sent }]" :key="group.title" class="sec">
        <h2 class="section-title">{{ group.title }}</h2>
        <div v-for="r in group.list" :key="r.id" class="card req">
          <div class="req-top">
            <NuxtLink :to="otherLink(r)" class="who">
              <Avatar :name="other(r)?.full_name ?? '?'" :size="48" :tone="isMaster ? 'moss' : 'walnut'" />
              <span class="who-text">
                <b>{{ other(r)?.full_name }}</b>
                <span class="muted">{{ r.kind === 'invite' ? 'Zaproszenie do warsztatu' : 'Prośba o naukę' }} · {{ new Date(r.created_at).toLocaleDateString('pl-PL') }}</span>
              </span>
            </NuxtLink>
            <span class="tag" :class="{ yellow: r.status === 'pending', no: r.status === 'declined' }">{{ STATUS[r.status] }}</span>
          </div>
          <div v-if="r.kind === 'application'" class="chips">
            <span v-if="r.level" class="dchip">{{ LEVEL[r.level] }}</span>
            <span v-if="r.start" class="dchip">{{ START[r.start] }}</span>
            <span v-if="r.exam_prep" class="dchip">Egzamin czeladniczy</span>
          </div>
          <p v-if="r.motivation" class="text">{{ r.motivation }}</p>
          <div v-if="isReceived(r) && r.status === 'pending'" class="actions">
            <button class="btn" @click="answer(r.id, 'accepted')">Przyjmij</button>
            <button class="btn btn-outline" @click="answer(r.id, 'declined')">Odrzuć</button>
          </div>
        </div>
        <p v-if="!group.list.length" class="muted">Brak.</p>
      </section>
    </div>
  </main>
</template>

<style scoped>
.sec { display: flex; flex-direction: column; gap: 10px; }
.req { display: flex; flex-direction: column; gap: 12px; }
.req-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; }
.who { display: flex; align-items: center; gap: 12px; min-width: 0; text-decoration: none; }
.who-text { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
.who-text b { font-weight: 800; font-size: 16px; }
.who-text .muted { font-size: 13px; }
.tag { flex: none; }
.tag.no { background: var(--line-soft); color: var(--soft); }
.text { margin: 0; font-size: 15px; line-height: 1.55; }
.actions { display: flex; gap: 10px; }
</style>
