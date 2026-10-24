'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Smartphone, HelpCircle, Download, Sparkles } from 'lucide-react';

export default function Navbar() {
  const pathname = usePathname();

  return (
    <header className="sticky top-0 z-50 w-full backdrop-blur-md bg-arcade-950/85 border-b border-arcade-border/80">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
        {/* Brand Logo */}
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-splat-green to-emerald-500 border border-black shadow-comic-sm flex items-center justify-center transform group-hover:rotate-6 transition">
            <span className="text-xl">🪰</span>
          </div>
          <div className="flex flex-col">
            <span className="font-black text-xl tracking-tight text-white group-hover:text-splat-green transition flex items-center gap-1.5">
              SMASH IT<span className="text-comic-yellow">!</span>
            </span>
            <span className="text-[9px] font-mono tracking-widest text-zinc-500 uppercase -mt-1">
              FOLDABLE FLY SWATTER
            </span>
          </div>
        </Link>

        {/* Navigation Links */}
        <nav className="flex items-center gap-3 sm:gap-6">
          <Link
            href="/"
            className={`text-xs sm:text-sm font-semibold transition flex items-center gap-1.5 ${
              pathname === '/'
                ? 'text-splat-green'
                : 'text-zinc-400 hover:text-white'
            }`}
          >
            <Smartphone className="w-4 h-4" />
            <span className="hidden sm:inline">Game</span>
          </Link>

          <Link
            href="/support"
            className={`text-xs sm:text-sm font-semibold transition flex items-center gap-1.5 ${
              pathname === '/support' || pathname === '/support/'
                ? 'text-splat-green'
                : 'text-zinc-400 hover:text-white'
            }`}
          >
            <HelpCircle className="w-4 h-4" />
            <span>Support</span>
          </Link>

          {/* Download Button in Navbar */}
          <a
            href="#download"
            className="flex items-center gap-1.5 px-3 py-1.5 sm:px-4 sm:py-2 rounded-lg bg-zinc-900 border border-zinc-700 hover:border-splat-green text-zinc-200 hover:text-splat-green text-xs sm:text-sm font-bold transition shadow-sm"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Get App</span>
          </a>
        </nav>
      </div>
    </header>
  );
}
