# 🪰 SMASH IT! — Official Promotional Website

The official, interactive promotional website for **"SMASH IT! The Foldable Fly Swatter"**, built with Next.js 14 (App Router), React, Tailwind CSS, Framer Motion, and Lucide React.

Configured for **GitHub Pages Static Export** (`output: 'export'`).

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
npm install
```

### 2. Run Local Development Server
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) to view the site in your browser.

### 3. Build & Static Export (GitHub Pages)
```bash
npm run build
```
This generates the production-ready static export inside the `/out` directory, including:
- `/out/index.html` (Marketing Home Page)
- `/out/support/index.html` (App Store Support & Contact Page)
- `/out/.nojekyll` (Ensures GitHub Pages serves `_next` assets properly)

---

## 📱 Features & Highlights

- **Interactive 3D Foldable Phone (`components/FoldablePhone.tsx`)**:
  - Landscape orientation foldable device with left screen, right screen, and center mechanical hinge.
  - 3D CSS perspective & `transform-style: preserve-3d`.
  - Pure SVG code-animated fly buzzing randomly across both displays with high-frequency wing flutter.
  - Physical 3D folding snap using `rotateY` triggered by tapping the phone or clicking "SQUASH IT!".
  - Screen shake effect, dynamic "SPLAT!" comic pop-up badge, and instant spring-rebound reveal of a massive, symmetrical neon-green SVG inkblot splat.
  - Integrated digital sponge wipe mechanic to reset the screen.
  - Synthesized Web Audio API sound effects (no external audio files needed).
- **Dark Arcade Aesthetics**:
  - Deep black palette, neon green, vibrant comic orange, and yellow accents.
  - Extruded comic typography and action dropshadows.
- **App Store Compliant Support Page (`app/support/page.tsx`)**:
  - Interactive Framer Motion FAQ accordion.
  - Styled contact inquiry form.
  - Visible support contact (`support@erikgeiger.com`).
