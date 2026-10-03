<script setup lang="ts">
const { me } = useMe()
const items = computed(() => [
  { to: '/szukaj', label: 'Szukaj', icon: 'M11 4a7 7 0 1 0 0 14a7 7 0 1 0 0-14M20 20l-4-4' },
  ...(me.value?.role === 'apprentice'
    ? [{ to: '/zapisane', label: 'Zapisane', icon: 'M6 3h12v18l-6-4-6 4z' }]
    : []),
  { to: '/zgloszenia', label: 'Zgłoszenia', icon: 'M4 5h16v11H8l-4 4z' },
  { to: '/profil', label: 'Profil', icon: 'M12 4a4 4 0 1 0 0 8a4 4 0 1 0 0-8M4 21c1-4 4-6 8-6s7 2 8 6' },
])
</script>

<template>
  <nav class="nav">
    <NuxtLink v-for="i in items" :key="i.to" :to="i.to" class="item" active-class="active">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
        stroke-linecap="round" stroke-linejoin="round"><path :d="i.icon" /></svg>
      {{ i.label }}
    </NuxtLink>
  </nav>
</template>

<style scoped>
.nav { position: fixed; bottom: 0; left: 50%; transform: translateX(-50%); width: 100%; max-width: 480px;
  display: flex; justify-content: space-around; background: #fff; border-top: 1px solid var(--line);
  padding: 8px 8px calc(8px + env(safe-area-inset-bottom)); }
.item { display: grid; justify-items: center; gap: 2px; min-width: 64px; min-height: 48px; padding: 4px 8px;
  border-radius: 16px; font-size: 12px; font-weight: 700; text-decoration: none; color: var(--walnut); }
.item.active { color: var(--brown); background: var(--light); }
</style>
