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
  <main v-if="m" class="page" :class="{ 'has-bar': isApprentice && m.accepting }">
    <header class="cover">
      <div class="plank p1" /><div class="plank p2" /><div class="plank p3" />
      <div class="cover-btns">
        <button class="round" aria-label="Wróć" @click="$router.back()">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3B2716" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 5l-7 7 7 7" /></svg>
        </button>
        <button v-if="isApprentice" class="round" :aria-label="saved ? 'Usuń z zapisanych' : 'Zapisz mistrza'" :aria-pressed="saved" @click="toggleSave">
          <svg width="22" height="22" viewBox="0 0 24 24" :fill="saved ? '#F4C542' : 'none'" stroke="#3B2716" stroke-width="2" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h12v18l-6-4-6 4z" /></svg>
        </button>
      </div>
    </header>

    <div class="content">
      <div class="id-row">
        <Avatar :name="m.full_name" :size="96" tone="yellow" class="big-avatar" />
        <span v-if="m.accepting" class="tag">Przyjmuje uczniów</span>
        <span v-else class="tag yellow">Nie przyjmuje uczniów</span>
      </div>
      <div class="names">
        <h1 class="h1">{{ m.full_name }}</h1>
        <p class="sub">{{ m.title || m.crafts?.label }} · {{ m.cities?.name }}</p>
      </div>

      <div class="stats">
        <div><b>{{ rating }}</b><span>ocena</span></div>
        <div><b>{{ m.trained_count ?? 0 }}</b><span>wyszkolonych</span></div>
        <div><b>{{ m.years_in_trade ?? 0 }} lat</b><span>w zawodzie</span></div>
      </div>

      <section v-if="m.skills.length" class="sec">
        <h2 class="section-title">Czego Cię nauczę</h2>
        <div class="chips"><span v-for="s in m.skills" :key="s" class="dchip">{{ s }}</span></div>
      </section>

      <dl class="table">
        <div><dt>Czas praktyki</dt><dd>{{ m.duration || '—' }}</dd></div>
        <div><dt>Grafik</dt><dd>{{ m.schedule || '—' }}</dd></div>
        <div><dt>Na koniec</dt><dd class="good">{{ m.ends_with || '—' }}</dd></div>
      </dl>

      <section v-if="m.bio" class="sec">
        <h2 class="section-title">O mnie</h2>
        <p class="text">{{ m.bio }}</p>
      </section>

      <section class="sec">
        <h2 class="section-title">Opinie ({{ reviews?.length ?? 0 }})</h2>
        <form v-if="canReview && !reviewed" class="card stack" @submit.prevent="sendReview">
          <b>Twoja opinia</b>
          <div class="chips">
            <button v-for="n in 5" :key="n" type="button" class="chip" :class="{ on: review.stars === n }" @click="review.stars = n">{{ n }}★</button>
          </div>
          <label class="field">Komentarz <textarea v-model="review.text" maxlength="1000" placeholder="Jak wyglądała nauka u tego mistrza?" /></label>
          <p v-if="reviewError" class="error">{{ reviewError }}</p>
          <button class="btn">Dodaj opinię</button>
        </form>
        <div v-for="r in reviews" :key="r.apprentice_id" class="card review">
          <div class="review-top"><b>{{ r.apprentice?.full_name }}</b><span class="stars" :aria-label="`${r.stars} na 5`">{{ '★'.repeat(r.stars) }}</span></div>
          <p v-if="r.text" class="text">{{ r.text }}</p>
        </div>
        <p v-if="!reviews?.length" class="muted">Brak opinii.</p>
      </section>
    </div>

    <div v-if="isApprentice && m.accepting" class="bar">
      <NuxtLink :to="`/mistrz/${id}/zgloszenie`" class="btn btn-yellow">Poproś o naukę</NuxtLink>
    </div>
  </main>
</template>

<style scoped>
.cover { height: 200px; background: var(--walnut); position: relative; overflow: hidden; }
.plank { position: absolute; left: -40px; width: calc(100% + 108px); transform: rotate(-6deg); }
.p1 { top: 60px; height: 18px; background: #8E6039; }
.p2 { top: 110px; height: 10px; background: #6A4226; }
.p3 { top: 150px; height: 26px; background: #8E6039; }
.cover-btns { position: absolute; left: 16px; right: 16px; top: 36px; display: flex; justify-content: space-between; }
.content { padding: 0 20px; margin-top: -48px; position: relative; display: flex; flex-direction: column; gap: 16px; }
.id-row { display: flex; align-items: flex-end; gap: 14px; }
.id-row .tag { margin-bottom: 8px; align-self: auto; }
.big-avatar { box-sizing: content-box; border: 4px solid var(--cream); }
.names { display: flex; flex-direction: column; gap: 4px; }
.sub { margin: 0; font-size: 15px; color: var(--soft); font-weight: 600; }
.stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px; }
.stats div { padding: 12px; border-radius: 16px; background: var(--light); display: flex; flex-direction: column; gap: 2px; }
.stats b { font: 700 22px 'Zilla Slab', Georgia, serif; }
.stats span { font-size: 12px; font-weight: 600; color: var(--soft); }
.sec { display: flex; flex-direction: column; gap: 10px; }
.text { margin: 0; font-size: 15px; line-height: 1.55; }
.review { display: flex; flex-direction: column; gap: 4px; }
.review-top { display: flex; justify-content: space-between; gap: 8px; }
.stars { color: var(--honey); }
</style>
