'use client';

import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Volume2, VolumeX, Sparkles, RefreshCw, Zap, ShieldAlert } from 'lucide-react';

export default function FoldablePhone() {
  const [phoneState, setPhoneState] = useState<'idle' | 'folding' | 'splatted'>('idle');
  const [splatCount, setSplatCount] = useState<number>(0);
  const [shake, setShake] = useState<boolean>(false);
  const [soundEnabled, setSoundEnabled] = useState<boolean>(true);
  const [splatSeed, setSplatSeed] = useState<number>(1);
  const audioCtxRef = useRef<AudioContext | null>(null);

  // Web Audio sound synthesizer (zero external assets required)
  const playSound = (type: 'smash' | 'wipe') => {
    if (!soundEnabled || typeof window === 'undefined') return;
    try {
      const AudioContextClass = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (!audioCtxRef.current) {
        audioCtxRef.current = new AudioContextClass();
      }
      const ctx = audioCtxRef.current;
      if (ctx.state === 'suspended') {
        ctx.resume();
      }

      if (type === 'smash') {
        // Physical slam sub-bass thud
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(150, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(32, ctx.currentTime + 0.16);
        gain.gain.setValueAtTime(0.8, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.22);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.23);

        // Wet squishy impact noise
        const bufferSize = Math.floor(ctx.sampleRate * 0.18);
        const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
          data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (ctx.sampleRate * 0.04));
        }
        const noise = ctx.createBufferSource();
        noise.buffer = buffer;
        const filter = ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.setValueAtTime(1400, ctx.currentTime);
        filter.frequency.exponentialRampToValueAtTime(250, ctx.currentTime + 0.16);
        filter.Q.value = 3.0;

        const noiseGain = ctx.createGain();
        noiseGain.gain.setValueAtTime(0.7, ctx.currentTime + 0.02);
        noiseGain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.18);
        noise.connect(filter);
        filter.connect(noiseGain);
        noiseGain.connect(ctx.destination);
        noise.start(ctx.currentTime + 0.02);
      } else if (type === 'wipe') {
        // High-pitched squeak / wipe sound
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(500, ctx.currentTime);
        osc.frequency.linearRampToValueAtTime(950, ctx.currentTime + 0.08);
        osc.frequency.linearRampToValueAtTime(620, ctx.currentTime + 0.18);
        gain.gain.setValueAtTime(0.2, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.2);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.2);
      }
    } catch {
      // AudioContext fallback
    }
  };

  const triggerSmash = () => {
    if (phoneState === 'folding') return;
    if (phoneState === 'splatted') {
      // Already splatted, clean first
      handleWipeScreen();
      return;
    }

    setPhoneState('folding');

    // Impact timing sequence:
    // 1. Fold inward (0 to 220ms)
    // 2. Clapping impact at 220ms -> shake, sound, reveal splat
    // 3. Spring open back to flat (240ms to 600ms)
    setTimeout(() => {
      playSound('smash');
      setShake(true);
      setSplatCount((prev) => prev + 1);
      setSplatSeed((prev) => prev + 1);
    }, 220);

    setTimeout(() => {
      setShake(false);
      setPhoneState('splatted');
    }, 450);
  };

  const handleWipeScreen = () => {
    playSound('wipe');
    setPhoneState('idle');
  };

  return (
    <div className="relative flex flex-col items-center w-full max-w-4xl mx-auto px-4 select-none">
      {/* Top Interactive Status Bar & Sound Toggle */}
      <div className="w-full flex items-center justify-between mb-3 px-2 text-xs font-mono">
        <div className="flex items-center gap-2">
          <span className="flex h-2.5 w-2.5 relative">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-splat-green opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-splat-green"></span>
          </span>
          <span className="text-zinc-400 uppercase tracking-wider hidden sm:inline">
            DUAL-SCREEN HINGE GYRO: <span className="text-splat-green font-bold">ACTIVE 60Hz</span>
          </span>
          <span className="text-zinc-400 sm:hidden">
            GYRO: <span className="text-splat-green font-bold">ONLINE</span>
          </span>
        </div>

        <div className="flex items-center gap-4">
          <div className="text-zinc-400">
            SQUASHES: <span className="text-comic-yellow font-bold text-sm">{splatCount}</span>
          </div>
          <button
            onClick={() => setSoundEnabled(!soundEnabled)}
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-zinc-900 border border-zinc-800 text-zinc-300 hover:text-white hover:border-zinc-700 transition"
            title={soundEnabled ? 'Mute sound effects' : 'Unmute sound effects'}
          >
            {soundEnabled ? <Volume2 className="w-3.5 h-3.5 text-splat-green" /> : <VolumeX className="w-3.5 h-3.5 text-zinc-500" />}
            <span className="text-[10px] hidden sm:inline">{soundEnabled ? 'AUDIO ON' : 'MUTED'}</span>
          </button>
        </div>
      </div>

      {/* 3D Perspective Phone Stage with Screen Shake */}
      <motion.div
        animate={
          shake
            ? {
                x: [0, -14, 16, -12, 10, -5, 0],
                y: [0, 8, -10, 6, -5, 2, 0],
                rotate: [0, -2, 2.5, -1.5, 1, 0],
                scale: [1, 1.04, 0.98, 1.02, 1],
              }
            : { x: 0, y: 0, rotate: 0, scale: 1 }
        }
        transition={{ duration: 0.35, ease: 'easeInOut' }}
        className="w-full flex justify-center py-4 cursor-pointer"
        style={{ perspective: '1400px' }}
        onClick={phoneState === 'idle' ? triggerSmash : undefined}
      >
        {/* Landscape Foldable Phone Body */}
        <div className="relative w-full max-w-[760px] h-[340px] sm:h-[400px] md:h-[450px] p-2.5 sm:p-3 rounded-[32px] sm:rounded-[38px] bg-gradient-to-b from-zinc-700 via-zinc-800 to-zinc-950 shadow-[0_20px_50px_rgba(0,0,0,0.9),0_0_20px_rgba(30,41,59,0.5)] border-2 border-zinc-600/60 preserve-3d">
          
          {/* Inner Display Bezel Shell */}
          <div className="relative w-full h-full rounded-[24px] sm:rounded-[28px] bg-black p-1.5 sm:p-2 overflow-hidden flex preserve-3d">
            
            {/* =========================================
                LEFT SCREEN (Rotates Y around Right edge)
                ========================================= */}
            <motion.div
              className="relative w-1/2 h-full rounded-l-[20px] sm:rounded-l-[22px] bg-[#07090e] overflow-hidden border-r border-zinc-900/90 shadow-inner flex flex-col justify-between"
              style={{
                transformOrigin: 'right center',
                transformStyle: 'preserve-3d',
                backfaceVisibility: 'hidden',
              }}
              animate={{
                rotateY: phoneState === 'folding' ? 88 : 0,
              }}
              transition={
                phoneState === 'folding'
                  ? { duration: 0.22, ease: [0.4, 0, 0.2, 1] }
                  : { type: 'spring', stiffness: 260, damping: 18 }
              }
            >
              {/* Screen Glare & Vignette */}
              <div className="absolute inset-0 bg-gradient-to-tr from-transparent via-white/[0.02] to-white/[0.06] pointer-events-none z-30" />
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_left,#101422_0%,#05060a_100%)] opacity-90 pointer-events-none" />

              {/* Arcade Grid Overlay */}
              <div className="absolute inset-0 arcade-grid opacity-30 pointer-events-none" />

              {/* Status Bar: Left Screen */}
              <div className="relative z-20 flex items-center justify-between px-3 sm:px-4 pt-2.5 text-[10px] sm:text-xs font-mono text-zinc-500">
                <span className="font-bold text-zinc-300">09:41</span>
                <span className="flex items-center gap-1 text-[9px] px-1.5 py-0.5 rounded bg-zinc-900 border border-zinc-800 text-zinc-400">
                  <Zap className="w-2.5 h-2.5 text-comic-yellow" /> DUO L
                </span>
              </div>

              {/* Crosshair / Target Reticle Graphic */}
              <div className="absolute inset-0 flex items-center justify-end pointer-events-none pr-0 opacity-20">
                <div className="w-48 h-48 sm:w-64 sm:h-64 rounded-full border border-dashed border-red-500/50 flex items-center justify-center">
                  <div className="w-24 h-24 sm:w-36 sm:h-36 rounded-full border border-red-500/40" />
                </div>
              </div>

              {/* Symmetrical Left Inkblot Splat */}
              {phoneState === 'splatted' && (
                <div className="absolute inset-0 flex items-center justify-end z-20 pointer-events-none overflow-hidden pr-0">
                  <motion.div
                    initial={{ scale: 0.2, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ type: 'spring', stiffness: 350, damping: 15 }}
                    className="w-full h-full flex items-center justify-end"
                  >
                    <svg
                      viewBox="0 0 300 360"
                      className="w-full h-full max-h-[380px] text-splat-green filter drop-shadow-[0_0_20px_rgba(57,255,20,0.7)]"
                    >
                      <defs>
                        <linearGradient id="splatGradLeft" x1="0%" y1="0%" x2="100%" y2="0%">
                          <stop offset="0%" stopColor="#22c55e" stopOpacity="0.85" />
                          <stop offset="70%" stopColor="#39ff14" stopOpacity="0.95" />
                          <stop offset="100%" stopColor="#6eff3b" stopOpacity="1" />
                        </linearGradient>
                      </defs>
                      {/* Left half of massive symmetrical inkblot splat */}
                      <g fill="url(#splatGradLeft)">
                        {/* Main central organic body meeting the hinge at x=300 */}
                        <path d="M 300 80 C 260 85 240 110 210 120 C 170 135 150 110 120 130 C 85 155 70 190 90 220 C 110 250 140 230 170 250 C 200 270 230 250 260 275 C 280 290 290 280 300 285 Z" />
                        
                        {/* Left splatter droplets & tendrils */}
                        <circle cx="85" cy="115" r="9" />
                        <circle cx="55" cy="140" r="14" />
                        <circle cx="40" cy="180" r="7" />
                        <circle cx="60" cy="245" r="11" />
                        <circle cx="105" cy="275" r="16" />
                        <circle cx="130" cy="90" r="8" />
                        <circle cx="160" cy="65" r="13" />
                        <circle cx="210" cy="70" r="9" />
                        <circle cx="95" cy="70" r="5" />
                        <circle cx="45" cy="215" r="6" />

                        {/* Splat tendril branches */}
                        <path d="M 120 130 Q 90 110 65 135 Q 85 150 110 140 Z" />
                        <path d="M 170 250 Q 140 290 110 280 Q 130 260 160 245 Z" />
                        <path d="M 210 120 Q 180 80 160 70 Q 170 100 200 115 Z" />
                      </g>

                      {/* Inner luminous acid core highlight */}
                      <g fill="#bbf7d0" opacity="0.6">
                        <ellipse cx="280" cy="180" rx="35" ry="55" />
                        <circle cx="210" cy="165" r="12" />
                        <circle cx="225" cy="210" r="14" />
                      </g>

                      {/* Left half squashed fly debris at the seam */}
                      <g opacity="0.85">
                        <ellipse cx="295" cy="180" rx="15" ry="26" fill="#18181b" stroke="#000" strokeWidth="2" />
                        {/* Squashed wing remnants */}
                        <ellipse cx="270" cy="165" rx="20" ry="10" transform="rotate(-25 270 165)" fill="#67e8f9" opacity="0.45" stroke="#0284c7" strokeWidth="1.5" />
                        <ellipse cx="272" cy="195" rx="18" ry="9" transform="rotate(25 272 195)" fill="#67e8f9" opacity="0.45" stroke="#0284c7" strokeWidth="1.5" />
                        {/* Comic bent leg */}
                        <path d="M 285 170 L 260 150 L 245 155" stroke="#18181b" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                        <path d="M 285 190 L 255 210 L 240 205" stroke="#18181b" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                        {/* Dizzy X eye */}
                        <line x1="285" y1="173" x2="293" y2="181" stroke="#ef4444" strokeWidth="2.5" strokeLinecap="round" />
                        <line x1="293" y1="173" x2="285" y2="181" stroke="#ef4444" strokeWidth="2.5" strokeLinecap="round" />
                      </g>
                    </svg>
                  </motion.div>
                </div>
              )}

              {/* Bottom Interactive Element: Digital Sponge wipe button */}
              <div className="relative z-30 p-2 sm:p-3 flex items-center justify-between">
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    handleWipeScreen();
                  }}
                  className={`flex items-center gap-1.5 px-2.5 py-1 sm:px-3 sm:py-1.5 rounded-lg border text-[10px] sm:text-xs font-mono transition shadow-md ${
                    phoneState === 'splatted'
                      ? 'bg-comic-yellow text-black border-yellow-300 font-bold animate-bounce shadow-comic-sm'
                      : 'bg-zinc-900/80 text-zinc-400 border-zinc-800 hover:text-zinc-200 hover:bg-zinc-800'
                  }`}
                  title="Digital Sponge: Wipe the screen clean!"
                >
                  <span className="text-sm">🧽</span>
                  <span>{phoneState === 'splatted' ? 'WIPE SCREEN' : 'SPONGE'}</span>
                </button>

                <span className="text-[9px] text-zinc-600 font-mono hidden md:inline">
                  COREMOTION 60FPS
                </span>
              </div>
            </motion.div>

            {/* =========================================
                CENTER PHYSICAL HINGE MECHANISM
                ========================================= */}
            <div className="relative w-4 sm:w-5 h-full bg-gradient-to-r from-zinc-950 via-zinc-700 to-zinc-950 z-20 flex flex-col justify-between items-center py-2 shadow-2xl border-x border-zinc-950">
              {/* Top micro-gear mechanical notch */}
              <div className="w-2.5 sm:w-3 h-4 rounded-sm bg-zinc-900 border border-zinc-600/70" />

              {/* Vertical Laser Micro-Etching on Hinge */}
              <div className="h-32 w-[1px] bg-gradient-to-b from-transparent via-zinc-400/30 to-transparent" />
              <div className="text-[7px] text-zinc-500 font-mono rotate-90 tracking-widest hidden sm:block">
                DUO-HINGE
              </div>
              <div className="h-32 w-[1px] bg-gradient-to-b from-transparent via-zinc-400/30 to-transparent" />

              {/* Bottom micro-gear mechanical notch */}
              <div className="w-2.5 sm:w-3 h-4 rounded-sm bg-zinc-900 border border-zinc-600/70" />
            </div>

            {/* =========================================
                RIGHT SCREEN (Rotates Y around Left edge)
                ========================================= */}
            <motion.div
              className="relative w-1/2 h-full rounded-r-[20px] sm:rounded-r-[22px] bg-[#07090e] overflow-hidden border-l border-zinc-900/90 shadow-inner flex flex-col justify-between"
              style={{
                transformOrigin: 'left center',
                transformStyle: 'preserve-3d',
                backfaceVisibility: 'hidden',
              }}
              animate={{
                rotateY: phoneState === 'folding' ? -88 : 0,
              }}
              transition={
                phoneState === 'folding'
                  ? { duration: 0.22, ease: [0.4, 0, 0.2, 1] }
                  : { type: 'spring', stiffness: 260, damping: 18 }
              }
            >
              {/* Screen Glare & Vignette */}
              <div className="absolute inset-0 bg-gradient-to-tl from-transparent via-white/[0.02] to-white/[0.06] pointer-events-none z-30" />
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_right,#101422_0%,#05060a_100%)] opacity-90 pointer-events-none" />

              {/* Arcade Grid Overlay */}
              <div className="absolute inset-0 arcade-grid opacity-30 pointer-events-none" />

              {/* Status Bar: Right Screen */}
              <div className="relative z-20 flex items-center justify-between px-3 sm:px-4 pt-2.5 text-[10px] sm:text-xs font-mono text-zinc-500">
                <span className="flex items-center gap-1 text-[9px] px-1.5 py-0.5 rounded bg-zinc-900 border border-zinc-800 text-zinc-400">
                  DUO R <Zap className="w-2.5 h-2.5 text-splat-green" />
                </span>
                <span className="flex items-center gap-1 font-bold text-zinc-400">
                  98%
                  <span className="w-4 h-2 border border-zinc-500 rounded-sm p-[1px] flex items-center">
                    <span className="w-full h-full bg-splat-green rounded-[1px]" />
                  </span>
                </span>
              </div>

              {/* Crosshair / Target Reticle Graphic */}
              <div className="absolute inset-0 flex items-center justify-start pointer-events-none pl-0 opacity-20">
                <div className="w-48 h-48 sm:w-64 sm:h-64 rounded-full border border-dashed border-red-500/50 flex items-center justify-center">
                  <div className="w-24 h-24 sm:w-36 sm:h-36 rounded-full border border-red-500/40" />
                </div>
              </div>

              {/* Symmetrical Right Inkblot Splat (Mirror Image of Left) */}
              {phoneState === 'splatted' && (
                <div className="absolute inset-0 flex items-center justify-start z-20 pointer-events-none overflow-hidden pl-0">
                  <motion.div
                    initial={{ scale: 0.2, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ type: 'spring', stiffness: 350, damping: 15 }}
                    className="w-full h-full flex items-center justify-start"
                  >
                    <svg
                      viewBox="0 0 300 360"
                      className="w-full h-full max-h-[380px] text-splat-green filter drop-shadow-[0_0_20px_rgba(57,255,20,0.7)]"
                    >
                      <defs>
                        <linearGradient id="splatGradRight" x1="100%" y1="0%" x2="0%" y2="0%">
                          <stop offset="0%" stopColor="#22c55e" stopOpacity="0.85" />
                          <stop offset="70%" stopColor="#39ff14" stopOpacity="0.95" />
                          <stop offset="100%" stopColor="#6eff3b" stopOpacity="1" />
                        </linearGradient>
                      </defs>
                      {/* Mirrored right half of symmetrical inkblot splat */}
                      <g fill="url(#splatGradRight)" transform="translate(300, 0) scale(-1, 1)">
                        <path d="M 300 80 C 260 85 240 110 210 120 C 170 135 150 110 120 130 C 85 155 70 190 90 220 C 110 250 140 230 170 250 C 200 270 230 250 260 275 C 280 290 290 280 300 285 Z" />
                        
                        <circle cx="85" cy="115" r="9" />
                        <circle cx="55" cy="140" r="14" />
                        <circle cx="40" cy="180" r="7" />
                        <circle cx="60" cy="245" r="11" />
                        <circle cx="105" cy="275" r="16" />
                        <circle cx="130" cy="90" r="8" />
                        <circle cx="160" cy="65" r="13" />
                        <circle cx="210" cy="70" r="9" />
                        <circle cx="95" cy="70" r="5" />
                        <circle cx="45" cy="215" r="6" />

                        <path d="M 120 130 Q 90 110 65 135 Q 85 150 110 140 Z" />
                        <path d="M 170 250 Q 140 290 110 280 Q 130 260 160 245 Z" />
                        <path d="M 210 120 Q 180 80 160 70 Q 170 100 200 115 Z" />
                      </g>

                      {/* Mirrored inner luminous acid core highlight */}
                      <g fill="#bbf7d0" opacity="0.6" transform="translate(300, 0) scale(-1, 1)">
                        <ellipse cx="280" cy="180" rx="35" ry="55" />
                        <circle cx="210" cy="165" r="12" />
                        <circle cx="225" cy="210" r="14" />
                      </g>

                      {/* Right half squashed fly debris at the seam */}
                      <g opacity="0.85" transform="translate(300, 0) scale(-1, 1)">
                        <ellipse cx="295" cy="180" rx="15" ry="26" fill="#18181b" stroke="#000" strokeWidth="2" />
                        <ellipse cx="270" cy="165" rx="20" ry="10" transform="rotate(-25 270 165)" fill="#67e8f9" opacity="0.45" stroke="#0284c7" strokeWidth="1.5" />
                        <ellipse cx="272" cy="195" rx="18" ry="9" transform="rotate(25 272 195)" fill="#67e8f9" opacity="0.45" stroke="#0284c7" strokeWidth="1.5" />
                        <path d="M 285 170 L 260 150 L 245 155" stroke="#18181b" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                        <path d="M 285 190 L 255 210 L 240 205" stroke="#18181b" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                        <line x1="285" y1="173" x2="293" y2="181" stroke="#ef4444" strokeWidth="2.5" strokeLinecap="round" />
                        <line x1="293" y1="173" x2="285" y2="181" stroke="#ef4444" strokeWidth="2.5" strokeLinecap="round" />
                      </g>
                    </svg>
                  </motion.div>
                </div>
              )}

              {/* Bottom Info HUD */}
              <div className="relative z-30 p-2 sm:p-3 flex items-center justify-end">
                <div className="flex items-center gap-2 text-[10px] sm:text-xs font-mono text-zinc-400">
                  <span className="hidden sm:inline text-zinc-600">IMPACT READY:</span>
                  <span className="px-2 py-0.5 rounded bg-zinc-900 border border-zinc-800 text-splat-green font-bold">
                    {phoneState === 'splatted' ? 'SPLATTED!' : 'MACH 2'}
                  </span>
                </div>
              </div>
            </motion.div>

            {/* =========================================
                THE ANIMATED SVG FLY (BUZZING FREELY)
                ========================================= */}
            {phoneState === 'idle' && (
              <motion.div
                className="absolute inset-0 z-40 pointer-events-none flex items-center justify-center"
                initial={{ x: 0, y: 0 }}
                animate={{
                  x: [0, 110, -90, 60, -120, 40, -40, 130, 0],
                  y: [0, -70, 60, -90, -20, 80, -60, 40, 0],
                  rotate: [0, 35, -40, 65, -30, 45, -20, 50, 0],
                }}
                transition={{
                  duration: 7,
                  repeat: Infinity,
                  ease: 'easeInOut',
                }}
              >
                {/* Comic Buzz lines and SVG Fly */}
                <div className="relative">
                  {/* Subtle cartoon buzz trail */}
                  <motion.div
                    animate={{ opacity: [0.2, 0.8, 0.2], scale: [0.9, 1.1, 0.9] }}
                    transition={{ repeat: Infinity, duration: 0.15 }}
                    className="absolute -inset-2 rounded-full border border-dashed border-comic-yellow/40 pointer-events-none"
                  />

                  {/* Cartoon Fly SVG */}
                  <svg
                    width="64"
                    height="64"
                    viewBox="0 0 64 64"
                    className="w-12 h-12 sm:w-16 sm:h-16 filter drop-shadow-[0_4px_8px_rgba(0,0,0,0.8)]"
                  >
                    {/* Articulated Fly Legs */}
                    <g stroke="#1e293b" strokeWidth="2.5" strokeLinecap="round" fill="none">
                      {/* Left legs */}
                      <path d="M 26 26 L 12 18 L 6 24" />
                      <path d="M 25 32 L 10 32 L 4 38" />
                      <path d="M 26 38 L 12 46 L 8 54" />
                      {/* Right legs */}
                      <path d="M 38 26 L 52 18 L 58 24" />
                      <path d="M 39 32 L 54 32 L 60 38" />
                      <path d="M 38 38 L 52 46 L 56 54" />
                    </g>

                    {/* Translucent Vibrating Wings */}
                    <g>
                      {/* Left Wing */}
                      <motion.ellipse
                        cx="22"
                        cy="22"
                        rx="16"
                        ry="8"
                        transform="rotate(-40 22 22)"
                        fill="rgba(186, 230, 253, 0.75)"
                        stroke="#38bdf8"
                        strokeWidth="1.5"
                        animate={{
                          scaleY: [1, 0.15, 1],
                          rotate: [-40, -55, -40],
                        }}
                        transition={{
                          repeat: Infinity,
                          duration: 0.07,
                          ease: 'easeInOut',
                        }}
                      />
                      {/* Right Wing */}
                      <motion.ellipse
                        cx="42"
                        cy="22"
                        rx="16"
                        ry="8"
                        transform="rotate(40 42 22)"
                        fill="rgba(186, 230, 253, 0.75)"
                        stroke="#38bdf8"
                        strokeWidth="1.5"
                        animate={{
                          scaleY: [1, 0.15, 1],
                          rotate: [40, 55, 40],
                        }}
                        transition={{
                          repeat: Infinity,
                          duration: 0.07,
                          ease: 'easeInOut',
                        }}
                      />
                    </g>

                    {/* Fly Abdomen (Striped bug body) */}
                    <ellipse cx="32" cy="40" rx="10" ry="14" fill="#0f172a" stroke="#020617" strokeWidth="1.5" />
                    <line x1="24" y1="36" x2="40" y2="36" stroke="#eab308" strokeWidth="2" strokeLinecap="round" />
                    <line x1="23" y1="42" x2="41" y2="42" stroke="#eab308" strokeWidth="2" strokeLinecap="round" />
                    <line x1="26" y1="48" x2="38" y2="48" stroke="#eab308" strokeWidth="2" strokeLinecap="round" />

                    {/* Fly Thorax */}
                    <ellipse cx="32" cy="27" rx="9" ry="8" fill="#1e293b" stroke="#0f172a" strokeWidth="1.5" />

                    {/* Fly Head */}
                    <circle cx="32" cy="18" r="6.5" fill="#0f172a" />

                    {/* Giant Ruby Compound Eyes */}
                    <ellipse cx="28" cy="16" rx="4" ry="5" fill="#dc2626" />
                    <ellipse cx="36" cy="16" rx="4" ry="5" fill="#dc2626" />
                    {/* Eye specular glare dots */}
                    <circle cx="27" cy="14" r="1.5" fill="#fff" />
                    <circle cx="35" cy="14" r="1.5" fill="#fff" />

                    {/* Antennae */}
                    <path d="M 29 12 Q 25 6 22 7" stroke="#334155" strokeWidth="1.5" strokeLinecap="round" fill="none" />
                    <path d="M 35 12 Q 39 6 42 7" stroke="#334155" strokeWidth="1.5" strokeLinecap="round" fill="none" />
                  </svg>
                </div>
              </motion.div>
            )}

            {/* =========================================
                DYNAMIC "SPLAT!" COMIC TEXT POP-UP
                ========================================= */}
            <AnimatePresence>
              {phoneState === 'splatted' && (
                <motion.div
                  key={`splat-${splatSeed}`}
                  className="absolute inset-0 z-50 flex items-center justify-center pointer-events-none"
                  initial={{ scale: 0, rotate: -35, opacity: 0 }}
                  animate={{ scale: [0, 1.35, 1], rotate: [-35, 12, -6], opacity: 1 }}
                  exit={{ scale: 0, opacity: 0 }}
                  transition={{
                    type: 'spring',
                    stiffness: 450,
                    damping: 14,
                    duration: 0.4,
                  }}
                >
                  <div className="relative flex items-center justify-center">
                    {/* Comic 16-point Action Starburst */}
                    <div className="absolute w-44 h-44 sm:w-56 sm:h-56">
                      <svg viewBox="0 0 100 100" className="w-full h-full filter drop-shadow-[0_8px_16px_rgba(0,0,0,0.9)] animate-spin-slow">
                        <polygon
                          points="50,0 62,28 92,15 78,42 100,56 74,68 85,96 58,82 48,100 38,82 12,94 24,67 0,55 22,42 8,14 38,28"
                          fill="#ffe600"
                          stroke="#000000"
                          strokeWidth="3"
                        />
                        <polygon
                          points="50,6 60,30 86,18 74,42 94,55 70,66 80,90 56,78 48,94 40,78 16,88 28,64 6,54 26,42 14,18 40,30"
                          fill="#ff5e00"
                          opacity="0.9"
                        />
                      </svg>
                    </div>

                    {/* "SPLAT!" Bold Action Typography */}
                    <div className="relative z-10 px-6 py-2 transform -rotate-6">
                      <span className="block font-black text-4xl sm:text-6xl md:text-7xl italic tracking-tighter text-splat-green comic-outline-thick drop-shadow-[0_6px_0_#000]">
                        SPLAT!
                      </span>
                      <span className="block text-center font-black text-xs sm:text-sm tracking-widest text-comic-yellow comic-outline uppercase">
                        CRUSHED AT MACH 2!
                      </span>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

          </div>
        </div>
      </motion.div>

      {/* Main Action Trigger Buttons */}
      <div className="mt-4 flex flex-col sm:flex-row items-center justify-center gap-3 w-full max-w-md">
        {phoneState === 'splatted' ? (
          <button
            onClick={handleWipeScreen}
            className="w-full sm:w-auto flex-1 flex items-center justify-center gap-2.5 px-7 py-3.5 rounded-xl bg-comic-yellow text-black font-black text-base sm:text-lg tracking-wider uppercase border-2 border-black shadow-comic hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition active:bg-yellow-400"
          >
            <RefreshCw className="w-5 h-5 text-black animate-spin" />
            <span>WIPE SCREEN (SPONGE) 🧽</span>
          </button>
        ) : (
          <button
            onClick={triggerSmash}
            disabled={phoneState === 'folding'}
            className="w-full sm:w-auto flex-1 flex items-center justify-center gap-2.5 px-8 py-3.5 rounded-xl bg-gradient-to-r from-splat-green to-emerald-400 text-black font-black text-base sm:text-lg tracking-wider uppercase border-2 border-black shadow-comic hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition active:scale-95 disabled:opacity-50"
          >
            <Zap className="w-5 h-5 fill-black" />
            <span>SQUASH IT! 💥</span>
          </button>
        )}
      </div>

      {/* Interactive Helper Hint */}
      <p className="mt-2 text-xs font-mono text-zinc-500 text-center">
        💡 <span className="text-zinc-400">Pro-Tip:</span> Click directly anywhere on the foldable phone to trigger the physical 3D closing snap!
      </p>
    </div>
  );
}
