<script setup lang="ts">
defineProps<{ error: { statusCode: number } }>()
</script>

<template>
  <main class="page">
    <header class="ycap">
      <span class="kicker">Czeladniczka</span>
      <h1 class="h1">{{ error.statusCode === 404 ? 'Nie znaleziono strony' : 'Coś poszło nie tak' }}</h1>
    </header>
    <div class="page-body">
      <button class="btn" @click="clearError({ redirect: '/' })">Wróć na start</button>
    </div>
  </main>
</template>

<style scoped>
.ycap { gap: 2px; }
</style>
