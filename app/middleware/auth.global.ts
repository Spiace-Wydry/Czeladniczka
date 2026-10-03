const PUBLIC = ['/', '/login', '/signup']

export default defineNuxtRouteMiddleware(async (to) => {
  const supabase = useSupabaseClient()
  const { data: { session } } = await supabase.auth.getSession()

  if (!session) return PUBLIC.includes(to.path) ? undefined : navigateTo('/login')

  const me = await useMe().load(session.user.id)
  if (!me) {
    await supabase.auth.signOut()
    return navigateTo('/login')
  }
  if (PUBLIC.includes(to.path)) return navigateTo('/szukaj')

  const apprenticeOnly = to.path === '/zapisane' || to.path.endsWith('/zgloszenie')
  if (apprenticeOnly && me.role !== 'apprentice') return navigateTo('/szukaj')
})
