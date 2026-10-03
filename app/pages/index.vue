<template>
  <main class="screen welcome">
    <div class="stack hero">
      <h1 class="h1 big">Czeladniczka</h1>
      <p class="lead">Znajdź mistrza, który nauczy Cię fachu.</p>
      <ul class="points">
        <li>Praktyka u doświadczonych rzemieślników</li>
        <li>Warsztaty w Twojej okolicy</li>
        <li>Droga do egzaminu czeladniczego</li>
        <li>Praktyki zawodowe</li>
      </ul>
    </div>
    <div class="stack">
      <NuxtLink to="/signup?role=apprentice" class="btn">Szukam mistrza</NuxtLink>
      <NuxtLink to="/signup?role=master" class="btn btn-outline">Jestem mistrzem — szukam ucznia</NuxtLink>
      <p class="login">Masz już konto? <NuxtLink to="/login"><b>Zaloguj się</b></NuxtLink></p>
    </div>
  </main>
</template>

<style scoped>
.welcome { display: flex; flex-direction: column; justify-content: space-between; background: #FBE7A1; padding-bottom: 32px; }
.hero { margin-top: 48px; }
.big { font-size: 42px; }
.lead { font-size: 18px; font-weight: 600; margin: 0; }
.points { list-style: none; padding: 0; margin: 16px 0 0; display: grid; gap: 10px; }
.points li { background: rgba(255,255,255,.6); border-radius: 18px; padding: 14px 16px; font-weight: 700; }
.login { text-align: center; margin: 4px 0 0; }
</style>
