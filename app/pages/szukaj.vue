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
  <main class="screen">
    <h1 class="h1">Cześć, {{ firstName }}!</h1>
    <p class="muted big">{{ isMaster ? 'Kogo szukasz do warsztatu?' : 'Czego chcesz się nauczyć?' }}</p>

    <input v-model.lazy="q" class="search" type="search"
      :placeholder="isMaster ? 'Szukaj czeladnika lub umiejętności' : 'Szukaj rzemiosła lub mistrza'">

    <div class="chips filters">
      <button class="chip" :class="{ on: near }" @click="near = !near">Do 20 km</button>
      <template v-if="!isMaster">
        <button class="chip" :class="{ on: paid }" @click="paid = !paid">Płatna praktyka</button>
        <button class="chip" :class="{ on: now }" @click="now = !now">Od zaraz</button>
      </template>
    </div>

    <div class="row between">
      <h2 class="section-title">Rzemiosła</h2>
      <button v-if="craftId" class="link" @click="craftId = null">Wszystkie</button>
    </div>
    <div class="crafts">
      <button v-for="c in crafts" :key="c.id" class="craft" :class="{ on: craftId === c.id }" @click="pickCraft(c.id)">
        <span class="tile" :style="{ background: c.bg }">
          <svg width="30" height="30" viewBox="0 0 24 24" fill="none" :stroke="c.ink" stroke-width="1.8"
            stroke-linecap="round" stroke-linejoin="round"><path :d="c.icon" /></svg>
        </span>
        {{ c.label }}
      </button>
    </div>

    <h2 class="section-title">{{ isMaster ? 'Czeladnicy w pobliżu' : 'Mistrzowie w pobliżu' }}</h2>
    <p v-if="pending" class="muted">Szukam…</p>
    <div v-else class="stack">
      <template v-if="isMaster">
        <NuxtLink v-for="a in results?.apprentices" :key="a.id" :to="`/czeladnik/${a.id}`" class="card row">
          <Avatar :name="a.full_name" :dark="false" />
          <div class="stack tight">
            <b>{{ a.full_name }}</b>
            <span class="muted">{{ a.age ? `${a.age} lat · ` : '' }}{{ a.city_name }}<template v-if="a.distance_km != null">, {{ a.distance_km }} km</template></span>
            <span v-if="a.craft_label" class="tag yellow">Szuka: {{ a.craft_label }}</span>
          </div>
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
.big { font-size: 16px; margin: 4px 0 16px; }
.search { width: 100%; min-height: 52px; border-radius: 26px; border: 1.5px solid var(--line); background: #fff;
  padding: 0 20px; font: 500 15px Manrope, sans-serif; color: var(--brown); }
.filters { margin-top: 12px; }
.between { justify-content: space-between; }
.link { background: none; border: 0; font: 700 14px Manrope, sans-serif; color: var(--walnut); cursor: pointer; min-height: 44px; }
.crafts { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px 8px; }
.craft { display: grid; justify-items: center; gap: 6px; background: none; border: 0; padding: 0; cursor: pointer;
  font: 700 12px Manrope, sans-serif; color: var(--brown); }
.tile { display: flex; width: 64px; height: 64px; border-radius: 20px; align-items: center; justify-content: center;
  border: 2px solid transparent; }
.craft.on .tile { border-color: var(--brown); }
.tight { gap: 4px; }
</style>
