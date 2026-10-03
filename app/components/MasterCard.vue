<script lang="ts">
export type MasterCardData = {
  id: string; full_name: string; title: string | null; craft_label: string | null; city_name: string | null
  distance_km?: number | null; rating_avg?: number | null; accepting: boolean; duration: string | null
}
</script>

<script setup lang="ts">
defineProps<{ m: MasterCardData }>()
</script>

<template>
  <NuxtLink :to="`/mistrz/${m.id}`" class="card row">
    <Avatar :name="m.full_name" />
    <div class="body">
      <div class="top">
        <b>{{ m.full_name }}</b>
        <span v-if="m.rating_avg" class="rating">★ {{ String(m.rating_avg).replace('.', ',') }}</span>
      </div>
      <div class="muted">
        {{ m.title || m.craft_label }} · {{ m.city_name }}<template v-if="m.distance_km != null">, {{ m.distance_km }} km</template>
      </div>
      <div class="row tags">
        <span v-if="m.accepting" class="tag">Przyjmuje uczniów</span>
        <span v-if="m.duration" class="tag yellow">{{ m.duration }}</span>
      </div>
    </div>
  </NuxtLink>
</template>

<style scoped>
.body { flex: 1; min-width: 0; display: grid; gap: 4px; }
.top { display: flex; justify-content: space-between; gap: 8px; }
.rating { font-weight: 800; color: var(--honey); }
.tags { gap: 6px; flex-wrap: wrap; }
</style>
