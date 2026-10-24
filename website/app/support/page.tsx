'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ChevronDown,
  Mail,
  Send,
  HelpCircle,
  Smartphone,
  ShieldCheck,
  CheckCircle2,
  Copy,
  AlertTriangle,
  Sparkles,
} from 'lucide-react';

interface FAQItem {
  id: string;
  question: string;
  answer: string;
  subtext?: string;
}

const FAQ_DATA: FAQItem[] = [
  {
    id: 'hinge-sensor',
    question: 'How does the physical closing sensor work?',
    answer:
      'SMASH IT! DUO connects directly to iOS CoreMotion and CMMotionManager at a 60Hz polling frequency. When you begin folding the two halves of your device face-to-face, our kinematics pipeline reads real-time hinge angle velocity (deg/s) and deceleration shocks (G-force), instantaneously registering the smash without requiring a single screen tap.',
    subtext: 'Hardware vectoring runs 100% on-device with zero network latency and minimal battery consumption.',
  },
  {
    id: 'safety-guideline',
    question: 'How hard do I need to fold the phone?',
    answer:
      'Fold gently! You do NOT need to violently slam the glass. Velocity is measured immediately upon hinge movement. A calm, decisive inward clap easily triggers Mach-tier smashes while protecting your device display hinges.',
    subtext: 'Always hold your device firmly with two hands while playing.',
  },
  {
    id: 'sponge-clean',
    question: 'How do I clean the screen between insect waves?',
    answer:
      'Tap the digital sponge in the bottom corner (or gently shake your phone) to wipe away neon bug juice splats! In Wave 6 and higher, soap bubbles dissolve inkblot splatters and reset the table bait for the next swarm wave.',
    subtext: 'Auto-wipe can also be enabled in the Settings menu.',
  },
  {
    id: 'wasp-penalty',
    question: 'Why does the Yellowjacket Wasp cost a life when folded?',
    answer:
      'The Yellowjacket Wasp is a reflex trap hazard! Unlike houseflies and mosquitoes, wasps sting when crushed inside your folded device. When you hear the 230Hz warning hum and see a wasp land on the table, keep your phone OPEN flat to let it depart harmlessly.',
    subtext: 'Clapping a wasp costs 1 heart (out of 3).',
  },
  {
    id: 'hardware-reqs',
    question: 'Is SMASH IT! compatible with standard, non-foldable phones?',
    answer:
      'No. SMASH IT! DUO is designed exclusively for foldable dual-screen hardware (iPhone Duo, hardware identifier iPhone19,4). Single-slab smartphones lack the physical dual displays and hinge angle kinematics necessary to clap shut.',
    subtext: 'App Store app thinning automatically restricts distribution to certified foldable hardware.',
  },
];

