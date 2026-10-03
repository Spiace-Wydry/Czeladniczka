<script setup lang="ts">
defineProps<{ error: { statusCode: number } }>()
</script>

<template>
  <main class="screen stack">
    <h1 class="h1">{{ error.statusCode === 404 ? 'Nie znaleziono strony' : 'Coś poszło nie tak' }}</h1>
    <button class="btn" @click="clearError({ redirect: '/' })">Wróć na start</button>
  </main>
</template>
