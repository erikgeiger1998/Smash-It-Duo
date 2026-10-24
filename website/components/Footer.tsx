import React from 'react';
import Link from 'next/link';
import { Mail, ShieldCheck, Smartphone, ExternalLink, Zap } from 'lucide-react';

export default function Footer() {
  return (
    <footer className="w-full bg-obsidian-950 border-t border-obsidian-border/80 py-14 px-4 sm:px-6">
      <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-8">
        
        {/* Brand & Mission */}
        <div className="flex flex-col items-center md:items-start text-center md:text-left max-w-sm">
          <div className="flex items-center gap-2">
            <span className="text-2xl">🪰</span>
            <span className="font-black text-xl tracking-wider text-white">
              SMASH IT<span className="text-arcade-gold">!</span> DUO
            </span>
          </div>
          <p className="text-xs text-zinc-400 mt-2 leading-relaxed">
            The world&apos;s first physical reflex game built exclusively for the foldable iPhone Duo. Don&apos;t tap it. Clap it.
          </p>
          <div className="mt-3 flex items-center gap-2 text-[10px] font-mono text-zinc-500">
            <span className="w-2 h-2 rounded-full bg-bugJuice" />
            <span>CoreMotion &amp; CoreHaptics Architecture</span>
          </div>
        </div>

        {/* Quick Links & App Store Review Compliance */}
        <div className="flex flex-wrap items-center justify-center gap-6 text-xs text-zinc-400">
          <Link href="/" className="hover:text-bugJuice transition">
            Home
          </Link>
          <Link href="/#gameplay" className="hover:text-bugJuice transition">
            Gameplay
          </Link>
          <Link href="/#enemies" className="hover:text-bugJuice transition">
            The Enemies
          </Link>
          <Link href="/support" className="hover:text-bugJuice text-white font-semibold transition">
            App Store Support
          </Link>
          <a
            href="mailto:support@erikgeiger.ro"
            className="flex items-center gap-1 hover:text-bugJuice transition text-bugJuice"
          >
            <Mail className="w-3.5 h-3.5" />
            <span>support@erikgeiger.ro</span>
          </a>
        </div>

        {/* Developer & Legal */}
        <div className="text-xs text-zinc-500 text-center md:text-right font-mono">
          <p className="text-zinc-400 font-bold">Developer: Erik Geiger</p>
          <p className="text-[11px] text-zinc-500 mt-1">© 2026 Erik Geiger. All rights reserved.</p>
          <p className="text-[10px] text-zinc-600 mt-0.5">
            Designed exclusively for iPhone Duo (Hardware ID iPhone19,4).
          </p>
        </div>

      </div>
    </footer>
  );
}
