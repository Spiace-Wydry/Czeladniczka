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
  <main class="screen">
    <form class="stack" @submit.prevent="submit">
      <h1 class="h1">Zaloguj się</h1>
      <label class="field">Email <input v-model="form.email" type="email" required autocomplete="email"></label>
      <label class="field">Hasło <input v-model="form.password" type="password" required autocomplete="current-password"></label>
      <p v-if="error" class="error">{{ error }}</p>
      <button class="btn" :disabled="busy">Zaloguj się</button>
      <p>Nie masz konta? <NuxtLink to="/signup"><b>Załóż konto</b></NuxtLink></p>
    </form>
  </main>
</template>
