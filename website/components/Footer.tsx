import React from 'react';
import Link from 'next/link';
import { Smartphone, Mail, ShieldCheck } from 'lucide-react';

export default function Footer() {
  return (
    <footer className="w-full bg-arcade-950 border-t border-arcade-border/80 py-12 px-4 sm:px-6">
      <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
        
        {/* Brand & Tagline */}
        <div className="flex flex-col items-center md:items-start text-center md:text-left">
          <div className="flex items-center gap-2">
            <span className="text-xl">🪰</span>
            <span className="font-black text-lg tracking-wider text-white">
              SMASH IT<span className="text-comic-yellow">!</span>
            </span>
          </div>
          <p className="text-xs text-zinc-500 mt-1 max-w-sm">
            The world&apos;s first viral foldable smartphone fly swatter arcade experience. Snap shut at Mach 2.
          </p>
        </div>

        {/* Links & Compliance */}
        <div className="flex flex-wrap items-center justify-center gap-6 text-xs text-zinc-400">
          <Link href="/" className="hover:text-splat-green transition">
            Home
          </Link>
          <Link href="/support" className="hover:text-splat-green transition">
            Support & FAQ
          </Link>
          <a
            href="mailto:support@erikgeiger.com"
            className="flex items-center gap-1 hover:text-splat-green transition"
          >
            <Mail className="w-3.5 h-3.5" />
            <span>support@erikgeiger.com</span>
          </a>
          <span className="flex items-center gap-1 text-zinc-500">
            <ShieldCheck className="w-3.5 h-3.5 text-splat-green" />
            <span>App Store Compliant</span>
          </span>
        </div>

        {/* Copyright */}
        <div className="text-xs text-zinc-600 text-center md:text-right font-mono">
          <p>© 2026 Erik Geiger. All rights reserved.</p>
          <p className="text-[10px] text-zinc-700 mt-0.5">Designed exclusively for Foldable Smartphones</p>
        </div>

      </div>
    </footer>
  );
}
