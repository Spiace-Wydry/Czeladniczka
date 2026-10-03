<script setup lang="ts">
const { me } = useMe()
const items = computed(() => [
  { to: '/szukaj', label: 'Szukaj', icon: 'M4 11a7 7 0 1 0 14 0a7 7 0 1 0-14 0M20 20l-4-4' },
  ...(me.value?.role === 'apprentice'
    ? [{ to: '/zapisane', label: 'Zapisane', icon: 'M6 3h12v18l-6-4-6 4z' }]
    : []),
  { to: '/zgloszenia', label: 'Zgłoszenia', icon: 'M4 5h16v11H9l-5 4z' },
  { to: '/profil', label: 'Profil', icon: 'M8 8a4 4 0 1 0 8 0a4 4 0 1 0-8 0M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6' },
])
</script>

<template>
  <nav class="nav" aria-label="Nawigacja główna" :style="{ gridTemplateColumns: `repeat(${items.length}, minmax(0, 1fr))` }">
    <NuxtLink v-for="i in items" :key="i.to" :to="i.to" class="item" active-class="active">
      <span class="pill">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
          stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path :d="i.icon" /></svg>
      </span>
      {{ i.label }}
    </NuxtLink>
  </nav>
</template>

<style scoped>
.nav { position: fixed; bottom: 0; left: 50%; transform: translateX(-50%); width: 100%; max-width: 480px; z-index: 10;
  display: grid; align-items: center; height: calc(80px + env(safe-area-inset-bottom)); padding-bottom: env(safe-area-inset-bottom);
  background: var(--light); border-top: 1px solid var(--line); }
.item { display: flex; flex-direction: column; align-items: center; gap: 4px; min-height: 56px; justify-content: center;
  font-size: 12px; font-weight: 600; text-decoration: none; color: var(--soft); }
.pill { display: flex; width: 64px; height: 32px; border-radius: 16px; align-items: center; justify-content: center; }
.item.active { color: var(--brown); font-weight: 800; }
.item.active .pill { background: var(--yellow); }
</style>
