<script setup lang="ts">
const route = useRoute()
const supabase = useSupabaseClient()
const role = computed(() => (route.query.role === 'master' ? 'master' : 'apprentice'))

const { data: cities } = await useAsyncData('cities', async () =>
  (await supabase.from('cities').select('id, name').order('name')).data ?? [])

const form = reactive({ full_name: '', email: '', password: '', city_id: '' })
const error = ref('')
const info = ref('')
const busy = ref(false)

async function submit() {
  busy.value = true
  error.value = ''
  info.value = ''
  const { data, error: e } = await supabase.auth.signUp({
    email: form.email,
    password: form.password,
    options: { data: { role: role.value, full_name: form.full_name, city_id: form.city_id } },
  })
  busy.value = false
  if (e) {
    error.value = e.message.includes('already registered') ? 'Konto z tym adresem już istnieje.' : `Nie udało się założyć konta: ${e.message}`
    return
  }
  if (!data.session) {
    info.value = 'Sprawdź skrzynkę i potwierdź adres email, a potem się zaloguj.'
    return
  }
  await navigateTo('/profil')
}
</script>

<template>
  <main class="screen">
    <form class="stack" @submit.prevent="submit">
      <h1 class="h1">{{ role === 'master' ? 'Konto mistrza' : 'Konto czeladnika' }}</h1>
      <p class="muted">
        {{ role === 'master' ? 'Znajdź ucznia do swojego warsztatu.' : 'Znajdź mistrza, który nauczy Cię fachu.' }}
        <NuxtLink :to="`/signup?role=${role === 'master' ? 'apprentice' : 'master'}`">
          {{ role === 'master' ? 'Szukam mistrza' : 'Jestem mistrzem' }}
        </NuxtLink>
      </p>
      <label class="field">Imię i nazwisko <input v-model="form.full_name" required minlength="2" maxlength="80" autocomplete="name"></label>
      <label class="field">Miejscowość
        <select v-model="form.city_id" required>
          <option value="" disabled>Wybierz</option>
          <option v-for="c in cities" :key="c.id" :value="c.id">{{ c.name }}</option>
        </select>
      </label>
      <label class="field">Email <input v-model="form.email" type="email" required autocomplete="email"></label>
      <label class="field">Hasło <input v-model="form.password" type="password" required minlength="6" autocomplete="new-password"></label>
      <p v-if="error" class="error">{{ error }}</p>
      <p v-if="info" class="tag">{{ info }}</p>
      <button class="btn" :disabled="busy">Załóż konto</button>
      <p>Masz już konto? <NuxtLink to="/login"><b>Zaloguj się</b></NuxtLink></p>
    </form>
  </main>
</template>
