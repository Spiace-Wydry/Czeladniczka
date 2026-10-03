<script setup lang="ts">
import type { MasterCardData } from '~/components/MasterCard.vue'

const supabase = useSupabaseClient()
const { me } = useMe()

const { data: masters } = await useAsyncData('saved', async () => {
  const { data } = await supabase.from('saved_masters')
    .select('master:profiles!master_id(id, full_name, title, accepting, duration, crafts(label), cities(name))')
    .eq('apprentice_id', me.value!.id).order('created_at', { ascending: false })
  return (data ?? []).flatMap(({ master: m }): MasterCardData[] => m ? [{
    id: m.id, full_name: m.full_name, title: m.title, accepting: m.accepting, duration: m.duration,
    craft_label: m.crafts?.label ?? null, city_name: m.cities?.name ?? null,
  }] : [])
})
</script>

<template>
  <main class="screen">
    <h1 class="h1">Zapisane</h1>
    <div class="stack list">
      <MasterCard v-for="m in masters" :key="m.id" :m="m" />
      <p v-if="!masters?.length" class="muted">Nie masz jeszcze zapisanych mistrzów. Użyj zakładki na profilu mistrza.</p>
    </div>
  </main>
</template>

<style scoped>
.list { margin-top: 16px; }
</style>
