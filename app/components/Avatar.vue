<script setup lang="ts">
const props = withDefaults(defineProps<{ name: string; size?: number; dark?: boolean }>(), { size: 56, dark: true })
const initials = computed(() => props.name.split(/\s+/).map((w) => w[0]).slice(0, 2).join('').toUpperCase())
</script>

<template>
  <span
    class="avatar"
    :style="{ width: `${size}px`, height: `${size}px`, fontSize: `${size * 0.36}px`,
      background: dark ? 'var(--walnut)' : 'var(--yellow)', color: dark ? 'var(--cream)' : 'var(--brown)' }"
  >{{ initials }}</span>
</template>

<style scoped>
.avatar { display: inline-flex; flex: none; align-items: center; justify-content: center; border-radius: 50%;
  font-family: 'Zilla Slab', Georgia, serif; font-weight: 700; }
</style>
