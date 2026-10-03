<script setup lang="ts">
const points = [
  'Praktyka u doświadczonych rzemieślników',
  'Warsztaty w Twojej okolicy',
  'Droga do egzaminu czeladniczego',
  'Praktyki zawodowe',
]
</script>

<template>
  <main class="welcome">
    <svg class="planks" viewBox="0 0 412 318" preserveAspectRatio="none" aria-hidden="true">
      <rect x="0" y="0" width="412" height="70" fill="#B9824F" />
      <rect x="0" y="70" width="412" height="70" fill="#A87444" />
      <rect x="0" y="140" width="412" height="70" fill="#C08A55" />
      <rect x="0" y="210" width="412" height="70" fill="#AD7846" />
      <g fill="none" stroke="#7A4E2D" stroke-width="1.4" stroke-linecap="round" opacity="0.45">
        <path d="M0 18 C80 12 140 28 220 19 S360 10 412 21" />
        <path d="M0 46 C100 52 170 36 260 45 S380 54 412 47" />
        <path d="M0 92 C70 86 150 100 230 90 S350 84 412 95" />
        <path d="M0 118 C90 124 180 110 250 119 S370 126 412 115" />
        <path d="M0 160 C60 154 130 168 200 160 S330 150 412 162" />
        <path d="M0 188 C110 194 190 180 280 189 S380 196 412 186" />
        <path d="M0 232 C90 226 160 240 240 231 S360 224 412 236" />
        <path d="M0 258 C70 264 170 250 240 259 S360 266 412 256" />
        <ellipse cx="300" cy="34" rx="24" ry="10" />
        <ellipse cx="96" cy="175" rx="20" ry="9" />
      </g>
      <ellipse cx="300" cy="34" rx="12" ry="5" fill="#7A4E2D" opacity="0.7" />
      <ellipse cx="96" cy="175" rx="10" ry="4.5" fill="#7A4E2D" opacity="0.7" />
      <g stroke="#5C3A20" stroke-width="2">
        <path d="M0 70 H412" /><path d="M0 140 H412" /><path d="M0 210 H412" />
        <path d="M252 70 V140" /><path d="M128 210 V280" />
      </g>
      <rect x="0" y="280" width="412" height="26" fill="#6A4226" />
      <rect x="0" y="280" width="412" height="4" fill="#8E6039" />
      <rect x="0" y="306" width="412" height="12" fill="#3B2716" opacity="0.12" />
    </svg>

    <div class="logo">
      <svg width="58" height="58" viewBox="0 0 24 24" fill="none" stroke="#F4C542" stroke-width="2.2" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="6.5" /><circle cx="12" cy="12" r="2.6" /><path d="M18.5 12H21.5M16.6 16.6l2.1 2.1M12 18.5v3M7.4 16.6l-2.1 2.1M5.5 12H2.5M7.4 7.4L5.3 5.3M12 5.5v-3M16.6 7.4l2.1-2.1" /></svg>
    </div>

    <div class="hero">
      <h1>Czeladniczka</h1>
      <p class="lead">Znajdź mistrza, który nauczy Cię fachu.</p>
      <ul class="points">
        <li v-for="p in points" :key="p">
          <span class="tick"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFF7E2" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12l5 5 9-10" /></svg></span>
          {{ p }}
        </li>
      </ul>
    </div>

    <div class="actions">
      <NuxtLink to="/signup?role=apprentice" class="btn">Szukam mistrza</NuxtLink>
      <NuxtLink to="/signup?role=master" class="btn btn-outline">Jestem mistrzem — szukam ucznia</NuxtLink>
      <p class="login">Masz już konto? <NuxtLink to="/login">Zaloguj się</NuxtLink></p>
    </div>
  </main>
</template>

<style scoped>
.welcome { position: relative; overflow: hidden; max-width: 480px; margin: 0 auto; min-height: 100dvh;
  background: #FBE7A1; display: flex; flex-direction: column; padding: 364px 28px 36px; }
.planks { position: absolute; left: 0; top: 0; width: 100%; height: 318px; display: block; }
.logo { position: absolute; left: 50%; top: 236px; transform: translateX(-50%); display: flex; align-items: center;
  justify-content: center; width: 104px; height: 104px; border-radius: 30px; background: var(--brown); border: 5px solid #FBE7A1; }
.hero { position: relative; margin-top: auto; display: flex; flex-direction: column; gap: 16px; }
h1 { font-size: 60px; line-height: 1; letter-spacing: -1px; }
.lead { margin: 0; font-size: 22px; line-height: 1.35; font-weight: 600; max-width: 320px; }
.points { list-style: none; padding: 0; margin: 8px 0 0; display: flex; flex-direction: column; gap: 10px; }
.points li { display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500; }
.tick { display: flex; flex: none; width: 28px; height: 28px; border-radius: 50%; background: var(--moss); align-items: center; justify-content: center; }
.actions { position: relative; display: flex; flex-direction: column; gap: 12px; margin-top: 40px; }
.actions .btn { font-weight: 700; }
.login { margin: 6px 0 0; text-align: center; font-size: 14px; }
.login a { font-weight: 700; }
@media (max-width: 360px) { h1 { font-size: 48px; } }
</style>
