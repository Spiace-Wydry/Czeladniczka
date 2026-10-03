<script setup lang="ts">
const { me } = useMe()
const route = useRoute()
// Profile/application screens have their own back button and bottom action bar (as on the boards)
const showNav = computed(() => me.value && !/^\/(mistrz|czeladnik)\//.test(route.path))
</script>

<template>
  <NuxtPage />
  <AppNav v-if="showNav" />
</template>
