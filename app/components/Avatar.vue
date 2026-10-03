<script setup lang="ts">
const TONES = {
  walnut: ['var(--walnut)', 'var(--cream)'],
  moss: ['var(--moss)', 'var(--cream)'],
  yellow: ['var(--yellow)', 'var(--brown)'],
} as const
const props = withDefaults(defineProps<{ name: string; size?: number; dark?: boolean; tone?: keyof typeof TONES }>(), { size: 56, dark: true })
const initials = computed(() => props.name.split(/\s+/).map((w) => w[0]).slice(0, 2).join('').toUpperCase())
const colors = computed(() => TONES[props.tone ?? (props.dark ? 'walnut' : 'yellow')])
</script>

<template>
  <span
    class="avatar"
    :style="{ width: `${size}px`, height: `${size}px`, fontSize: `${Math.round(size * 0.38)}px`,
      borderRadius: `${Math.round(size * 0.31)}px`, background: colors[0], color: colors[1] }"
  >{{ initials }}</span>
</template>

<style scoped>
.avatar { display: inline-flex; flex: none; align-items: center; justify-content: center;
  font-family: 'Zilla Slab', Georgia, serif; font-weight: 700; }
</style>
