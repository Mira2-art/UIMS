<script setup lang="ts">
import { GraduationCap } from 'lucide-vue-next'
</script>

<template>
  <div class="min-h-screen w-full flex items-center justify-center bg-gradient-to-b from-primary to-[#2D5A68] px-6">
    <div class="max-w-2xl w-full text-center space-y-8 animate-in fade-in zoom-in duration-700">
      <!-- Logo Placeholder -->
      <div class="inline-flex p-6 rounded-full bg-white/10 mx-auto border border-white/20">
        <GraduationCap class="w-16 h-16 text-secondary" />
      </div>

      <div class="space-y-4">
        <h1 class="text-4xl md:text-6xl font-bold text-white tracking-tight">
          {{ $t('welcome') }}
        </h1>
        <p class="text-lg md:text-xl text-white/80 leading-relaxed max-w-lg mx-auto">
          {{ $t('description') }}
        </p>
      </div>

      <div class="flex flex-col sm:flex-row gap-4 justify-center pt-8">
        <button class="px-8 py-4 bg-secondary hover:bg-secondary/90 text-white rounded-lg font-bold text-lg transition-colors shadow-lg">
          {{ $t('getStarted') }}
        </button>
        <button class="px-8 py-4 bg-transparent border-2 border-white text-white hover:bg-white/10 rounded-lg font-bold text-lg transition-all">
          {{ $t('login') }}
        </button>
      </div>

      <div class="pt-12 text-white/50 text-sm">
        © 2024 Trustech Technologies
      </div>
    </div>
  </div>
</template>
