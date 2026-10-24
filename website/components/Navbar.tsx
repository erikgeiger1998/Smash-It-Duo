'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Smartphone, Bug, HelpCircle, ShieldCheck, Download } from 'lucide-react';

export default function Navbar() {
  const pathname = usePathname();

  return (
    <header className="sticky top-4 z-50 w-full max-w-5xl mx-auto px-4 sm:px-6">
      <div className="w-full backdrop-blur-xl bg-obsidian-900/80 border border-obsidian-border/80 rounded-2xl h-16 px-4 sm:px-6 flex items-center justify-between shadow-[0_10px_30px_rgba(0,0,0,0.8)]">
        
        {/* Brand Logo */}
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-bugJuice to-emerald-500 border border-black shadow-comic-sm flex items-center justify-center transform group-hover:rotate-6 transition">
            <span className="text-xl">🪰</span>
          </div>
          <div className="flex flex-col">
            <span className="font-black text-lg sm:text-xl tracking-tight text-white group-hover:text-bugJuice transition flex items-center gap-1">
              SMASH IT<span className="text-arcade-gold">!</span>
              <span className="text-[10px] px-1.5 py-0.5 rounded bg-zinc-800 text-bugJuice border border-zinc-700 ml-1">
                DUO
              </span>
            </span>
          </div>
        </Link>

        {/* Navigation Links */}
        <nav className="hidden md:flex items-center gap-6 text-sm font-semibold text-zinc-400">
          <Link
            href="/#gameplay"
            className="hover:text-white transition flex items-center gap-1.5"
          >
            <Smartphone className="w-4 h-4 text-bugJuice" />
            <span>Gameplay</span>
          </Link>

          <Link
            href="/#enemies"
            className="hover:text-white transition flex items-center gap-1.5"
          >
            <Bug className="w-4 h-4 text-arcade-gold" />
            <span>The Enemies</span>
          </Link>

          <Link
            href="/support"
            className={`transition flex items-center gap-1.5 ${
              pathname === '/support' || pathname === '/support/'
                ? 'text-bugJuice font-bold'
                : 'hover:text-white'
            }`}
          >
            <HelpCircle className="w-4 h-4 text-arcade-crimson" />
            <span>Support</span>
          </Link>

          <Link
            href="/privacy"
            className={`transition flex items-center gap-1.5 ${
              pathname === '/privacy' || pathname === '/privacy/'
                ? 'text-bugJuice font-bold'
                : 'hover:text-white'
            }`}
          >
            <ShieldCheck className="w-4 h-4 text-emerald-400" />
            <span>Privacy</span>
          </Link>
        </nav>

        {/* Glowing Download on App Store CTA Pill */}
        <a
          href="https://apps.apple.com"
          target="_blank"
          rel="noopener noreferrer"
          className="relative group flex items-center gap-2 px-4 py-2 rounded-xl bg-gradient-to-r from-bugJuice via-emerald-400 to-bugJuice text-black font-black text-xs sm:text-sm uppercase tracking-wider border border-black shadow-comic-sm hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 transition"
        >
          <Download className="w-4 h-4 fill-black" />
          <span className="hidden sm:inline">Download on App Store</span>
          <span className="sm:hidden">Get App</span>
        </a>

      </div>
    </header>
  );
}
