export default defineNuxtConfig({
  compatibilityDate: '2026-10-01',
  ssr: false,
  modules: ['@nuxtjs/supabase'],
  css: ['~/assets/main.css'],
  supabase: {
    redirect: false,
    types: '~/types/database.types.ts',
  },
  // Phone testing over LAN (`npm run dev:lan`): the page must be HTTPS (secure context for
  // Supabase auth), so Supabase is reached same-origin through this proxy, not over plain http.
  $development: {
    routeRules: { '/supabase/**': { proxy: 'http://127.0.0.1:54521/**' } },
  },
  app: {
    head: {
      htmlAttrs: { lang: 'pl' },
      title: 'Czeladniczka',
      meta: [{ name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover' }],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Manrope:wght@500;600;700;800&family=Zilla+Slab:wght@700&display=swap' },
      ],
    },
  },
})
