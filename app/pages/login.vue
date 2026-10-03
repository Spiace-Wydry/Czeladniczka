<script setup lang="ts">
const supabase = useSupabaseClient()
const form = reactive({ email: '', password: '' })
const error = ref('')
const busy = ref(false)

async function submit() {
  busy.value = true
  error.value = ''
  const { error: e } = await supabase.auth.signInWithPassword(form)
  busy.value = false
  if (e) {
    error.value = e.message.includes('Invalid login') ? 'Nieprawidłowy email lub hasło.' : e.message
    return
  }
  await navigateTo('/szukaj')
}
</script>

<template>
  <main class="page">
    <header class="ycap">
      <NuxtLink to="/" class="round" aria-label="Wróć">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3B2716" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 5l-7 7 7 7" /></svg>
      </NuxtLink>
      <div class="titles">
        <span class="kicker">Czeladniczka</span>
        <h1 class="h1">Zaloguj się</h1>
      </div>
    </header>
    <form class="page-body" @submit.prevent="submit">
      <label class="field">Email <input v-model="form.email" type="email" required autocomplete="email" placeholder="np. jan.kowalski@gmail.com"></label>
      <label class="field">Hasło <input v-model="form.password" type="password" required autocomplete="current-password" placeholder="Twoje hasło"></label>
      <p v-if="error" class="error">{{ error }}</p>
      <button class="btn" :disabled="busy">Zaloguj się</button>
      <p class="alt">Nie masz konta? <NuxtLink to="/signup">Załóż konto</NuxtLink></p>
    </form>
  </main>
</template>

<style scoped>
.titles { display: flex; flex-direction: column; gap: 2px; }
.alt { margin: 0; text-align: center; font-size: 14px; }
.alt a { font-weight: 700; }
</style>
