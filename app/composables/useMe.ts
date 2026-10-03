import type { Tables } from '~/types/database.types'

export type Profile = Tables<'profiles'>

export const useMe = () => {
  const me = useState<Profile | null>('me', () => null)
  const supabase = useSupabaseClient()

  async function load(id: string) {
    if (me.value?.id === id) return me.value
    const { data } = await supabase.from('profiles').select('*').eq('id', id).maybeSingle()
    me.value = data
    return data
  }

  async function logout() {
    await supabase.auth.signOut()
    me.value = null
    await navigateTo('/')
  }

  return { me, load, logout }
}
