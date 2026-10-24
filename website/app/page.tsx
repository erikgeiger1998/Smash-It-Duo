'use client';

import React from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import {
  Smartphone,
  Vibrate,
  Bug,
  Zap,
  ArrowRight,
  ShieldCheck,
  ChevronDown,
  Sparkles,
  Download,
  Flame,
} from 'lucide-react';
import FoldablePhone from '@/components/FoldablePhone';

export default function HomePage() {
  return (
    <div className="relative w-full overflow-hidden">
      {/* Background Decorative Ambient Radial Lighting */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-splat-green/10 blur-[130px] rounded-full pointer-events-none -z-10" />
      <div className="absolute top-96 right-10 w-[600px] h-[500px] bg-comic-orange/10 blur-[150px] rounded-full pointer-events-none -z-10" />
      <div className="absolute inset-0 arcade-grid opacity-20 pointer-events-none -z-10" />

      {/* =========================================
          HERO SECTION
          ========================================= */}
      <section className="relative pt-10 sm:pt-14 pb-12 sm:pb-20 px-4 sm:px-6 flex flex-col items-center text-center">
        
        {/* Arcade Action Pill */}
        <motion.div
          initial={{ opacity: 0, y: -16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-zinc-900/90 border border-splat-green/40 shadow-neon-glow mb-6"
        >
          <span className="flex h-2 w-2 rounded-full bg-splat-green animate-pulse" />
          <span className="text-xs sm:text-sm font-black tracking-wider text-splat-green uppercase">
            WORLD&apos;S FIRST FOLDABLE EXCLUSIVE GAME
          </span>
          <span className="text-xs">📱💥</span>
        </motion.div>

        {/* Comic Arcade Title "SMASH IT!" */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, type: 'spring' }}
          className="relative max-w-4xl mx-auto mb-4"
        >
          <h1 className="font-black text-6xl sm:text-8xl md:text-9xl tracking-tight uppercase select-none leading-none">
            <span className="bg-gradient-to-r from-comic-yellow via-comic-orange to-comic-red bg-clip-text text-transparent comic-outline-thick drop-shadow-[0_10px_0_#000]">
              SMASH IT
            </span>
            <span className="text-splat-green comic-outline-thick drop-shadow-[0_10px_0_#000]">
              !
            </span>
          </h1>

          <p className="mt-4 font-black text-xl sm:text-2xl md:text-3xl text-white tracking-wide uppercase flex items-center justify-center gap-2">
            <span className="text-splat-green font-mono">///</span>
            <span>The Foldable Fly Swatter</span>
            <span className="text-splat-green font-mono">///</span>
          </p>
        </motion.div>

        <motion.p
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="max-w-2xl text-zinc-400 text-sm sm:text-base md:text-lg mb-8"
        >
          Tired of boring touch taps? Physically snap your foldable dual-screen phone shut to crush buzzing pests at Mach 2 speeds with genuine 60Hz hinge vectoring.
        </motion.p>

        {/* Mount FoldablePhone Interactive Component */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.3 }}
          className="w-full mb-12"
        >
          <FoldablePhone />
        </motion.div>

        {/* =========================================
            CALL TO ACTION SECTION
            ========================================= */}
        <div id="download" className="relative flex flex-col items-center gap-4 mt-2">
          {/* Pulsing Download Button */}
          <motion.a
            href="https://apps.apple.com"
            target="_blank"
            rel="noopener noreferrer"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.96 }}
            className="group relative flex items-center gap-4 px-8 sm:px-10 py-4 sm:py-5 rounded-2xl bg-gradient-to-r from-splat-green via-emerald-400 to-splat-green text-black font-black text-lg sm:text-xl md:text-2xl tracking-wide uppercase border-4 border-black shadow-comic-lg hover:shadow-comic transition overflow-hidden animate-pulse-fast"
          >
            {/* Shimmer effect */}
            <div className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-1000 bg-gradient-to-r from-transparent via-white/40 to-transparent" />
            
            {/* Apple / App Store Icon */}
            <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-xl bg-black flex items-center justify-center text-white">
              <Download className="w-5 h-5 sm:w-6 sm:h-6 text-splat-green" />
            </div>

            <div className="flex flex-col items-start leading-none text-left">
              <span className="text-[10px] sm:text-xs font-bold text-zinc-900 tracking-widest uppercase">
                AVAILABLE NOW ON iOS
              </span>
              <span className="font-black text-black">
                Download on the App Store
              </span>
            </div>
          </motion.a>

          {/* Device Hardware Compatibility Notice */}
          <div className="flex flex-wrap items-center justify-center gap-4 text-xs font-mono text-zinc-500">
            <span className="flex items-center gap-1.5">
              <ShieldCheck className="w-4 h-4 text-splat-green" />
              <span>Requires Foldable Hardware (iPhone Duo)</span>
            </span>
            <span>•</span>
            <span>Zero In-App Ads</span>
            <span>•</span>
            <Link href="/support" className="text-zinc-400 hover:text-splat-green underline">
              View Support &amp; FAQ
            </Link>
          </div>
        </div>

      </section>

      {/* =========================================
          FEATURES SECTION (3 Simple Cards)
          ========================================= */}
      <section className="relative py-16 sm:py-24 px-4 sm:px-6 bg-arcade-900/60 border-t border-b border-arcade-border/80">
        <div className="max-w-6xl mx-auto">
          
          {/* Section Header */}
          <div className="text-center mb-14">
            <div className="inline-flex items-center gap-2 text-xs font-mono text-comic-yellow font-bold uppercase tracking-widest mb-2">
              <Sparkles className="w-3.5 h-3.5" />
              <span>NEXT-GEN FOLDABLE HARDWARE MECHANICS</span>
            </div>
            <h2 className="text-3xl sm:text-5xl font-black uppercase tracking-tight text-white">
              WHY PLAY WITH FINGERS WHEN YOU CAN{' '}
              <span className="text-comic-orange comic-outline">SLAM?</span>
            </h2>
          </div>

          {/* 3 Feature Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8">
            
            {/* Card 1: Real Physical Impact */}
            <motion.div
              whileHover={{ y: -6 }}
              className="relative p-6 sm:p-8 rounded-3xl bg-arcade-850 border-2 border-arcade-border hover:border-splat-green/60 shadow-comic transition flex flex-col justify-between group"
            >
              <div className="w-14 h-14 rounded-2xl bg-zinc-900 border border-zinc-700 flex items-center justify-center mb-6 group-hover:bg-splat-green/10 transition shadow-inner">
                <Smartphone className="w-8 h-8 text-splat-green transform group-hover:scale-110 group-hover:rotate-6 transition" />
              </div>
              <div>
                <span className="text-[10px] font-mono font-bold tracking-widest text-splat-green uppercase">
                  COREMOTION 60HZ
                </span>
                <h3 className="text-xl sm:text-2xl font-black text-white uppercase mt-1 mb-3">
                  Real Physical Impact
                </h3>
                <p className="text-zinc-400 text-sm leading-relaxed">
                  Our custom kinematics engine monitors high-frequency hinge angle velocity and deceleration. Slap the device shut to smash flies with real-world kinetic force.
                </p>
              </div>
              <div className="mt-6 pt-4 border-t border-zinc-800 flex items-center justify-between text-xs font-mono text-zinc-500">
                <span>VELOCITY</span>
                <span className="text-splat-green font-bold">1,420°/s MAX</span>
              </div>
            </motion.div>

            {/* Card 2: Dynamic Insect Waves */}
            <motion.div
              whileHover={{ y: -6 }}
              className="relative p-6 sm:p-8 rounded-3xl bg-arcade-850 border-2 border-arcade-border hover:border-comic-orange/60 shadow-comic transition flex flex-col justify-between group"
            >
              <div className="w-14 h-14 rounded-2xl bg-zinc-900 border border-zinc-700 flex items-center justify-center mb-6 group-hover:bg-comic-orange/10 transition shadow-inner">
                <Bug className="w-8 h-8 text-comic-orange transform group-hover:scale-110 group-hover:-rotate-6 transition" />
              </div>
              <div>
                <span className="text-[10px] font-mono font-bold tracking-widest text-comic-orange uppercase">
                  DUAL-SCREEN SWARMS
                </span>
                <h3 className="text-xl sm:text-2xl font-black text-white uppercase mt-1 mb-3">
                  Dynamic Insect Waves
                </h3>
                <p className="text-zinc-400 text-sm leading-relaxed">
                  Face hyperactive houseflies, armored hornets, and neon radioactive wasps that fly seamlessly back and forth across the folding screen seam.
                </p>
              </div>
              <div className="mt-6 pt-4 border-t border-zinc-800 flex items-center justify-between text-xs font-mono text-zinc-500">
                <span>SPECIES</span>
                <span className="text-comic-orange font-bold">24 UNIQUE PESTS</span>
              </div>
            </motion.div>

            {/* Card 3: Haptic Feedback */}
            <motion.div
              whileHover={{ y: -6 }}
              className="relative p-6 sm:p-8 rounded-3xl bg-arcade-850 border-2 border-arcade-border hover:border-comic-yellow/60 shadow-comic transition flex flex-col justify-between group"
            >
              <div className="w-14 h-14 rounded-2xl bg-zinc-900 border border-zinc-700 flex items-center justify-center mb-6 group-hover:bg-comic-yellow/10 transition shadow-inner">
                <Vibrate className="w-8 h-8 text-comic-yellow transform group-hover:scale-110 group-hover:rotate-12 transition" />
              </div>
              <div>
                <span className="text-[10px] font-mono font-bold tracking-widest text-comic-yellow uppercase">
                  COREHAPTICS ENGINE
                </span>
                <h3 className="text-xl sm:text-2xl font-black text-white uppercase mt-1 mb-3">
                  Haptic Feedback
                </h3>
                <p className="text-zinc-400 text-sm leading-relaxed">
                  Feel the instant crunch! Dual linear resonant actuators generate realistic impact impulses and dying insect twitches buzzing through both halves of the chassis.
                </p>
              </div>
              <div className="mt-6 pt-4 border-t border-zinc-800 flex items-center justify-between text-xs font-mono text-zinc-500">
                <span>TACTILE RECOIL</span>
                <span className="text-comic-yellow font-bold">3.8G DECEL</span>
              </div>
            </motion.div>

          </div>
        </div>
      </section>

      {/* =========================================
          HOW TO PLAY MINI-SECTION
          ========================================= */}
      <section className="py-16 sm:py-20 px-4 sm:px-6 max-w-5xl mx-auto text-center">
        <h2 className="text-2xl sm:text-4xl font-black uppercase text-white mb-10">
          THREE STEPS TO PEST-FREE GLORY
        </h2>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
          <div className="p-6 rounded-2xl bg-zinc-900/50 border border-zinc-800 flex flex-col items-center">
            <span className="w-10 h-10 rounded-full bg-zinc-800 text-splat-green font-mono font-bold flex items-center justify-center mb-3">
              01
            </span>
            <h4 className="font-bold text-white text-base uppercase mb-1">Open Flat</h4>
            <p className="text-zinc-400 text-xs">
              Keep your foldable device open at 180° and track the target buzzing across both screens.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-zinc-900/50 border border-zinc-800 flex flex-col items-center">
            <span className="w-10 h-10 rounded-full bg-zinc-800 text-comic-orange font-mono font-bold flex items-center justify-center mb-3">
              02
            </span>
            <h4 className="font-bold text-white text-base uppercase mb-1">Slap Shut</h4>
            <p className="text-zinc-400 text-xs">
              Snap the two displays together as fast as you can. Deceleration triggers the instant swat.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-zinc-900/50 border border-zinc-800 flex flex-col items-center">
            <span className="w-10 h-10 rounded-full bg-zinc-800 text-comic-yellow font-mono font-bold flex items-center justify-center mb-3">
              03
            </span>
            <h4 className="font-bold text-white text-base uppercase mb-1">Wipe Clean</h4>
            <p className="text-zinc-400 text-xs">
              Reopen to inspect your neon splat, tap the digital sponge to wipe the glass, and go again!
            </p>
          </div>
        </div>
      </section>

      {/* Bottom Sticky CTA Banner */}
      <section className="py-12 px-4 sm:px-6 bg-gradient-to-r from-arcade-900 via-arcade-850 to-arcade-900 border-t border-zinc-800">
        <div className="max-w-4xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-6 text-center sm:text-left">
          <div>
            <h3 className="text-xl sm:text-2xl font-black text-white uppercase">
              Ready to Fold &amp; Destroy?
            </h3>
            <p className="text-xs sm:text-sm text-zinc-400 mt-1">
              Download the exclusive build on the App Store today.
            </p>
          </div>
          <a
            href="https://apps.apple.com"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 px-6 py-3 rounded-xl bg-splat-green text-black font-black uppercase text-sm border-2 border-black shadow-comic hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 transition"
          >
            <span>GET IT NOW</span>
            <ArrowRight className="w-4 h-4" />
          </a>
        </div>
      </section>
    </div>
  );
}