export default function SupportPage() {
  const [activeFaq, setActiveFaq] = useState<string | null>('hinge-sensor');
  const [copied, setCopied] = useState<boolean>(false);
  const [formSubmitted, setFormSubmitted] = useState<boolean>(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: '',
  });

  const toggleFaq = (id: string) => {
    setActiveFaq((prev) => (prev === id ? null : id));
  };

  const copyEmail = () => {
    navigator.clipboard.writeText('support@erikgeiger.com');
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.email || !formData.message) return;
    setFormSubmitted(true);
  };

  return (
    <div className="relative w-full min-h-screen py-12 sm:py-20 px-4 sm:px-6">
      {/* Background glow */}
      <div className="absolute top-10 left-1/2 -translate-x-1/2 w-[700px] h-[350px] bg-bugJuice/10 blur-[150px] rounded-full pointer-events-none -z-10" />

      <div className="max-w-4xl mx-auto">
        
        {/* Support Header */}
        <div className="text-center mb-14">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-obsidian-850 border border-obsidian-border text-xs font-mono text-zinc-400 mb-4 shadow-comic-sm">
            <ShieldCheck className="w-4 h-4 text-bugJuice" />
            <span>APPLE APP STORE COMPLIANCE &amp; CUSTOMER SUPPORT</span>
          </div>

          <h1 className="text-4xl sm:text-6xl font-black uppercase tracking-tight text-white">
            SMASH IT<span className="text-arcade-gold">!</span>{' '}
            <span className="text-bugJuice">Support &amp; Safety</span>
          </h1>

          <p className="mt-4 text-zinc-400 text-sm sm:text-base max-w-xl mx-auto">
            Official customer care portal for SMASH IT! DUO. Review sensor mechanics, safety advisories, or contact developer Erik Geiger directly.
          </p>

          {/* Quick Direct Email Bar */}
          <div className="mt-6 inline-flex flex-wrap items-center justify-center gap-3 p-3.5 rounded-2xl bg-obsidian-850 border border-obsidian-border">
            <span className="text-xs font-mono text-zinc-400">Direct Developer Support:</span>
            <a
              href="mailto:support@erikgeiger.com"
              className="font-mono text-sm font-bold text-bugJuice hover:underline flex items-center gap-1.5"
            >
              <Mail className="w-4 h-4" />
              <span>support@erikgeiger.com</span>
            </a>
            <button
              onClick={copyEmail}
              className="px-2.5 py-1 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-300 text-xs font-mono flex items-center gap-1 transition"
              title="Copy email to clipboard"
            >
              {copied ? (
                <>
                  <CheckCircle2 className="w-3.5 h-3.5 text-bugJuice" />
                  <span className="text-bugJuice">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* ========================================================
            DEVICE COMPATIBILITY & SAFETY ADVISORY CARD
            ======================================================== */}
        <div className="mb-14 p-6 sm:p-8 rounded-3xl bg-obsidian-850 border-2 border-arcade-gold/40 shadow-comic flex flex-col md:flex-row items-start gap-6">
          <div className="w-12 h-12 rounded-2xl bg-arcade-gold/10 border border-arcade-gold flex items-center justify-center flex-shrink-0">
            <AlertTriangle className="w-6 h-6 text-arcade-gold" />
          </div>
          <div>
            <span className="text-[10px] font-mono font-bold tracking-widest text-arcade-gold uppercase">
              HARDWARE SAFETY NOTICE &amp; KINEMATICS
            </span>
            <h3 className="text-xl sm:text-2xl font-black text-white uppercase mt-1 mb-2">
              Fold Gently — Velocity is Measured Upon Movement
            </h3>
            <p className="text-zinc-300 text-sm leading-relaxed">
              SMASH IT! DUO uses high-frequency 60Hz vectoring to evaluate closing speed instantly upon initial hinge rotation. You do not need to forcefully slam the screens together. A controlled, smooth inward fold registers full Mach 2 bonus velocity while keeping your foldable device in pristine condition.
            </p>
            <div className="mt-4 flex flex-wrap gap-4 text-xs font-mono text-zinc-400">
              <span className="flex items-center gap-1.5">
                <Smartphone className="w-4 h-4 text-bugJuice" />
                <span>Certified for iPhone Duo (iPhone19,4)</span>
              </span>
              <span>•</span>
              <span>CMMotionManager Vectoring Active</span>
            </div>
          </div>
        </div>

        {/* ========================================================
            INTERACTIVE FAQ ACCORDION SECTION
            ======================================================== */}
        <div className="mb-16">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl sm:text-3xl font-black uppercase text-white tracking-tight">
                Frequently Asked Questions
              </h2>
              <p className="text-xs sm:text-sm text-zinc-400">
                Answers regarding CoreMotion kinematics, trap hazards, and gameplay.
              </p>
            </div>
            <span className="text-xs font-mono text-bugJuice font-bold px-3 py-1 rounded-full bg-obsidian-850 border border-zinc-800">
              5 VERIFIED ANSWERS
            </span>
          </div>

          <div className="space-y-3">
            {FAQ_DATA.map((faq) => {
              const isOpen = activeFaq === faq.id;
              return (
                <div
                  key={faq.id}
                  className="rounded-2xl bg-obsidian-850/90 border border-obsidian-border overflow-hidden transition-all duration-200 hover:border-zinc-700"
                >
                  <button
                    onClick={() => toggleFaq(faq.id)}
                    className="w-full flex items-center justify-between p-5 sm:p-6 text-left group"
                    aria-expanded={isOpen}
                  >
                    <span className="text-base sm:text-lg font-bold text-white group-hover:text-bugJuice transition pr-4">
                      {faq.question}
                    </span>
                    <motion.div
                      animate={{ rotate: isOpen ? 180 : 0 }}
                      transition={{ duration: 0.2 }}
                      className="w-8 h-8 rounded-full bg-zinc-800 flex items-center justify-center flex-shrink-0 group-hover:bg-zinc-700"
                    >
                      <ChevronDown className="w-4 h-4 text-zinc-300 group-hover:text-bugJuice" />
                    </motion.div>
                  </button>

                  <AnimatePresence initial={false}>
                    {isOpen && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.25, ease: 'easeInOut' }}
                      >
                        <div className="px-5 pb-6 sm:px-6 sm:pb-6 text-sm text-zinc-300 border-t border-zinc-800/80 pt-4 leading-relaxed">
                          <p>{faq.answer}</p>
                          {faq.subtext && (
                            <p className="mt-2 text-xs font-mono text-zinc-500">
                              ℹ️ {faq.subtext}
                            </p>
                          )}
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              );
            })}
          </div>
        </div>

        {/* ========================================================
            DIRECT CONTACT CARD & SUPPORT FORM
            ======================================================== */}
        <div className="p-7 sm:p-10 rounded-3xl bg-obsidian-850 border-2 border-obsidian-border shadow-comic-lg">
          <div className="max-w-xl mx-auto text-center mb-8">
            <h3 className="text-2xl sm:text-3xl font-black uppercase text-white tracking-tight">
              Contact Developer
            </h3>
            <p className="text-xs sm:text-sm text-zinc-400 mt-1">
              Have an inquiry, feedback, or bug report? Submit the form below or write directly to{' '}
              <a href="mailto:support@erikgeiger.com" className="text-bugJuice hover:underline">
                support@erikgeiger.com
              </a>.
            </p>
          </div>

          {formSubmitted ? (
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="p-8 rounded-2xl bg-zinc-950 border border-bugJuice/40 text-center flex flex-col items-center gap-3"
            >
              <div className="w-12 h-12 rounded-full bg-bugJuice/10 border border-bugJuice flex items-center justify-center">
                <CheckCircle2 className="w-6 h-6 text-bugJuice" />
              </div>
              <h4 className="text-xl font-bold text-white">Inquiry Received</h4>
              <p className="text-sm text-zinc-400 max-w-md">
                Thank you! Erik Geiger will review your ticket and reply to <span className="text-bugJuice font-mono">{formData.email}</span> within 24 hours.
              </p>
              <button
                onClick={() => {
                  setFormSubmitted(false);
                  setFormData({ name: '', email: '', message: '' });
                }}
                className="mt-3 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-xs font-bold text-zinc-200 transition"
              >
                Send Another Inquiry
              </button>
            </motion.div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4 max-w-xl mx-auto">
              <div>
                <label htmlFor="name" className="block text-xs font-mono uppercase text-zinc-400 mb-1.5 font-bold">
                  Your Name
                </label>
                <input
                  id="name"
                  type="text"
                  required
                  placeholder="e.g. Erik Geiger"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl bg-zinc-950 border border-zinc-800 text-white placeholder-zinc-600 focus:outline-none focus:border-bugJuice focus:ring-1 focus:ring-bugJuice transition text-sm"
                />
              </div>

              <div>
                <label htmlFor="email" className="block text-xs font-mono uppercase text-zinc-400 mb-1.5 font-bold">
                  Email Address
                </label>
                <input
                  id="email"
                  type="email"
                  required
                  placeholder="name@example.com"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl bg-zinc-950 border border-zinc-800 text-white placeholder-zinc-600 focus:outline-none focus:border-bugJuice focus:ring-1 focus:ring-bugJuice transition text-sm"
                />
              </div>

              <div>
                <label htmlFor="message" className="block text-xs font-mono uppercase text-zinc-400 mb-1.5 font-bold">
                  Inquiry / Description
                </label>
                <textarea
                  id="message"
                  required
                  rows={4}
                  placeholder="Describe your question, bug report, or device model..."
                  value={formData.message}
                  onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl bg-zinc-950 border border-zinc-800 text-white placeholder-zinc-600 focus:outline-none focus:border-bugJuice focus:ring-1 focus:ring-bugJuice transition text-sm resize-none"
                />
              </div>

              <button
                type="submit"
                className="w-full flex items-center justify-center gap-2 px-6 py-4 rounded-xl bg-bugJuice text-black font-black uppercase text-base border-2 border-black shadow-comic hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 transition active:scale-[0.99]"
              >
                <Send className="w-4 h-4 fill-black" />
                <span>Submit Ticket to Developer</span>
              </button>

              <p className="text-[11px] text-zinc-600 text-center font-mono mt-2">
                Complies with Apple App Store Developer Review Guidelines.
              </p>
            </form>
          )}
        </div>

        {/* Developer & App Compliance Stamp */}
        <div className="mt-12 p-6 rounded-2xl bg-zinc-950/70 border border-zinc-900 text-xs text-zinc-500 font-mono flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <Smartphone className="w-4 h-4 text-bugJuice" />
            <span>SMASH IT! DUO v1.0.0 (Build 2026.10)</span>
          </div>
          <div>Developer: Erik Geiger</div>
          <div>App Store Thinning: iPhone19,4</div>
        </div>

      </div>
    </div>
  );
}
