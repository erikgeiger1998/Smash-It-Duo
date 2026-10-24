'use client';

import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Volume2,
  VolumeX,
  Zap,
  RotateCcw,
  Sparkles,
  ShieldAlert,
  Pause,
  Settings,
  Heart,
  Flame,
} from 'lucide-react';

type DemoStage = 'hunt' | 'clap' | 'buzz' | 'reveal' | 'wipe';

export default function LiveFoldableDemo() {
  const [stage, setStage] = useState<DemoStage>('hunt');
  const [soundEnabled, setSoundEnabled] = useState<boolean>(true);
  const [manualTriggerCount, setManualTriggerCount] = useState<number>(0);
  const [score, setScore] = useState<number>(5900);
  const [wave, setWave] = useState<number>(6);
  const [shake, setShake] = useState<boolean>(false);
  const audioCtxRef = useRef<AudioContext | null>(null);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  // Synthesize game sounds via Web Audio API (zero external mp3/video files)
  const playSound = (type: 'buzz' | 'clap' | 'haptic' | 'wipe' | 'cheer') => {
    if (!soundEnabled || typeof window === 'undefined') return;
    try {
      const AudioContextClass =
        window.AudioContext ||
        (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (!audioCtxRef.current) {
        audioCtxRef.current = new AudioContextClass();
      }
      const ctx = audioCtxRef.current;
      if (ctx.state === 'suspended') {
        ctx.resume();
      }

      const now = ctx.currentTime;

      if (type === 'clap') {
        // Heavy kinetic slam sub-bass + high snap
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(160, now);
        osc.frequency.exponentialRampToValueAtTime(30, now + 0.18);
        gain.gain.setValueAtTime(0.9, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.22);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 0.23);

        // Wet squish noise burst
        const bufferSize = Math.floor(ctx.sampleRate * 0.16);
        const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
          data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (ctx.sampleRate * 0.04));
        }
        const noise = ctx.createBufferSource();
        noise.buffer = buffer;
        const filter = ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(1400, now);
        filter.frequency.exponentialRampToValueAtTime(250, now + 0.16);

        const noiseGain = ctx.createGain();
        noiseGain.gain.setValueAtTime(0.8, now);
        noiseGain.gain.exponentialRampToValueAtTime(0.001, now + 0.16);
        noise.connect(filter);
        filter.connect(noiseGain);
        noiseGain.connect(ctx.destination);
        noise.start(now + 0.01);
      } else if (type === 'haptic') {
        // Decaying CoreHaptics insect death vibration (1.5s flutter)
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(85, now);
        osc.frequency.linearRampToValueAtTime(45, now + 0.7);

        // Amplitude modulated pulse (bzzz-bz-bz)
        gain.gain.setValueAtTime(0.18, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.75);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 0.8);
      } else if (type === 'wipe') {
        // Rubber sponge squeak
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(450, now);
        osc.frequency.linearRampToValueAtTime(880, now + 0.12);
        osc.frequency.linearRampToValueAtTime(560, now + 0.25);
        gain.gain.setValueAtTime(0.18, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.28);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 0.28);
      }
    } catch {
      // Audio fallback
    }
  };

  // Continuous 4-Stage Automated Loop Sequence
  useEffect(() => {
    let t1: NodeJS.Timeout;
    let t2: NodeJS.Timeout;
    let t3: NodeJS.Timeout;
    let t4: NodeJS.Timeout;
    let t5: NodeJS.Timeout;

    if (stage === 'hunt') {
      // Fly buzzes and lands on the watermelon for 2.5s -> Trigger Clap
      t1 = setTimeout(() => {
        setStage('clap');
      }, 2500);
    } else if (stage === 'clap') {
      // Physical snap shut (0.5s duration)
      playSound('clap');
      setShake(true);
      setTimeout(() => setShake(false), 350);

      t2 = setTimeout(() => {
        setStage('buzz');
      }, 500);
    } else if (stage === 'buzz') {
      // Phone closed, haptic death throes (0.8s)
      playSound('haptic');
      t3 = setTimeout(() => {
        setStage('reveal');
      }, 800);
    } else if (stage === 'reveal') {
      // Phone unfolds flat, massive splat revealed for 1.8s
      setScore((prev) => prev + 1750);
      t4 = setTimeout(() => {
        setStage('wipe');
      }, 2000);
    } else if (stage === 'wipe') {
      // Cartoon sponge sweeps screen for 0.9s, then loop back to hunt
      playSound('wipe');
      t5 = setTimeout(() => {
        setStage('hunt');
      }, 1000);
    }

    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
      clearTimeout(t4);
      clearTimeout(t5);
    };
  }, [stage, manualTriggerCount]);

  // Interactive User Override
  const handleManualClap = () => {
    if (stage === 'clap' || stage === 'buzz') return;
    setStage('clap');
    setManualTriggerCount((prev) => prev + 1);
  };

  const isClosed = stage === 'clap' || stage === 'buzz';

  return (
    <div className="relative flex flex-col items-center w-full max-w-5xl mx-auto px-4 select-none">
      
      {/* Top Hardware Telemetry Bar */}
      <div className="w-full flex items-center justify-between mb-4 px-3 text-xs font-mono">
        <div className="flex items-center gap-2">
          <span className="flex h-2.5 w-2.5 relative">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-bugJuice opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-bugJuice"></span>
          </span>
          <span className="text-zinc-400 uppercase tracking-wider hidden sm:inline">
            SIMULATION MODE: <span className="text-bugJuice font-bold">ACTIVE 60FPS</span>
          </span>
          <span className="text-zinc-500 text-[10px] sm:text-xs">
            {stage === 'hunt' && 'STAGE 1: THE HUNT'}
            {stage === 'clap' && 'STAGE 2: THE 3D CLAP'}
            {stage === 'buzz' && 'STAGE 3: COREHAPTICS BUZZ'}
            {stage === 'reveal' && 'STAGE 4: SYMMETRICAL REVEAL'}
            {stage === 'wipe' && 'STAGE 5: SPONGE RESET'}
          </span>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => setSoundEnabled(!soundEnabled)}
            className="flex items-center gap-1.5 px-3 py-1 rounded-lg bg-obsidian-850 border border-obsidian-border text-zinc-300 hover:text-white hover:border-bugJuice transition"
            title={soundEnabled ? 'Mute simulated audio' : 'Unmute simulated audio'}
          >
            {soundEnabled ? (
              <Volume2 className="w-3.5 h-3.5 text-bugJuice" />
            ) : (
              <VolumeX className="w-3.5 h-3.5 text-zinc-500" />
            )}
            <span className="text-[10px] hidden sm:inline">{soundEnabled ? 'AUDIO ON' : 'MUTED'}</span>
          </button>
        </div>
      </div>

      {/* 3D Perspective Stage Container with Camera Screen-Shake */}
      <motion.div
        animate={
          shake
            ? {
                x: [0, -18, 20, -15, 12, -6, 0],
                y: [0, 10, -14, 8, -6, 3, 0],
                rotate: [0, -2.5, 3, -1.8, 1.2, 0],
                scale: [1, 1.05, 0.97, 1.02, 1],
              }
            : { x: 0, y: 0, rotate: 0, scale: 1 }
        }
        transition={{ duration: 0.35, ease: 'easeInOut' }}
        className="w-full flex justify-center py-4 cursor-pointer"
        style={{ perspective: '1400px' }}
        onClick={handleManualClap}
      >
        {/* ========================================================
            IPHONE DUO PHYSICAL HARDWARE CHASSIS (Landscape Open)
            ======================================================== */}
        <div className="relative w-full max-w-[820px] h-[360px] sm:h-[440px] md:h-[480px] p-2.5 sm:p-3.5 rounded-[36px] sm:rounded-[44px] bg-gradient-to-b from-zinc-600 via-zinc-800 to-zinc-950 shadow-[0_25px_60px_rgba(0,0,0,0.95),0_0_25px_rgba(30,41,59,0.5)] border-2 border-zinc-600/70 preserve-3d">
          
          {/* External Hardware Edge Buttons */}
          <div className="absolute -top-1.5 right-20 w-12 h-1.5 bg-zinc-700 rounded-t-sm" />
          <div className="absolute -right-1.5 top-28 w-1.5 h-14 bg-zinc-700 rounded-r-sm" />

          {/* Radiating Neon Soundwaves during Stage 3 Haptic Buzz */}
          <AnimatePresence>
            {stage === 'buzz' && (
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: [0.3, 0.9, 0.3], scale: [0.95, 1.08, 0.95] }}
                exit={{ opacity: 0 }}
                transition={{ repeat: Infinity, duration: 0.18 }}
                className="absolute -inset-4 sm:-inset-6 rounded-[50px] border-4 border-dashed border-bugJuice/60 pointer-events-none z-50 flex items-center justify-center"
              >
                <div className="px-4 py-1.5 rounded-full bg-black/90 border border-bugJuice text-bugJuice font-mono font-black text-xs uppercase tracking-widest shadow-neon-green animate-pulse">
                  ⚡ COREHAPTICS: BZZZZ-BZZ-BZ...
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Internal Display Bezel Shell */}
          <div className="relative w-full h-full rounded-[28px] sm:rounded-[36px] bg-black p-1.5 sm:p-2 overflow-hidden flex preserve-3d">
            
            {/* ========================================================
                LEFT SCREEN (Folds forward around right hinge edge)
                ======================================================== */}
            <motion.div
              className="relative w-1/2 h-full rounded-l-[24px] sm:rounded-l-[28px] overflow-hidden border-r border-black/80 shadow-inner flex flex-col justify-between wood-plank-bg"
              style={{
                transformOrigin: 'right center',
                transformStyle: 'preserve-3d',
                backfaceVisibility: 'hidden',
              }}
              animate={{
                rotateY: isClosed ? 85 : 0,
              }}
              transition={
                isClosed
                  ? { duration: 0.22, ease: [0.4, 0, 0.2, 1] }
                  : { type: 'spring', stiffness: 280, damping: 18 }
              }
            >
              {/* Wood Plank Horizontal Grooves */}
              <div className="absolute inset-0 bg-gradient-to-r from-black/20 via-transparent to-black/30 pointer-events-none z-10" />

              {/* Red-and-White Checkered Picnic Gingham Runner along left edge */}
              <div className="absolute left-0 top-0 bottom-0 w-12 sm:w-16 picnic-gingham shadow-[2px_0_8px_rgba(0,0,0,0.5)] border-r border-red-800/40 z-10" />

              {/* Screen Glass Reflection Sheen */}
              <div className="absolute inset-0 bg-gradient-to-tr from-transparent via-white/[0.04] to-white/[0.08] pointer-events-none z-30" />

              {/* Left Screen Portion of the Watermelon Bait (meets hinge at right border) */}
              <div className="absolute inset-0 flex items-center justify-end pointer-events-none z-20 pr-0">
                <svg width="90" height="90" viewBox="0 0 90 90" className="translate-x-0 filter drop-shadow-[0_8px_12px_rgba(0,0,0,0.6)]">
                  {/* Left half of sliced watermelon */}
                  <defs>
                    <clipPath id="leftHalfClip">
                      <rect x="0" y="0" width="90" height="90" />
                    </clipPath>
                  </defs>
                  <g clipPath="url(#leftHalfClip)">
                    {/* Dark Green Outer Rind */}
                    <path d="M 90 20 A 70 70 0 0 0 20 90 L 90 90 Z" fill="#15803d" stroke="#14532d" strokeWidth="2" />
                    {/* Light Green / White Inner Rind */}
                    <path d="M 90 26 A 64 64 0 0 0 26 90 L 90 90 Z" fill="#bbf7d0" />
                    {/* Juicy Crimson Pulp */}
                    <path d="M 90 32 A 58 58 0 0 0 32 90 L 90 90 Z" fill="#ef4444" />
                    {/* Watermelon Seeds */}
                    <ellipse cx="65" cy="55" rx="2.5" ry="4" transform="rotate(-30 65 55)" fill="#18181b" />
                    <ellipse cx="50" cy="72" rx="2.5" ry="4" transform="rotate(-60 50 72)" fill="#18181b" />
                    <ellipse cx="78" cy="72" rx="2.5" ry="4" transform="rotate(-15 78 72)" fill="#18181b" />
                  </g>
                </svg>
              </div>

              {/* Symmetrical Left Inkblot Splat (Revealed in Stage 4) */}
              {(stage === 'reveal' || stage === 'wipe') && (
                <div className="absolute inset-0 flex items-center justify-end z-25 pointer-events-none pr-0">
                  <motion.div
                    initial={{ scale: 0.1, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ type: 'spring', stiffness: 400, damping: 14 }}
                    className="w-full h-full flex items-center justify-end"
                  >
                    <svg viewBox="0 0 260 300" className="w-full h-full max-h-[340px] filter drop-shadow-[0_0_18px_rgba(57,255,20,0.8)]">
                      {/* Left half yellow action starburst */}
                      <g fill="#FFD700" stroke="#000" strokeWidth="2.5">
                        <polygon points="260,60 210,85 240,115 180,130 220,165 170,185 220,225 180,245 260,260" />
                      </g>

                      {/* Left half neon green bug juice splat */}
                      <g fill="#39FF14" stroke="#15803d" strokeWidth="1.5">
                        <path d="M 260 90 C 220 95 190 120 170 135 C 130 150 110 130 80 160 C 50 190 80 220 120 225 C 160 230 190 215 220 235 C 240 245 250 240 260 245 Z" />
                        <circle cx="65" cy="140" r="10" />
                        <circle cx="45" cy="175" r="7" />
                        <circle cx="60" cy="210" r="12" />
                        <circle cx="100" cy="245" r="8" />
                        <circle cx="130" cy="115" r="9" />
                        <circle cx="160" cy="95" r="6" />
                        <circle cx="85" cy="105" r="5" />
                      </g>

                      {/* Luminous Acid Yellow Core */}
                      <g fill="#eab308" opacity="0.8">
                        <ellipse cx="240" cy="175" rx="30" ry="45" />
                        <circle cx="180" cy="165" r="10" />
                      </g>

                      {/* Squashed Fly Body & X X Eyes at the crease */}
                      <g>
                        <ellipse cx="255" cy="175" rx="14" ry="24" fill="#090a0f" stroke="#000" strokeWidth="2" />
                        {/* Twisted legs */}
                        <path d="M 245 160 L 220 140 L 205 145" stroke="#090a0f" strokeWidth="3" strokeLinecap="round" fill="none" />
                        <path d="M 245 190 L 215 210 L 200 205" stroke="#090a0f" strokeWidth="3" strokeLinecap="round" fill="none" />
                        {/* Red X Eye */}
                        <line x1="244" y1="168" x2="252" y2="176" stroke="#ef4444" strokeWidth="3" strokeLinecap="round" />
                        <line x1="252" y1="168" x2="244" y2="176" stroke="#ef4444" strokeWidth="3" strokeLinecap="round" />
                      </g>
                    </svg>
                  </motion.div>
                </div>
              )}

              {/* Bottom In-Game Status (Left) */}
              <div className="relative z-30 p-2 sm:p-3 flex items-center justify-between">
                <span className="text-[10px] font-mono text-amber-200/80 bg-black/50 px-2 py-0.5 rounded border border-white/10">
                  DUO-L • 120Hz
                </span>
                <span className="text-[10px] font-mono text-zinc-400 hidden sm:inline">
                  WATERMELON BAIT ACTIVE
                </span>
              </div>
            </motion.div>

            {/* ========================================================
                CENTER VERTICAL HINGE CREASE SHADOW
                ======================================================== */}
            <div className="relative w-3.5 sm:w-4 h-full bg-gradient-to-r from-zinc-950 via-zinc-700 to-zinc-950 z-20 flex flex-col justify-between items-center py-2 shadow-2xl border-x border-black">
              <div className="w-2 sm:w-2.5 h-3.5 rounded-sm bg-zinc-900 border border-zinc-600" />
              <div className="h-28 w-[1px] bg-gradient-to-b from-transparent via-zinc-400/40 to-transparent" />
              <div className="text-[6px] text-zinc-500 font-mono rotate-90 tracking-widest hidden sm:block">
                HINGE
              </div>
              <div className="h-28 w-[1px] bg-gradient-to-b from-transparent via-zinc-400/40 to-transparent" />
              <div className="w-2 sm:w-2.5 h-3.5 rounded-sm bg-zinc-900 border border-zinc-600" />
            </div>

            {/* ========================================================
                RIGHT SCREEN (Folds forward around left hinge edge)
                ======================================================== */}
            <motion.div
              className="relative w-1/2 h-full rounded-r-[24px] sm:rounded-r-[28px] overflow-hidden border-l border-black/80 shadow-inner flex flex-col justify-between wood-plank-bg"
              style={{
                transformOrigin: 'left center',
                transformStyle: 'preserve-3d',
                backfaceVisibility: 'hidden',
              }}
              animate={{
                rotateY: isClosed ? -85 : 0,
              }}
              transition={
                isClosed
                  ? { duration: 0.22, ease: [0.4, 0, 0.2, 1] }
                  : { type: 'spring', stiffness: 280, damping: 18 }
              }
            >
              {/* Wood Plank Horizontal Grooves */}
              <div className="absolute inset-0 bg-gradient-to-l from-black/20 via-transparent to-black/30 pointer-events-none z-10" />

              {/* Screen Glass Reflection Sheen */}
              <div className="absolute inset-0 bg-gradient-to-tl from-transparent via-white/[0.04] to-white/[0.08] pointer-events-none z-30" />

              {/* Right Camera Punch-hole Notch */}
              <div className="absolute top-3 right-3 z-30 w-3.5 h-3.5 rounded-full bg-black border border-zinc-700 flex items-center justify-center">
                <div className="w-1.5 h-1.5 rounded-full bg-blue-950/80" />
              </div>

              {/* Right Screen Portion of the Watermelon Bait (meets hinge at left border) */}
              <div className="absolute inset-0 flex items-center justify-start pointer-events-none z-20 pl-0">
                <svg width="90" height="90" viewBox="0 0 90 90" className="translate-x-0 filter drop-shadow-[0_8px_12px_rgba(0,0,0,0.6)]">
                  {/* Right half of sliced watermelon */}
                  <g transform="translate(90, 0) scale(-1, 1)">
                    <defs>
                      <clipPath id="rightHalfClip">
                        <rect x="0" y="0" width="90" height="90" />
                      </clipPath>
                    </defs>
                    <g clipPath="url(#rightHalfClip)">
                      <path d="M 90 20 A 70 70 0 0 0 20 90 L 90 90 Z" fill="#15803d" stroke="#14532d" strokeWidth="2" />
                      <path d="M 90 26 A 64 64 0 0 0 26 90 L 90 90 Z" fill="#bbf7d0" />
                      <path d="M 90 32 A 58 58 0 0 0 32 90 L 90 90 Z" fill="#ef4444" />
                      <ellipse cx="65" cy="55" rx="2.5" ry="4" transform="rotate(-30 65 55)" fill="#18181b" />
                      <ellipse cx="50" cy="72" rx="2.5" ry="4" transform="rotate(-60 50 72)" fill="#18181b" />
                      <ellipse cx="78" cy="72" rx="2.5" ry="4" transform="rotate(-15 78 72)" fill="#18181b" />
                    </g>
                  </g>
                </svg>
              </div>

              {/* Symmetrical Right Inkblot Splat (Mirror Image of Left) */}
              {(stage === 'reveal' || stage === 'wipe') && (
                <div className="absolute inset-0 flex items-center justify-start z-25 pointer-events-none pl-0">
                  <motion.div
                    initial={{ scale: 0.1, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ type: 'spring', stiffness: 400, damping: 14 }}
                    className="w-full h-full flex items-center justify-start"
                  >
                    <svg viewBox="0 0 260 300" className="w-full h-full max-h-[340px] filter drop-shadow-[0_0_18px_rgba(57,255,20,0.8)]">
                      {/* Mirrored right half */}
                      <g transform="translate(260, 0) scale(-1, 1)">
                        <g fill="#FFD700" stroke="#000" strokeWidth="2.5">
                          <polygon points="260,60 210,85 240,115 180,130 220,165 170,185 220,225 180,245 260,260" />
                        </g>

                        <g fill="#39FF14" stroke="#15803d" strokeWidth="1.5">
                          <path d="M 260 90 C 220 95 190 120 170 135 C 130 150 110 130 80 160 C 50 190 80 220 120 225 C 160 230 190 215 220 235 C 240 245 250 240 260 245 Z" />
                          <circle cx="65" cy="140" r="10" />
                          <circle cx="45" cy="175" r="7" />
                          <circle cx="60" cy="210" r="12" />
                          <circle cx="100" cy="245" r="8" />
                          <circle cx="130" cy="115" r="9" />
                          <circle cx="160" cy="95" r="6" />
                          <circle cx="85" cy="105" r="5" />
                        </g>

                        <g fill="#eab308" opacity="0.8">
                          <ellipse cx="240" cy="175" rx="30" ry="45" />
                          <circle cx="180" cy="165" r="10" />
                        </g>

                        <g>
                          <ellipse cx="255" cy="175" rx="14" ry="24" fill="#090a0f" stroke="#000" strokeWidth="2" />
                          <path d="M 245 160 L 220 140 L 205 145" stroke="#090a0f" strokeWidth="3" strokeLinecap="round" fill="none" />
                          <path d="M 245 190 L 215 210 L 200 205" stroke="#090a0f" strokeWidth="3" strokeLinecap="round" fill="none" />
                          <line x1="244" y1="168" x2="252" y2="176" stroke="#ef4444" strokeWidth="3" strokeLinecap="round" />
                          <line x1="252" y1="168" x2="244" y2="176" stroke="#ef4444" strokeWidth="3" strokeLinecap="round" />
                        </g>
                      </g>
                    </svg>
                  </motion.div>
                </div>
              )}

              {/* Bottom In-Game Status (Right) */}
              <div className="relative z-30 p-2 sm:p-3 flex items-center justify-end">
                <span className="text-[10px] font-mono text-bugJuice bg-black/50 px-2 py-0.5 rounded border border-white/10">
                  DUO-R • GYRO OK
                </span>
              </div>
            </motion.div>

            {/* ========================================================
                THE ARCADE HUD PILL AT THE TOP (Across Both Screens)
                ======================================================== */}
            <div className="absolute top-2.5 sm:top-3 left-1/2 -translate-x-1/2 z-40 flex flex-col items-center pointer-events-none w-full max-w-sm sm:max-w-md px-2">
              {/* Main Floating Arcade Pill */}
              <div className="w-full flex items-center justify-between px-3 sm:px-4 py-1.5 rounded-2xl bg-black/85 backdrop-blur-md border border-zinc-700/80 shadow-2xl text-xs font-mono">
                {/* Score */}
                <div className="flex flex-col text-left">
                  <span className="text-[8px] text-zinc-400 tracking-wider">SCORE</span>
                  <span className="font-black text-arcade-gold text-sm sm:text-base leading-none">
                    {score.toLocaleString()}
                  </span>
                </div>

                {/* Wave Badge */}
                <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-zinc-900 border border-zinc-800 text-[10px] sm:text-xs text-sky-400 font-bold">
                  <span>WAVE</span>
                  <span className="text-white">{wave}</span>
                </div>

                {/* 3 Red Hearts & Controls */}
                <div className="flex items-center gap-1.5 sm:gap-2">
                  <div className="flex items-center gap-0.5 text-red-500">
                    <Heart className="w-3.5 h-3.5 fill-red-500" />
                    <Heart className="w-3.5 h-3.5 fill-red-500" />
                    <Heart className="w-3.5 h-3.5 fill-red-500" />
                  </div>
                  <span className="w-[1px] h-3 bg-zinc-700 mx-0.5" />
                  <Pause className="w-3 h-3 text-zinc-400" />
                  <Settings className="w-3 h-3 text-zinc-400" />
                </div>
              </div>

              {/* Glowing Countdown & Warning Bar */}
              <div className="w-full mt-1.5 px-3 py-1 rounded-xl bg-black/90 border border-bugJuice/40 shadow-neon-green flex flex-col items-center">
                <div className="w-full flex items-center justify-between text-[9px] font-mono font-bold tracking-wider">
                  <span className="text-bugJuice">
                    {stage === 'clap'
                      ? '⚡ CLAP IMPACT VELOCITY: 1,420°/s'
                      : stage === 'buzz'
                      ? '📳 COREHAPTICS RECOIL DETECTED'
                      : stage === 'reveal'
                      ? '✨ SPLATTED ON WATERMELON!'
                      : 'FOLD GENTLY TO SMASH 0.65s'}
                  </span>
                  <span className="text-arcade-gold">⚠ SAFETY NOTICE</span>
                </div>
                {/* Green-to-Red Countdown Bar */}
                <div className="w-full h-1.5 rounded-full bg-zinc-900 overflow-hidden mt-1 border border-zinc-800">
                  <motion.div
                    className="h-full bg-gradient-to-r from-bugJuice via-arcade-yellow to-red-500"
                    animate={
                      stage === 'hunt'
                        ? { width: ['100%', '0%'] }
                        : { width: '100%' }
                    }
                    transition={{ duration: 2.5, ease: 'linear' }}
                  />
                </div>
              </div>
            </div>

            {/* ========================================================
                STAGE 1: ANIMATED SVG FLY (The Hunt)
                ======================================================== */}
            {stage === 'hunt' && (
              <motion.div
                className="absolute inset-0 z-35 pointer-events-none flex items-center justify-center"
                initial={{ x: 120, y: -70, rotate: 25 }}
                animate={{
                  x: [120, -110, 80, -40, 0],
                  y: [-70, 40, -50, 20, 0],
                  rotate: [25, -35, 45, -15, 0],
                }}
                transition={{
                  duration: 2.4,
                  times: [0, 0.25, 0.5, 0.75, 1],
                  ease: 'easeInOut',
                }}
              >
                <div className="relative">
                  {/* Comic Speech Bubble */}
                  <motion.div
                    initial={{ opacity: 0, y: 5 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.8 }}
                    className="absolute -top-10 left-1/2 -translate-x-1/2 px-2.5 py-1 rounded-lg bg-white text-black text-[9px] font-bold whitespace-nowrap shadow-comic-sm border border-black z-40"
                  >
                    Free watermelon! 🍉
                  </motion.div>

                  {/* Fly Drop Shadow (snaps tight under body upon landing) */}
                  <motion.ellipse
                    cx="28"
                    cy="44"
                    rx="12"
                    ry="6"
                    fill="rgba(0,0,0,0.4)"
                    animate={{
                      scale: [1.4, 0.9, 1.2, 0.8, 1],
                      opacity: [0.3, 0.7, 0.4, 0.8, 0.9],
                    }}
                    transition={{ duration: 2.4 }}
                  />

                  {/* Animated SVG Fly */}
                  <svg width="56" height="56" viewBox="0 0 56 56" className="filter drop-shadow-[0_4px_6px_rgba(0,0,0,0.6)]">
                    {/* Legs */}
                    <g stroke="#18181b" strokeWidth="2.5" strokeLinecap="round" fill="none">
                      <path d="M 22 22 L 12 14 L 6 18" />
                      <path d="M 22 28 L 8 28 L 4 34" />
                      <path d="M 22 34 L 10 42 L 6 48" />
                      <path d="M 34 22 L 44 14 L 50 18" />
                      <path d="M 34 28 L 48 28 L 52 34" />
                      <path d="M 34 34 L 46 42 L 50 48" />
                    </g>
                    {/* Rapid Oscillating Wings */}
                    <g>
                      <motion.ellipse
                        cx="18"
                        cy="18"
                        rx="14"
                        ry="7"
                        transform="rotate(-40 18 18)"
                        fill="rgba(186, 230, 253, 0.8)"
                        stroke="#38bdf8"
                        strokeWidth="1.5"
                        animate={{ scaleY: [1, 0.2, 1], rotate: [-40, -55, -40] }}
                        transition={{ repeat: Infinity, duration: 0.06 }}
                      />
                      <motion.ellipse
                        cx="38"
                        cy="18"
                        rx="14"
                        ry="7"
                        transform="rotate(40 38 18)"
                        fill="rgba(186, 230, 253, 0.8)"
                        stroke="#38bdf8"
                        strokeWidth="1.5"
                        animate={{ scaleY: [1, 0.2, 1], rotate: [40, 55, 40] }}
                        transition={{ repeat: Infinity, duration: 0.06 }}
                      />
                    </g>
                    {/* Iridescent Body */}
                    <ellipse cx="28" cy="34" rx="9" ry="12" fill="#0f172a" stroke="#020617" strokeWidth="1.5" />
                    <line x1="21" y1="30" x2="35" y2="30" stroke="#ca8a04" strokeWidth="2" strokeLinecap="round" />
                    <line x1="20" y1="35" x2="36" y2="35" stroke="#ca8a04" strokeWidth="2" strokeLinecap="round" />
                    <ellipse cx="28" cy="24" rx="8" ry="7" fill="#1e293b" />
                    <circle cx="28" cy="16" r="5.5" fill="#0f172a" />
                    {/* Big Ruby Compound Eyes */}
                    <ellipse cx="24.5" cy="14" rx="3.5" ry="4.5" fill="#dc2626" />
                    <ellipse cx="31.5" cy="14" rx="3.5" ry="4.5" fill="#dc2626" />
                    <circle cx="23.5" cy="12.5" r="1.2" fill="#ffffff" />
                    <circle cx="30.5" cy="12.5" r="1.2" fill="#ffffff" />
                  </svg>
                </div>
              </motion.div>
            )}

            {/* ========================================================
                STAGE 2: VISUAL WARNING FLASH & COMIC "CLAP!"
                ======================================================== */}
            <AnimatePresence>
              {stage === 'clap' && (
                <motion.div
                  initial={{ scale: 0, opacity: 0, rotate: -25 }}
                  animate={{ scale: [0, 1.4, 1.1], opacity: 1, rotate: [-25, 12, -4] }}
                  exit={{ scale: 0, opacity: 0 }}
                  className="absolute inset-0 z-50 flex items-center justify-center pointer-events-none"
                >
                  <div className="relative flex items-center justify-center">
                    <svg viewBox="0 0 100 100" className="w-48 h-48 sm:w-64 sm:h-64 filter drop-shadow-[0_10px_20px_rgba(0,0,0,0.9)] animate-spin-slow">
                      <polygon
                        points="50,0 62,28 92,15 78,42 100,56 74,68 85,96 58,82 48,100 38,82 12,94 24,67 0,55 22,42 8,14 38,28"
                        fill="#FF2A55"
                        stroke="#000"
                        strokeWidth="3"
                      />
                      <polygon
                        points="50,6 60,30 86,18 74,42 94,55 70,66 80,90 56,78 48,94 40,78 16,88 28,64 6,54 26,42 14,18 40,30"
                        fill="#FFD700"
                      />
                    </svg>
                    <span className="absolute z-10 font-black text-4xl sm:text-6xl text-white comic-outline-thick uppercase tracking-tighter">
                      CLAP!
                    </span>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            {/* ========================================================
                STAGE 4: REVEAL FLOATING RATING BADGE
                ======================================================== */}
            <AnimatePresence>
              {stage === 'reveal' && (
                <motion.div
                  initial={{ y: 20, opacity: 0, scale: 0.8 }}
                  animate={{ y: 0, opacity: 1, scale: 1 }}
                  exit={{ y: -10, opacity: 0 }}
                  className="absolute bottom-6 left-1/2 -translate-x-1/2 z-40 flex items-center gap-2 pointer-events-none"
                >
                  <div className="px-4 py-2 rounded-2xl bg-black/90 border-2 border-bugJuice shadow-comic flex items-center gap-2">
                    <Zap className="w-4 h-4 text-arcade-gold fill-arcade-gold animate-bounce" />
                    <span className="font-mono font-black text-xs sm:text-sm text-white">
                      ⚡ 142ms - GODLIKE!
                    </span>
                    <span className="px-2 py-0.5 rounded-md bg-bugJuice text-black font-black text-xs">
                      +1,750 PTS
                    </span>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            {/* ========================================================
                STAGE 5: CARTOON SPONGE WIPE & SOAP BUBBLES
                ======================================================== */}
            <AnimatePresence>
              {stage === 'wipe' && (
                <motion.div
                  initial={{ x: -250, y: 0 }}
                  animate={{ x: 250, y: [0, -30, 20, 0] }}
                  transition={{ duration: 0.9, ease: 'easeInOut' }}
                  className="absolute inset-0 z-45 flex items-center justify-center pointer-events-none"
                >
                  <div className="relative">
                    {/* Soap Bubbles trailing */}
                    <div className="absolute -left-12 top-0 flex gap-1">
                      <div className="w-4 h-4 rounded-full bg-cyan-200/70 border border-white animate-ping" />
                      <div className="w-6 h-6 rounded-full bg-cyan-100/60 border border-white" />
                      <div className="w-3 h-3 rounded-full bg-white/80" />
                    </div>

                    {/* Cartoon Kitchen Sponge */}
                    <div className="w-20 h-14 rounded-xl bg-gradient-to-b from-yellow-300 to-yellow-500 border-2 border-black shadow-comic flex flex-col justify-between p-1.5 transform rotate-6">
                      <div className="w-full h-2 rounded bg-emerald-600 border-b border-black" />
                      <div className="flex justify-around">
                        <div className="w-1.5 h-1.5 rounded-full bg-yellow-600/40" />
                        <div className="w-2 h-2 rounded-full bg-yellow-600/40" />
                        <div className="w-1.5 h-1.5 rounded-full bg-yellow-600/40" />
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

          </div>
        </div>
      </motion.div>

      {/* Interactive Trigger Control Pill */}
      <div className="mt-4 flex flex-col sm:flex-row items-center justify-center gap-3 w-full max-w-md">
        <button
          onClick={handleManualClap}
          disabled={isClosed}
          className="w-full flex items-center justify-center gap-3 px-8 py-4 rounded-2xl bg-gradient-to-r from-bugJuice via-emerald-400 to-bugJuice text-black font-black text-base sm:text-lg tracking-wider uppercase border-3 border-black shadow-comic-lg hover:shadow-comic hover:translate-x-1 hover:translate-y-1 transition active:scale-95 disabled:opacity-50"
        >
          <Zap className="w-5 h-5 fill-black" />
          <span>TRY IT YOURSELF: SLAM SHUT! 💥</span>
        </button>
      </div>

      <p className="mt-2 text-xs font-mono text-zinc-500 text-center">
        💡 <span className="text-zinc-400">Continuous 4-stage simulation running.</span> Tap button or click the phone anytime to interrupt and slam!
      </p>
    </div>
  );
}
