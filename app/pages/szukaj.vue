<script setup lang="ts">
const { me } = useMe()
const supabase = useSupabaseClient()
const isMaster = computed(() => me.value?.role === 'master')
const firstName = computed(() => me.value?.full_name.split(' ')[0])

const q = ref('')
const craftId = ref<number | null>(null)
const near = ref(false)
const paid = ref(false)
const now = ref(false)

const { data: crafts } = await useAsyncData('crafts', async () =>
  (await supabase.from('crafts').select('*').order('id')).data ?? [])

const { data: results, pending } = await useAsyncData('search', async () => {
  const common = { q: q.value.trim() || undefined, p_craft_id: craftId.value ?? undefined, max_km: near.value ? 20 : undefined }
  if (isMaster.value) return { apprentices: (await supabase.rpc('search_apprentices', common)).data ?? [], masters: [] }
  return {
    masters: (await supabase.rpc('search_masters', { ...common, p_paid: paid.value, p_available_now: now.value })).data ?? [],
    apprentices: [],
  }
}, { watch: [q, craftId, near, paid, now] })

const pickCraft = (id: number) => (craftId.value = craftId.value === id ? null : id)
</script>

<template>
  <main class="page">
    <header class="ycap">
      <div class="hello">
        <div class="titles">
          <span class="kicker">Cześć, {{ firstName }}!</span>
          <h1 class="h1">
            <template v-if="isMaster">Kogo szukasz<br>do warsztatu?</template>
            <template v-else>Czego chcesz<br>się nauczyć?</template>
          </h1>
        </div>
        <NuxtLink to="/zgloszenia" class="round dark" aria-label="Powiadomienia">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#F4C542" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 9a6 6 0 0 1 12 0c0 6 2.5 7.5 2.5 7.5h-17S6 15 6 9z" /><path d="M10 20a2 2 0 0 0 4 0" /></svg>
        </NuxtLink>
      </div>
      <div class="search-wrap">
        <label for="szukaj" class="search-label">{{ isMaster ? 'Szukaj czeladnika lub umiejętności' : 'Szukaj rzemiosła lub mistrza' }}</label>
        <div class="search">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6B5440" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" /></svg>
          <input id="szukaj" v-model.lazy="q" type="search" placeholder="np. stolarstwo, kowalstwo…">
        </div>
      </div>
      <div class="filters">
        <button class="fchip" :class="{ on: near }" @click="near = !near">Do 20 km</button>
        <template v-if="!isMaster">
          <button class="fchip" :class="{ on: paid }" @click="paid = !paid">Płatna praktyka</button>
          <button class="fchip" :class="{ on: now }" @click="now = !now">Od zaraz</button>
        </template>
      </div>
    </header>

    <div class="page-body">
      <div class="head">
        <h2>Rzemiosła</h2>
        <button class="all" @click="craftId = null">Wszystkie</button>
      </div>
      <div class="crafts">
        <button v-for="c in crafts" :key="c.id" class="craft" :class="{ on: craftId === c.id }" :aria-pressed="craftId === c.id" @click="pickCraft(c.id)">
          <span class="tile" :style="{ background: c.bg }">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" :stroke="c.ink" stroke-width="1.9"
              stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path :d="c.icon" /></svg>
          </span>
          <span class="clabel">{{ c.label }}</span>
        </button>
      </div>

      <div class="head near-head">
        <h2>{{ isMaster ? 'Czeladnicy w pobliżu' : 'Mistrzowie w pobliżu' }}</h2>
      </div>
      <p v-if="pending" class="muted">Szukam…</p>
      <template v-else-if="isMaster">
        <NuxtLink v-for="a in results?.apprentices" :key="a.id" :to="`/czeladnik/${a.id}`" class="lcard">
          <Avatar :name="a.full_name" tone="moss" />
          <span class="body">
            <span class="name">{{ a.full_name }}</span>
            <span class="meta">{{ a.age ? `${a.age} lat · ` : '' }}{{ a.city_name }}<template v-if="a.distance_km != null">, {{ a.distance_km }} km</template></span>
            <span v-if="a.craft_label" class="tags"><span class="tag yellow">Szuka: {{ a.craft_label.toLowerCase() }}</span></span>
          </span>
        </NuxtLink>
        <p v-if="!results?.apprentices.length" class="muted">Brak czeladników dla tych filtrów.</p>
      </template>
      <template v-else>
        <MasterCard v-for="m in results?.masters" :key="m.id" :m="m" />
        <p v-if="!results?.masters.length" class="muted">Brak mistrzów dla tych filtrów.</p>
      </template>
    </div>
  </main>
</template>

<style scoped>
.hello { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.titles { display: flex; flex-direction: column; gap: 2px; }
.search-wrap { display: flex; flex-direction: column; gap: 6px; }
.search-label { font-size: 13px; font-weight: 700; }
.search { display: flex; align-items: center; gap: 10px; height: 54px; padding: 0 16px; border-radius: 27px; background: var(--cream); }
.search input { flex: 1; min-width: 0; height: 100%; border: 0; background: transparent; font: inherit; font-size: 15px; color: var(--brown); outline: none; }
.search:focus-within { box-shadow: 0 0 0 2px var(--brown); }
.filters { display: flex; gap: 8px; flex-wrap: wrap; }
/* 36px visual chip as on the board; ::after extends the hit area to 44px */
.fchip { position: relative; height: 36px; padding: 0 14px; border-radius: 18px; font: 700 13px Manrope, sans-serif; cursor: pointer;
  background: transparent; color: var(--brown); border: 1.5px solid var(--brown); }
.fchip::after { content: ''; position: absolute; inset: -5px 0; }
.fchip.on { background: var(--brown); color: var(--cream); }
.page-body { gap: 14px; }
.head { display: flex; align-items: baseline; justify-content: space-between; }
.head h2 { font-size: 22px; }
.near-head { margin-top: 6px; }
.all { min-height: 44px; margin: -12px 0; padding: 0; border: 0; background: none; cursor: pointer; font: 700 14px Manrope, sans-serif;
  color: var(--moss); text-decoration: underline; }
.crafts { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; }
.craft { display: flex; flex-direction: column; align-items: center; gap: 6px; padding: 0; border: 0; background: transparent;
  cursor: pointer; font: inherit; color: var(--brown); }
.tile { display: flex; width: 64px; height: 64px; border-radius: 20px; align-items: center; justify-content: center; }
.craft.on .tile { box-shadow: inset 0 0 0 2px var(--brown); }
.clabel { font-size: 12px; font-weight: 600; }
.craft.on .clabel { font-weight: 800; }
</style>
