'use client';

import React from 'react';
import Link from 'next/link';
import { ShieldCheck, Lock, EyeOff, Smartphone, Mail, ArrowLeft } from 'lucide-react';

export default function PrivacyPolicyPage() {
  return (
    <div className="relative w-full min-h-screen py-12 sm:py-20 px-4 sm:px-6">
      <div className="absolute top-10 left-1/2 -translate-x-1/2 w-[600px] h-[300px] bg-bugJuice/10 blur-[150px] rounded-full pointer-events-none -z-10" />

      <div className="max-w-4xl mx-auto">
        
        {/* Back navigation */}
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-xs font-mono text-zinc-400 hover:text-bugJuice mb-8 transition"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Home</span>
        </Link>

        {/* Header */}
        <div className="mb-12">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-obsidian-850 border border-obsidian-border text-xs font-mono text-zinc-400 mb-4 shadow-comic-sm">
            <ShieldCheck className="w-4 h-4 text-bugJuice" />
            <span>APP STORE COMPLIANCE — PRIVACY POLICY</span>
          </div>

          <h1 className="text-4xl sm:text-6xl font-black uppercase tracking-tight text-white">
            Privacy <span className="text-bugJuice">Policy</span>
          </h1>

          <p className="mt-3 text-zinc-400 text-sm sm:text-base">
            Last Updated: October 2026 • Effective Date: October 24, 2026
          </p>
        </div>

        {/* Key Guarantee Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-12">
          <div className="p-5 rounded-2xl bg-obsidian-850 border border-obsidian-border">
            <div className="w-10 h-10 rounded-xl bg-bugJuice/10 border border-bugJuice/40 flex items-center justify-center mb-3">
              <EyeOff className="w-5 h-5 text-bugJuice" />
            </div>
            <h3 className="font-black text-white text-base uppercase mb-1">Zero Tracking</h3>
            <p className="text-xs text-zinc-400 leading-relaxed">
              We do not track your location, collect personal identifiers, or monitor your browsing activity.
            </p>
          </div>

          <div className="p-5 rounded-2xl bg-obsidian-850 border border-obsidian-border">
            <div className="w-10 h-10 rounded-xl bg-arcade-gold/10 border border-arcade-gold/40 flex items-center justify-center mb-3">
              <Smartphone className="w-5 h-5 text-arcade-gold" />
            </div>
            <h3 className="font-black text-white text-base uppercase mb-1">100% On-Device</h3>
            <p className="text-xs text-zinc-400 leading-relaxed">
              All hinge angle and CoreMotion kinematics operate locally in volatile memory and are never transmitted.
            </p>
          </div>

          <div className="p-5 rounded-2xl bg-obsidian-850 border border-obsidian-border">
            <div className="w-10 h-10 rounded-xl bg-arcade-crimson/10 border border-arcade-crimson/40 flex items-center justify-center mb-3">
              <Lock className="w-5 h-5 text-arcade-crimson" />
            </div>
            <h3 className="font-black text-white text-base uppercase mb-1">No Third-Party Ads</h3>
            <p className="text-xs text-zinc-400 leading-relaxed">
              Zero ad tracking SDKs, zero data brokers, and zero monetized user profiling of any kind.
            </p>
          </div>
        </div>

        {/* Detailed Legal Content */}
        <div className="space-y-8 text-sm sm:text-base text-zinc-300 leading-relaxed p-6 sm:p-10 rounded-3xl bg-obsidian-850 border border-obsidian-border">
          
          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              1. Overview &amp; Commitment
            </h2>
            <p>
              This Privacy Policy applies to the iOS application <strong>&quot;SMASH IT! The Foldable Fly Swatter&quot;</strong> (including <strong>&quot;SMASH IT! DUO&quot;</strong>), developed by <strong>Erik Geiger</strong> (&quot;we&quot;, &quot;our&quot;, or &quot;developer&quot;). We believe in absolute user privacy. Our software is designed to be an arcade reflex experience, not an advertising or data harvesting platform.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              2. Sensor Data (CoreMotion &amp; Hinge Kinematics)
            </h2>
            <p>
              To detect when your foldable device folds shut, SMASH IT! DUO accesses your device&apos;s built-in motion sensors through Apple&apos;s official <code>CMMotionManager</code> framework (including gyroscope, accelerometer, and hinge rotation vectoring).
            </p>
            <ul className="list-disc list-inside mt-2 space-y-1 text-zinc-400 text-sm">
              <li>Sensor data is processed in real-time strictly in volatile local memory (RAM).</li>
              <li>Sensor readings are never recorded, saved to disk, or sent across a network.</li>
              <li>The instant a clap or swat is calculated, motion data is discarded immediately.</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              3. Data We Do NOT Collect
            </h2>
            <p>SMASH IT! DUO does NOT collect or process any of the following:</p>
            <ul className="list-disc list-inside mt-2 space-y-1 text-zinc-400 text-sm">
              <li>Names, email addresses, phone numbers, or physical addresses (unless you contact customer support).</li>
              <li>Precise or coarse GPS location data.</li>
              <li>Camera or microphone feeds (zero camera or microphone permissions are requested).</li>
              <li>Apple Advertising Identifier (IDFA) or Vendor ID (IDFV) for marketing purposes.</li>
              <li>Financial or payment data (all purchases are handled exclusively by Apple via the App Store).</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              4. Local Data Storage
            </h2>
            <p>
              The game saves your local high scores, current wave progress, and cosmetic settings (such as sound on/off and appearance preferences) directly on your device using standard iOS <code>UserDefaults</code>. This data never leaves your device and is erased if you delete the app.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              5. Children&apos;s Privacy (COPPA &amp; GDPR Compliance)
            </h2>
            <p>
              Because SMASH IT! DUO does not collect any personal data, it complies with the Children&apos;s Online Privacy Protection Act (COPPA), the European Union General Data Protection Regulation (GDPR), and Apple&apos;s Kids Category guidelines. We do not knowingly collect information from children of any age.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              6. Direct Customer Support Communications
            </h2>
            <p>
              If you voluntarily contact developer support via our support email (<code>support@erikgeiger.ro</code>) or our website contact form, we use your email address and message content solely to reply to your inquiry. We never sell, rent, or share your contact information with third parties.
            </p>
          </section>

          <section>
            <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight mb-3">
              7. Contact Information
            </h2>
            <p>
              If you have any questions regarding this Privacy Policy or wish to make an inquiry, please contact:
            </p>
            <div className="mt-3 p-4 rounded-xl bg-zinc-950 border border-zinc-800 text-sm font-mono">
              <p className="text-white font-bold">Erik Geiger — Independent Developer</p>
              <p className="text-zinc-400 mt-1">App Store Product: SMASH IT! DUO</p>
              <p className="text-bugJuice mt-1">
                Official Support Email:{' '}
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
