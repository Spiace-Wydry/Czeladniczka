<script setup lang="ts">
const route = useRoute()
const id = route.params.id as string
const supabase = useSupabaseClient()
const { me } = useMe()
const isApprentice = computed(() => me.value?.role === 'apprentice')

const { data: m } = await useAsyncData(`master-${id}`, async () =>
  (await supabase.from('profiles').select('*, crafts(label), cities(name)').eq('id', id).eq('role', 'master').maybeSingle()).data)
if (!m.value) throw createError({ statusCode: 404, fatal: true })

const { data: reviews, refresh: refreshReviews } = await useAsyncData(`reviews-${id}`, async () =>
  (await supabase.from('reviews').select('stars, text, created_at, apprentice_id, apprentice:profiles!apprentice_id(full_name)')
    .eq('master_id', id).order('created_at', { ascending: false })).data ?? [])

const rating = computed(() => {
  const r = reviews.value ?? []
  return r.length ? (r.reduce((s, x) => s + x.stars, 0) / r.length).toFixed(1).replace('.', ',') : '—'
})

// Apprentice-only state: saved + review eligibility
const saved = ref(false)
const canReview = ref(false)
if (isApprentice.value) {
  const [{ data: s }, { data: acc }] = await Promise.all([
    supabase.from('saved_masters').select('master_id').eq('apprentice_id', me.value!.id).eq('master_id', id).maybeSingle(),
    supabase.from('requests').select('id').eq('apprentice_id', me.value!.id).eq('master_id', id).eq('status', 'accepted').limit(1),
  ])
  saved.value = !!s
  canReview.value = !!acc?.length
}
const reviewed = computed(() => reviews.value?.some((r) => r.apprentice_id === me.value?.id))

async function toggleSave() {
  const row = { apprentice_id: me.value!.id, master_id: id }
  const { error } = saved.value
    ? await supabase.from('saved_masters').delete().match(row)
    : await supabase.from('saved_masters').insert(row)
  if (!error) saved.value = !saved.value
}

const review = reactive({ stars: 5, text: '' })
const reviewError = ref('')
async function sendReview() {
  reviewError.value = ''
  const { error } = await supabase.from('reviews').insert({ apprentice_id: me.value!.id, master_id: id, ...review })
  if (error) reviewError.value = 'Nie udało się dodać opinii.'
  else await refreshReviews()
}
</script>

<template>
  <main v-if="m" class="screen">
    <div class="row between">
      <button class="back" aria-label="Wróć" @click="$router.back()">←</button>
      <button v-if="isApprentice" class="back" :aria-label="saved ? 'Usuń z zapisanych' : 'Zapisz'" @click="toggleSave">
        <svg width="24" height="24" viewBox="0 0 24 24" :fill="saved ? '#F4C542' : 'none'" stroke="currentColor" stroke-width="2"
          stroke-linejoin="round"><path d="M6 3h12v18l-6-4-6 4z" /></svg>
      </button>
    </div>

    <div class="hero stack">
      <Avatar :name="m.full_name" :size="96" />
      <span v-if="m.accepting" class="tag">Przyjmuje uczniów</span>
      <h1 class="h1">{{ m.full_name }}</h1>
      <p class="muted">{{ m.title || m.crafts?.label }} · {{ m.cities?.name }}</p>
    </div>

    <div class="stats">
      <div class="card"><b>{{ rating }}</b><span class="muted">ocena</span></div>
      <div class="card"><b>{{ m.trained_count ?? 0 }}</b><span class="muted">wyszkolonych</span></div>
      <div class="card"><b>{{ m.years_in_trade ?? 0 }} lat</b><span class="muted">w zawodzie</span></div>
    </div>

    <p v-if="m.bio">{{ m.bio }}</p>

    <template v-if="m.skills.length">
      <h2 class="section-title">Czego Cię nauczę</h2>
      <div class="chips"><span v-for="s in m.skills" :key="s" class="tag yellow">{{ s }}</span></div>
    </template>

    <dl class="kv card terms">
      <dt>Czas praktyki</dt><dd>{{ m.duration || '—' }}</dd>
      <dt>Grafik</dt><dd>{{ m.schedule || '—' }}</dd>
      <dt>Na koniec</dt><dd>{{ m.ends_with || '—' }}</dd>
    </dl>

    <NuxtLink v-if="isApprentice && m.accepting" :to="`/mistrz/${id}/zgloszenie`" class="btn btn-yellow">Poproś o naukę</NuxtLink>

    <h2 class="section-title">Opinie ({{ reviews?.length ?? 0 }})</h2>
    <form v-if="canReview && !reviewed" class="card stack" @submit.prevent="sendReview">
      <b>Twoja opinia</b>
      <div class="chips">
        <button v-for="n in 5" :key="n" type="button" class="chip" :class="{ on: review.stars === n }" @click="review.stars = n">{{ n }}★</button>
      </div>
      <label class="field">Komentarz <textarea v-model="review.text" maxlength="1000" /></label>
      <p v-if="reviewError" class="error">{{ reviewError }}</p>
      <button class="btn">Dodaj opinię</button>
    </form>
    <div class="stack">
      <div v-for="r in reviews" :key="r.apprentice_id" class="card stack tight">
        <div class="row between"><b>{{ r.apprentice?.full_name }}</b><span class="stars">{{ '★'.repeat(r.stars) }}</span></div>
        <p v-if="r.text" class="text">{{ r.text }}</p>
      </div>
      <p v-if="!reviews?.length" class="muted">Brak opinii.</p>
    </div>
  </main>
</template>

<style scoped>
.between { justify-content: space-between; }
.back { width: 44px; height: 44px; border-radius: 22px; border: 0; background: #fff; font-size: 20px; cursor: pointer; color: var(--brown);
  display: inline-flex; align-items: center; justify-content: center; }
.hero { justify-items: center; text-align: center; gap: 8px; margin: 8px 0 20px; }
.stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-bottom: 16px; }
.stats .card { display: grid; justify-items: center; padding: 12px 8px; }
.stats b { font: 700 22px 'Zilla Slab', Georgia, serif; }
.terms { margin: 20px 0; }
.stars { color: var(--honey); }
.tight { gap: 4px; }
.text { margin: 0; }
</style>
