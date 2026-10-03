<script setup lang="ts">
const { me } = useMe()
</script>

<template>
  <NuxtPage />
  <AppNav v-if="me" />
</template>
