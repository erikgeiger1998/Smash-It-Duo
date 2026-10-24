'use client';

import React from 'react';
import Link from 'next/link';
import { FileText, AlertTriangle, Smartphone, ShieldCheck, Mail, ArrowLeft } from 'lucide-react';

export default function TermsAndConditionsPage() {
  return (
    <div className="relative w-full min-h-screen py-12 sm:py-20 px-4 sm:px-6">
      <div className="absolute top-10 left-1/2 -translate-x-1/2 w-[600px] h-[300px] bg-arcade-gold/10 blur-[150px] rounded-full pointer-events-none -z-10" />

      <div className="max-w-4xl mx-auto">
        
        {/* Back navigation */}
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-xs font-mono text-zinc-400 hover:text-arcade-gold mb-8 transition"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Home</span>
        </Link>

        {/* Header */}
        <div className="mb-12">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-obsidian-850 border border-obsidian-border text-xs font-mono text-zinc-400 mb-4 shadow-comic-sm">
            <FileText className="w-4 h-4 text-arcade-gold" />
            <span>APP STORE LEGAL &amp; SAFETY TERMS</span>
          </div>

          <h1 className="text-4xl sm:text-6xl font-black uppercase tracking-tight text-white">
            Terms &amp; <span className="text-arcade-gold">Conditions</span>
          </h1>

          <p className="mt-3 text-zinc-400 text-sm sm:text-base">
            Last Updated: October 2026 • Effective Date: October 24, 2026
          </p>
        </div>

        {/* Safety Warning Card */}
        <div className="p-6 sm:p-8 rounded-3xl bg-obsidian-850 border-2 border-arcade-crimson/50 shadow-comic mb-10 flex flex-col sm:flex-row items-start gap-5">
          <div className="w-12 h-12 rounded-2xl bg-arcade-crimson/10 border border-arcade-crimson flex items-center justify-center flex-shrink-0">
            <AlertTriangle className="w-6 h-6 text-arcade-crimson" />
          </div>
          <div>
            <h3 className="text-lg sm:text-xl font-black text-white uppercase tracking-tight mb-2">
              Hardware Physical Safety Notice — Fold Gently
            </h3>
            <p className="text-sm text-zinc-300 leading-relaxed">
              SMASH IT! DUO measures hinge velocity instantaneously upon the beginning of inward rotation. You do <strong>NOT</strong> need to forcefully slam the device shut. Always maintain a firm, two-handed grip on your device. Never slap your device against tables, hard surfaces, or third-party objects.
            </p>
          </div>
        </div>

        {/* Legal Sections */}
        <div className="space-y-8 text-sm sm:text-base text-zinc-300 leading-relaxed p-6 sm:p-10 rounded-3xl bg-obsidian-850 border border-obsidian-border">
          
          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              1. Acceptance of Terms
            </h2>
            <p>
              By downloading, installing, or playing <strong>&quot;SMASH IT! The Foldable Fly Swatter&quot;</strong> (&quot;SMASH IT! DUO&quot; or the &quot;Application&quot;), developed by <strong>Erik Geiger</strong> (&quot;Developer&quot;), you agree to be bound by these Terms and Conditions and Apple&apos;s Standard Licensed Application End User License Agreement (EULA). If you do not agree, do not install or use the Application.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              2. License Grant
            </h2>
            <p>
              Developer grants you a personal, revocable, non-exclusive, non-transferable, limited license to download and play the Application on compatible iOS foldable devices (iPhone Duo, model identifier <code>iPhone19,4</code>) linked to your Apple ID, solely for personal, non-commercial arcade entertainment.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              3. Device Safety &amp; Disclaimer of Physical Damage
            </h2>
            <p>
              SMASH IT! DUO is designed to leverage the physical folding form-factor of your smartphone. You acknowledge and agree that:
            </p>
            <ul className="list-disc list-inside mt-2 space-y-1 text-zinc-400 text-sm">
              <li>You are solely responsible for exercising care and safe handling while folding your device.</li>
              <li>Velocity is measured in real-time by motion algorithms upon initial hinge movement; violent claps, physical slamming, or impacts against exterior surfaces are unnecessary for gameplay and strictly discouraged.</li>
              <li>
                <strong>To the maximum extent permitted by applicable law, Developer shall not be liable for any physical damage to your device, display glass, hinge mechanics, or surrounding property, nor for any personal injury resulting from careless, aggressive, or improper handling of your phone while playing.</strong>
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              4. Intellectual Property
            </h2>
            <p>
              All titles, code, audio synthesis algorithms, cartoon insect character illustrations, logos, visual effects, and game assets associated with SMASH IT! DUO are the exclusive intellectual property of <strong>Erik Geiger</strong>. You may not decompile, reverse-engineer, modify, or distribute any portion of the Application.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              5. Purchases &amp; Refunds
            </h2>
            <p>
              All financial transactions, downloads, and refund requests are administered exclusively by Apple Inc. in accordance with App Store Terms of Service. Developer does not process payments or issue refunds directly.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              6. Governing Law &amp; Contact
            </h2>
            <p>
              These Terms shall be governed by and construed in accordance with applicable laws. For support inquiries or legal questions, please contact:
            </p>
            <div className="mt-3 p-4 rounded-xl bg-zinc-950 border border-zinc-800 text-sm font-mono">
              <p className="text-white font-bold">Erik Geiger — Developer</p>
              <p className="text-zinc-400 mt-1">Product: SMASH IT! DUO</p>
              <p className="text-arcade-gold mt-1">
                Support Email:{' '}
                <a href="mailto:support@erikgeiger.ro" className="underline">
                  support@erikgeiger.ro
                </a>
              </p>
            </div>
          </section>

        </div>

      </div>
    </div>
  );
}
