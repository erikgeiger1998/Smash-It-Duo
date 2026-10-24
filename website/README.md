# 🪰 SMASH IT! DUO — Showcase & App Store Portal

The official, ultra-modern showcase website for **"SMASH IT! The Foldable Fly Swatter"** built exclusively for the foldable iPhone Duo.

Built with **Next.js 14 (App Router)**, **TypeScript**, **Tailwind CSS**, and **Framer Motion**.

---

## 🚀 Key Highlights

1. **Live 3D Hardware Simulation (`components/LiveFoldableDemo.tsx`)**:
   - 100% code-rendered iPhone Duo with 3D CSS perspective (`1400px`) and `transform-style: preserve-3d`.
   - In-screen game matching the real iOS game: horizontal warm wood planks, red-and-white checkered picnic runner, watermelon bait slice on the central hinge crease.
   - Arcade HUD: `SCORE: 5,900`, `WAVE 6`, 3 red hearts, and `FOLD GENTLY TO SMASH: 0.65s` countdown.
   - Continuous 4-Stage Automated Loop:
     - **Stage 1 (The Hunt)**: Animated SVG fly buzzes and lands on the watermelon.
     - **Stage 2 (The Clap)**: Warning flashes, dual displays violently fold shut in 3D (`rotateY: 85° / -85°`) with motion blur, "CLAP!" comic burst, and heavy camera shake.
     - **Stage 3 (Haptic Buzz)**: Closed phone physically jitters with radiating neon soundwaves simulating CoreHaptics death throes (`"BZZZZ-BZZ-BZ..."`).
     - **Stage 4 (The Reveal)**: Springs back open flat, revealing massive symmetrical neon-green inkblot splat on both sides of the hinge crease with `⚡ 142ms - GODLIKE! +1,750 PTS` badge.
     - **Stage 5 (Sponge Wipe)**: Cartoon sponge wipes screen clean with soap bubbles and loop restarts!
   - **Interactive Mode**: "TRY IT YOURSELF: SLAM SHUT!" button to slam at any time.

2. **Interactive Feature Bento Grid**:
   - Symmetrical Inkblot Physics
   - CoreHaptics Death Throes
   - 3D Spatial Audio Buzzing
   - "Too Hard!" Easter Egg (clickable fake cracked screen overlay + "+500 Brutality Bonus")

3. **The Bestiary / Enemy Waves**:
   - Common Housefly (158 Hz | 0.75s window)
   - Stealth Mosquito (460 Hz | 0.48s window)
   - Mutant Horsefly Boss (92 Hz | Armored Double-Clap)
   - Yellowjacket Wasp (230 Hz | Trap Hazard — DO NOT CLAP)

4. **App Store Compliant Support Page (`/support`)**:
   - Kinematics & CMMotionManager sensor explanation.
   - Safety guideline: "Fold gently — velocity is measured immediately upon hinge movement".
   - Interactive FAQ Accordion.
   - Direct Contact Card for developer Erik Geiger (`support@erikgeiger.com`).

---

## 🛠 Local Development & Static Export

```bash
# Run locally
npm run dev

# Static Export for GitHub Pages
npm run build
```
Output is generated in `/out` with `.nojekyll` ready for GitHub Pages hosting.
