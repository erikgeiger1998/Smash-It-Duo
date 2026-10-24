'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Smartphone,
  Vibrate,
  Bug,
  Volume2,
  AlertTriangle,
  Zap,
  Sparkles,
  Download,
  ShieldCheck,
  Flame,
  ArrowRight,
  Crosshair,
  Radio,
  RotateCcw,
} from 'lucide-react';
import LiveFoldableDemo from '@/components/LiveFoldableDemo';

export default function HomePage() {
  const [crackedScreenActive, setCrackedScreenActive] = useState<boolean>(false);
  const [soundPanned, setSoundPanned] = useState<'left' | 'center' | 'right'>('center');

  return (
    <div className="relative w-full overflow-hidden">
      {/* Dynamic Background Radial Lighting */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[900px] h-[550px] bg-bugJuice/10 blur-[150px] rounded-full pointer-events-none -z-10" />
      <div className="absolute top-[800px] right-0 w-[600px] h-[600px] bg-arcade-crimson/10 blur-[170px] rounded-full pointer-events-none -z-10" />
      <div className="absolute top-[1600px] left-0 w-[650px] h-[650px] bg-arcade-gold/10 blur-[160px] rounded-full pointer-events-none -z-10" />

      {/* ========================================================
          HERO SECTION
          ======================================================== */}
      <section className="relative pt-8 sm:pt-12 pb-16 sm:pb-24 px-4 sm:px-6 flex flex-col items-center text-center">
        
        {/* Hardware Exclusivity Pill */}
        <motion.div
          initial={{ opacity: 0, y: -16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-obsidian-850 border border-bugJuice/40 shadow-neon-green mb-6"
        >
          <span className="flex h-2 w-2 rounded-full bg-bugJuice animate-ping" />
          <span className="text-xs sm:text-sm font-black tracking-wider text-bugJuice uppercase">
            EXCLUSIVELY FOR FOLDABLE IPHONE DUO
          </span>
          <span className="text-xs">⚡</span>
        </motion.div>

        {/* Hero Headline: "DON'T TAP IT. CLAP IT." */}
        <motion.div
          initial={{ opacity: 0, scale: 0.92 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, type: 'spring' }}
          className="relative max-w-5xl mx-auto mb-4"
        >
          <h1 className="font-black text-6xl sm:text-8xl md:text-9xl tracking-tight uppercase select-none leading-none">
            <span className="text-white comic-outline-thick drop-shadow-[0_12px_0_#000]">
              DON&apos;T TAP IT.
            </span>
            <br />
            <span className="text-arcade-gold comic-outline-thick drop-shadow-[0_12px_0_#000]">
              CLAP IT
            </span>
            <span className="text-bugJuice comic-outline-thick drop-shadow-[0_12px_0_#000]">
              !
            </span>
          </h1>

          <p className="mt-6 max-w-2xl mx-auto text-zinc-300 font-medium text-base sm:text-xl md:text-2xl leading-relaxed">
            The world&apos;s first physical reflex game built exclusively for the foldable iPhone Duo.{' '}
            <span className="text-bugJuice font-bold">Your device is the weapon.</span>
          </p>
        </motion.div>

        {/* 3D Live Foldable Demo Component */}
        <div id="gameplay" className="w-full mt-4 mb-10">
          <LiveFoldableDemo />
        </div>

        {/* Reaction Time Ticker & Official App Store CTA */}
        <div className="relative flex flex-col items-center gap-5 w-full max-w-xl mx-auto">
          {/* Reaction Ticker */}
          <div className="w-full flex items-center justify-between px-4 py-2.5 rounded-xl bg-obsidian-850/90 border border-obsidian-border text-xs font-mono text-zinc-400">
            <div className="flex items-center gap-1.5">
              <Zap className="w-4 h-4 text-arcade-gold fill-arcade-gold" />
              <span>AVG REACTION: <strong className="text-white">184ms</strong></span>
            </div>
            <div className="hidden sm:inline text-zinc-600">•</div>
            <div className="hidden sm:flex items-center gap-1">
              <span>RECORD: <strong className="text-bugJuice">92ms (MACH 2)</strong></span>
            </div>
            <div className="text-zinc-600">•</div>
            <div>
              <span className="text-zinc-300 font-bold">2.4M+</span> SQUASHED
            </div>
          </div>

          {/* Official App Store CTA Button */}
          <motion.a
            href="https://apps.apple.com"
            target="_blank"
            rel="noopener noreferrer"
            whileHover={{ scale: 1.04 }}
            whileTap={{ scale: 0.96 }}
            className="group relative flex items-center gap-4 px-8 sm:px-12 py-4 sm:py-5 rounded-2xl bg-gradient-to-r from-bugJuice via-emerald-400 to-bugJuice text-black font-black text-xl sm:text-2xl tracking-wide uppercase border-4 border-black shadow-comic-lg hover:shadow-comic transition overflow-hidden animate-pulse-fast"
          >
            <div className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-1000 bg-gradient-to-r from-transparent via-white/40 to-transparent" />
            <div className="w-10 h-10 sm:w-11 sm:h-11 rounded-xl bg-black flex items-center justify-center text-white">
              <Download className="w-6 h-6 text-bugJuice" />
            </div>
            <div className="flex flex-col items-start leading-none text-left">
              <span className="text-[10px] sm:text-xs font-bold text-zinc-900 tracking-widest uppercase">
                EXCLUSIVELY FOR IPHONE DUO
              </span>
              <span className="font-black text-black text-lg sm:text-2xl">
                Download on the App Store
              </span>
            </div>
          </motion.a>

          <p className="text-xs font-mono text-zinc-500">
            Requires Dual-Screen Hardware &amp; DuoOS 18+ • Zero Microtransactions
          </p>
        </div>

      </section>

      {/* ========================================================
          INTERACTIVE FEATURE BENTO GRID ("WHY IT'S VIRAL")
          ======================================================== */}
      <section className="relative py-20 sm:py-28 px-4 sm:px-6 bg-obsidian-950/70 border-t border-b border-obsidian-border/80">
        <div className="max-w-6xl mx-auto">
          
          <div className="text-center mb-16">
            <div className="inline-flex items-center gap-2 text-xs font-mono text-bugJuice font-bold uppercase tracking-widest mb-3">
              <Sparkles className="w-4 h-4" />
              <span>TACTILE HARDWARE MECHANICS</span>
            </div>
            <h2 className="text-4xl sm:text-6xl font-black uppercase tracking-tight text-white">
              WHY IT&apos;S <span className="text-arcade-gold comic-outline">VIRAL</span>
            </h2>
            <p className="mt-3 text-zinc-400 text-sm sm:text-base max-w-xl mx-auto">
              Not another thumb-tap game. Smash It transforms your foldable phone into a physical insect swatter.
            </p>
          </div>

          {/* Bento Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-6">
            
            {/* Bento Card 1: Symmetrical Inkblot Physics (lg:col-span-7) */}
            <motion.div
              whileHover={{ y: -5 }}
              className="lg:col-span-7 p-7 sm:p-9 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-bugJuice/60 shadow-comic transition flex flex-col justify-between relative overflow-hidden group"
            >
              <div className="flex items-center justify-between mb-6">
                <span className="text-xs font-mono font-bold tracking-widest text-bugJuice uppercase">
                  PHYSICAL RORSCHACH JUICE TRANSFER
                </span>
                <span className="text-xs font-mono px-2.5 py-1 rounded-full bg-zinc-900 text-zinc-400 border border-zinc-800">
                  DUAL-OLED SEAM
                </span>
              </div>

              <div className="my-4">
                <h3 className="text-2xl sm:text-3xl font-black text-white uppercase mb-3">
                  Symmetrical Inkblot Physics
                </h3>
                <p className="text-zinc-400 text-sm sm:text-base leading-relaxed">
                  When you clap the phone shut, the fly is physically crushed between the dual OLED panels. Reopening stamps an authentic, mirrored neon-green inkblot splat across both screens right at the crease.
                </p>
              </div>

              {/* Visual Demo graphic inside card */}
              <div className="mt-6 p-4 rounded-2xl bg-black/60 border border-zinc-800 flex items-center justify-center gap-6">
                <div className="w-24 h-28 rounded-l-xl bg-table-wood border-r-2 border-dashed border-bugJuice p-2 flex items-center justify-end">
                  <div className="w-10 h-10 rounded-full bg-bugJuice blur-[2px]" />
                </div>
                <div className="text-xs font-mono text-zinc-500 uppercase tracking-widest text-center">
                  HINGE<br />AXIS
                </div>
                <div className="w-24 h-28 rounded-r-xl bg-table-wood border-l-2 border-dashed border-bugJuice p-2 flex items-center justify-start">
                  <div className="w-10 h-10 rounded-full bg-bugJuice blur-[2px]" />
                </div>
              </div>
            </motion.div>

            {/* Bento Card 2: CoreHaptics Death Throes (lg:col-span-5) */}
            <motion.div
              whileHover={{ y: -5 }}
              className="lg:col-span-5 p-7 sm:p-9 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-arcade-yellow/60 shadow-comic transition flex flex-col justify-between group"
            >
              <div className="flex items-center justify-between mb-4">
                <span className="text-xs font-mono font-bold tracking-widest text-arcade-gold uppercase">
                  TACTILE RECOIL
                </span>
                <Vibrate className="w-6 h-6 text-arcade-gold group-hover:rotate-12 transition" />
              </div>

              <div>
                <h3 className="text-2xl font-black text-white uppercase mb-2">
                  CoreHaptics Death Throes
                </h3>
                <p className="text-zinc-400 text-sm leading-relaxed">
                  Feel the fly buzzing in trapped panic inside your folded palms! A 1.5-second decaying vibrational flutter (<code className="text-arcade-gold">bzzzz-bzz-bz...</code>) pulses through the chassis actuators before flatlining.
                </p>
              </div>

              <div className="mt-6 p-4 rounded-2xl bg-zinc-950 border border-zinc-800 flex items-center justify-between text-xs font-mono">
                <span className="text-zinc-500">ACTUATOR OSCILLATION</span>
                <span className="text-arcade-gold font-bold animate-pulse">85Hz → 45Hz DECAY</span>
              </div>
            </motion.div>

            {/* Bento Card 3: 3D Spatial Audio Buzzing (lg:col-span-5) */}
            <motion.div
              whileHover={{ y: -5 }}
              className="lg:col-span-5 p-7 sm:p-9 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-sky-400/60 shadow-comic transition flex flex-col justify-between group"
            >
              <div className="flex items-center justify-between mb-4">
                <span className="text-xs font-mono font-bold tracking-widest text-sky-400 uppercase">
                  DUAL STEREO PANNING
                </span>
                <Radio className="w-6 h-6 text-sky-400" />
              </div>

              <div>
                <h3 className="text-2xl font-black text-white uppercase mb-2">
                  3D Spatial Audio Buzzing
                </h3>
                <p className="text-zinc-400 text-sm leading-relaxed">
                  Listen with your ears to hunt. Our spatial acoustic synthesizer pans high-frequency insect buzzes seamlessly across the left and right speakers according to the fly&apos;s real-time coordinate vector.
                </p>
              </div>

              {/* Interactive Audio Panning Demo */}
              <div className="mt-6 p-3.5 rounded-2xl bg-zinc-950 border border-zinc-800 flex items-center justify-between">
                <button
                  onClick={() => setSoundPanned('left')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-mono font-bold transition ${
                    soundPanned === 'left' ? 'bg-sky-400 text-black' : 'bg-zinc-900 text-zinc-400'
                  }`}
                >
                  LEFT CH
                </button>
                <button
                  onClick={() => setSoundPanned('center')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-mono font-bold transition ${
                    soundPanned === 'center' ? 'bg-sky-400 text-black' : 'bg-zinc-900 text-zinc-400'
                  }`}
                >
                  CENTER CREASE
                </button>
                <button
                  onClick={() => setSoundPanned('right')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-mono font-bold transition ${
                    soundPanned === 'right' ? 'bg-sky-400 text-black' : 'bg-zinc-900 text-zinc-400'
                  }`}
                >
                  RIGHT CH
                </button>
              </div>
            </motion.div>

            {/* Bento Card 4: The "Too Hard!" Easter Egg (lg:col-span-7) */}
            <motion.div
              whileHover={{ y: -5 }}
              onClick={() => setCrackedScreenActive(!crackedScreenActive)}
              className="lg:col-span-7 p-7 sm:p-9 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-arcade-crimson/60 shadow-comic transition flex flex-col justify-between relative overflow-hidden cursor-pointer group"
            >
              {/* Fake Cracked Screen Overlay upon click */}
              {crackedScreenActive && (
                <div className="absolute inset-0 bg-red-950/40 z-30 pointer-events-none flex items-center justify-center">
                  <svg className="absolute inset-0 w-full h-full stroke-white/80 stroke-2" viewBox="0 0 400 250">
                    <path d="M 200 120 L 140 40 L 90 60 L 30 20" fill="none" />
                    <path d="M 200 120 L 260 50 L 340 30" fill="none" />
                    <path d="M 200 120 L 280 190 L 370 210" fill="none" />
                    <path d="M 200 120 L 130 180 L 80 230" fill="none" />
                    <circle cx="200" cy="120" r="14" fill="#ffffff" opacity="0.3" />
                  </svg>
                  <div className="relative z-40 px-4 py-2 rounded-xl bg-arcade-crimson text-white font-black text-sm uppercase tracking-widest shadow-comic animate-bounce">
                    💥 +500 BRUTALITY BONUS! (TAP TO RESTORE)
                  </div>
                </div>
              )}

              <div className="flex items-center justify-between mb-4">
                <span className="text-xs font-mono font-bold tracking-widest text-arcade-crimson uppercase">
                  INTERACTIVE EASTER EGG (CLICK ME)
                </span>
                <span className="text-xs px-2 py-0.5 rounded bg-red-950 border border-red-800 text-red-400 font-mono">
                  {crackedScreenActive ? 'CRACKED!' : 'CLICK TO SLAM'}
                </span>
              </div>

              <div>
                <h3 className="text-2xl sm:text-3xl font-black text-white uppercase mb-2">
                  The &quot;Too Hard!&quot; Easter Egg
                </h3>
                <p className="text-zinc-400 text-sm leading-relaxed">
                  Slapped your iPhone Duo shut with superhuman aggression? Triggering deceleration over <strong className="text-white">4.5G</strong> awards a comic shattered glass visual with a &quot;+500 Brutality Bonus&quot;!
                </p>
              </div>

              <div className="mt-6 pt-4 border-t border-zinc-800 flex items-center justify-between text-xs font-mono text-zinc-500">
                <span>EASTER EGG STATUS</span>
                <span className="text-arcade-crimson font-bold">
                  {crackedScreenActive ? 'DISCIPLINED SLAMMER' : 'TAP CARD TO TEST BRUTALITY'}
                </span>
              </div>
            </motion.div>

          </div>
        </div>
      </section>

      {/* ========================================================
          THE BESTIARY / ENEMY WAVES SHOWCASE
          ======================================================== */}
      <section id="enemies" className="py-20 sm:py-28 px-4 sm:px-6 max-w-6xl mx-auto">
        
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 text-xs font-mono text-arcade-crimson font-bold uppercase tracking-widest mb-3">
            <Bug className="w-4 h-4" />
            <span>24 PROCEDURAL SWARM TYPES</span>
          </div>
          <h2 className="text-4xl sm:text-6xl font-black uppercase tracking-tight text-white">
            THE <span className="text-bugJuice comic-outline">BESTIARY</span>
          </h2>
          <p className="mt-3 text-zinc-400 text-sm sm:text-base max-w-xl mx-auto">
            Each insect features unique wing frequencies, flight agility, and clap vulnerability windows.
          </p>
        </div>

        {/* 4 Custom SVG Showcase Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          
          {/* Card 1: Common Housefly */}
          <motion.div
            whileHover={{ y: -6 }}
            className="p-6 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-bugJuice shadow-comic transition flex flex-col justify-between"
          >
            <div>
              <div className="w-full h-36 rounded-2xl bg-zinc-950 border border-zinc-800 flex items-center justify-center p-4 mb-5">
                {/* SVG Common Housefly */}
                <svg width="70" height="70" viewBox="0 0 60 60">
                  <g stroke="#334155" strokeWidth="2" fill="none">
                    <path d="M 22 22 L 10 14" /><path d="M 22 30 L 6 30" /><path d="M 22 38 L 10 46" />
                    <path d="M 38 22 L 50 14" /><path d="M 38 30 L 54 30" /><path d="M 38 38 L 50 46" />
                  </g>
                  <ellipse cx="20" cy="20" rx="14" ry="7" transform="rotate(-35 20 20)" fill="rgba(186,230,253,0.7)" stroke="#38bdf8" />
                  <ellipse cx="40" cy="20" rx="14" ry="7" transform="rotate(35 40 20)" fill="rgba(186,230,253,0.7)" stroke="#38bdf8" />
                  <ellipse cx="30" cy="36" rx="9" ry="12" fill="#0f172a" />
                  <ellipse cx="30" cy="24" rx="8" ry="7" fill="#1e293b" />
                  <circle cx="26" cy="16" r="4" fill="#dc2626" />
                  <circle cx="34" cy="16" r="4" fill="#dc2626" />
                </svg>
              </div>
              <span className="text-[10px] font-mono font-bold tracking-widest text-bugJuice uppercase">
                STANDARD TARGET
              </span>
              <h3 className="text-xl font-black text-white uppercase mt-1 mb-2">
                Common Housefly
              </h3>
              <p className="text-zinc-400 text-xs leading-relaxed">
                The standard pest. Loves watermelon and french fries. Predictable flight pattern, ideal for perfecting your clap timing.
              </p>
            </div>

            <div className="mt-5 pt-3 border-t border-zinc-800 flex flex-col gap-1 text-[11px] font-mono">
              <div className="flex justify-between text-zinc-500">
                <span>FREQUENCY</span>
                <span className="text-white font-bold">158 Hz</span>
              </div>
              <div className="flex justify-between text-zinc-500">
                <span>CLAP WINDOW</span>
                <span className="text-bugJuice font-bold">0.75s</span>
              </div>
            </div>
          </motion.div>

          {/* Card 2: Stealth Mosquito */}
          <motion.div
            whileHover={{ y: -6 }}
            className="p-6 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-sky-400 shadow-comic transition flex flex-col justify-between"
          >
            <div>
              <div className="w-full h-36 rounded-2xl bg-zinc-950 border border-zinc-800 flex items-center justify-center p-4 mb-5">
                {/* SVG Mosquito */}
                <svg width="70" height="70" viewBox="0 0 60 60">
                  <g stroke="#475569" strokeWidth="1.5" fill="none">
                    <path d="M 25 24 L 6 10 L 2 16" /><path d="M 25 32 L 4 32" /><path d="M 25 40 L 8 52" />
                    <path d="M 35 24 L 54 10 L 58 16" /><path d="M 35 32 L 56 32" /><path d="M 35 40 L 52 52" />
                  </g>
                  {/* Long proboscis */}
                  <line x1="30" y1="14" x2="30" y2="4" stroke="#e2e8f0" strokeWidth="1.5" />
                  <ellipse cx="22" cy="18" rx="14" ry="4" transform="rotate(-45 22 18)" fill="rgba(224,242,254,0.7)" stroke="#7dd3fc" />
                  <ellipse cx="38" cy="18" rx="14" ry="4" transform="rotate(45 38 18)" fill="rgba(224,242,254,0.7)" stroke="#7dd3fc" />
                  <ellipse cx="30" cy="38" rx="4" ry="14" fill="#1e1e24" />
                  <circle cx="28" cy="18" r="2.5" fill="#f87171" />
                  <circle cx="32" cy="18" r="2.5" fill="#f87171" />
                </svg>
              </div>
              <span className="text-[10px] font-mono font-bold tracking-widest text-sky-400 uppercase">
                HYPER-AGILE PEST
              </span>
              <h3 className="text-xl font-black text-white uppercase mt-1 mb-2">
                Stealth Mosquito
              </h3>
              <p className="text-zinc-400 text-xs leading-relaxed">
                High-pitch ultrasonic buzz. Darting zig-zag flight paths across the hinge crease. Requires razor-sharp reflex.
              </p>
            </div>

            <div className="mt-5 pt-3 border-t border-zinc-800 flex flex-col gap-1 text-[11px] font-mono">
              <div className="flex justify-between text-zinc-500">
                <span>FREQUENCY</span>
                <span className="text-white font-bold">460 Hz</span>
              </div>
              <div className="flex justify-between text-zinc-500">
                <span>CLAP WINDOW</span>
                <span className="text-sky-400 font-bold">0.48s (ERRATIC)</span>
              </div>
            </div>
          </motion.div>

          {/* Card 3: Mutant Horsefly Boss */}
          <motion.div
            whileHover={{ y: -6 }}
            className="p-6 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-arcade-yellow shadow-comic transition flex flex-col justify-between"
          >
            <div>
              <div className="w-full h-36 rounded-2xl bg-zinc-950 border border-zinc-800 flex items-center justify-center p-4 mb-5">
                {/* SVG Mutant Horsefly */}
                <svg width="70" height="70" viewBox="0 0 60 60">
                  <g stroke="#713f12" strokeWidth="3" fill="none">
                    <path d="M 20 22 L 8 16" /><path d="M 20 30 L 4 30" /><path d="M 20 38 L 8 46" />
                    <path d="M 40 22 L 52 16" /><path d="M 40 30 L 56 30" /><path d="M 40 38 L 52 46" />
                  </g>
                  <ellipse cx="18" cy="18" rx="16" ry="8" transform="rotate(-30 18 18)" fill="rgba(254,240,138,0.7)" stroke="#eab308" strokeWidth="2" />
                  <ellipse cx="42" cy="18" rx="16" ry="8" transform="rotate(30 42 18)" fill="rgba(254,240,138,0.7)" stroke="#eab308" strokeWidth="2" />
                  {/* Heavy armored body */}
                  <ellipse cx="30" cy="38" rx="12" ry="15" fill="#451a03" stroke="#78350f" strokeWidth="2" />
                  <line x1="20" y1="34" x2="40" y2="34" stroke="#ca8a04" strokeWidth="3" />
                  <line x1="20" y1="42" x2="40" y2="42" stroke="#ca8a04" strokeWidth="3" />
                  <ellipse cx="30" cy="22" rx="10" ry="8" fill="#78350f" />
                  <circle cx="25" cy="16" r="5" fill="#dc2626" />
                  <circle cx="35" cy="16" r="5" fill="#dc2626" />
                </svg>
              </div>
              <span className="text-[10px] font-mono font-bold tracking-widest text-arcade-gold uppercase">
                ARMORED BOSS
              </span>
              <h3 className="text-xl font-black text-white uppercase mt-1 mb-2">
                Mutant Horsefly
              </h3>
              <p className="text-zinc-400 text-xs leading-relaxed">
                Heavy armored exoskeleton. A single clap only dazes it—you must double-clap within 0.3s to finish the job!
              </p>
            </div>

            <div className="mt-5 pt-3 border-t border-zinc-800 flex flex-col gap-1 text-[11px] font-mono">
              <div className="flex justify-between text-zinc-500">
                <span>FREQUENCY</span>
                <span className="text-white font-bold">92 Hz</span>
              </div>
              <div className="flex justify-between text-zinc-500">
                <span>SPECIAL MECHANIC</span>
                <span className="text-arcade-gold font-bold">DOUBLE-CLAP</span>
              </div>
            </div>
          </motion.div>

          {/* Card 4: Yellowjacket Wasp (TRAP) */}
          <motion.div
            whileHover={{ y: -6 }}
            className="p-6 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border hover:border-arcade-crimson shadow-comic transition flex flex-col justify-between"
          >
            <div>
              <div className="w-full h-36 rounded-2xl bg-zinc-950 border border-zinc-800 flex items-center justify-center p-4 mb-5">
                {/* SVG Wasp */}
                <svg width="70" height="70" viewBox="0 0 60 60">
                  <g stroke="#18181b" strokeWidth="2" fill="none">
                    <path d="M 22 22 L 10 14" /><path d="M 22 30 L 6 30" /><path d="M 22 38 L 10 46" />
                    <path d="M 38 22 L 50 14" /><path d="M 38 30 L 54 30" /><path d="M 38 38 L 50 46" />
                  </g>
                  {/* Narrow wings */}
                  <ellipse cx="18" cy="18" rx="16" ry="5" transform="rotate(-40 18 18)" fill="rgba(254,249,195,0.8)" stroke="#fde047" />
                  <ellipse cx="42" cy="18" rx="16" ry="5" transform="rotate(40 42 18)" fill="rgba(254,249,195,0.8)" stroke="#fde047" />
                  {/* Pointed striped abdomen with sting */}
                  <path d="M 30 28 Q 22 34 26 44 L 30 52 L 34 44 Q 38 34 30 28 Z" fill="#eab308" stroke="#000" strokeWidth="1.5" />
                  <line x1="25" y1="36" x2="35" y2="36" stroke="#000" strokeWidth="2.5" />
                  <line x1="27" y1="42" x2="33" y2="42" stroke="#000" strokeWidth="2.5" />
                  <line x1="30" y1="52" x2="30" y2="56" stroke="#ef4444" strokeWidth="2" strokeLinecap="round" />
                  <circle cx="26" cy="18" r="3" fill="#000" />
                  <circle cx="34" cy="18" r="3" fill="#000" />
                </svg>
              </div>
              <span className="text-[10px] font-mono font-bold tracking-widest text-arcade-crimson uppercase">
                TRAP HAZARD — DO NOT CLAP
              </span>
              <h3 className="text-xl font-black text-white uppercase mt-1 mb-2">
                Yellowjacket Wasp
              </h3>
              <p className="text-zinc-400 text-xs leading-relaxed">
                The ultimate reflex test. When the wasp lands, DO NOT FOLD! Clapping will sting your fingers and cost 1 heart!
              </p>
            </div>

            <div className="mt-5 pt-3 border-t border-zinc-800 flex flex-col gap-1 text-[11px] font-mono">
              <div className="flex justify-between text-zinc-500">
                <span>FREQUENCY</span>
                <span className="text-white font-bold">230 Hz</span>
              </div>
              <div className="flex justify-between text-zinc-500">
                <span>PENALTY</span>
                <span className="text-arcade-crimson font-bold">-1 LIFE / STING</span>
              </div>
            </div>
          </motion.div>

        </div>
      </section>

      {/* ========================================================
          BOTTOM DOWNLOAD BANNER
          ======================================================== */}
      <section className="py-14 px-4 sm:px-6 bg-gradient-to-r from-obsidian-950 via-obsidian-850 to-obsidian-950 border-t border-obsidian-border">
        <div className="max-w-4xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-6 text-center sm:text-left">
          <div>
            <h3 className="text-2xl sm:text-3xl font-black text-white uppercase">
              Ready to turn your phone into a weapon?
            </h3>
            <p className="text-xs sm:text-sm text-zinc-400 mt-1">
              Download SMASH IT! DUO on the Apple App Store today.
            </p>
          </div>
          <a
            href="https://apps.apple.com"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 px-8 py-4 rounded-xl bg-bugJuice text-black font-black uppercase text-sm border-2 border-black shadow-comic hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 transition whitespace-nowrap"
          >
            <span>GET IT ON APP STORE</span>
            <ArrowRight className="w-4 h-4" />
          </a>
        </div>
      </section>
    </div>
  );
}
