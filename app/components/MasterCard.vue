<script lang="ts">
export type MasterCardData = {
  id: string; full_name: string; title: string | null; craft_label: string | null; city_name: string | null
  distance_km?: number | null; rating_avg?: number | null; accepting: boolean; duration: string | null
}
</script>

<script setup lang="ts">
const props = defineProps<{ m: MasterCardData }>()
// Stable per-master tile colour, alternating walnut/moss as on the board
const tone = computed(() => (parseInt(props.m.id.slice(-1), 16) % 2 ? 'walnut' : 'moss'))
</script>

<template>
  <NuxtLink :to="`/mistrz/${m.id}`" class="lcard">
    <Avatar :name="m.full_name" :tone="tone" />
    <span class="body">
      <span class="top">
        <span class="name">{{ m.full_name }}</span>
        <span v-if="m.rating_avg" class="rating">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="#E0A422" stroke="#B37E12" stroke-width="1.5" stroke-linejoin="round" aria-hidden="true"><path d="M12 3l2.7 5.6 6.1.8-4.5 4.2 1.1 6.1L12 16.8 6.6 19.7l1.1-6.1L3.2 9.4l6.1-.8z" /></svg>{{ Number(m.rating_avg).toFixed(1).replace('.', ',') }}
        </span>
      </span>
      <span class="meta">{{ m.title || m.craft_label }} · {{ m.city_name }}<template v-if="m.distance_km != null">, {{ m.distance_km }} km</template></span>
      <span v-if="m.accepting || m.duration" class="tags">
        <span v-if="m.accepting" class="tag">Przyjmuje uczniów</span>
        <span v-if="m.duration" class="tag yellow">{{ m.duration }}</span>
      </span>
    </span>
  </NuxtLink>
</template>
