'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ChevronDown,
  Mail,
  Send,
  HelpCircle,
  ShieldCheck,
  Smartphone,
  CheckCircle2,
  Copy,
  ExternalLink,
} from 'lucide-react';

interface FAQItem {
  id: string;
  question: string;
  answer: string;
  subtext?: string;
}

const FAQ_DATA: FAQItem[] = [
  {
    id: 'sensor',
    question: 'How does the closing sensor work?',
    answer:
      'We use the hinge angle and CoreMotion. When you physically fold your smartphone closed, our high-frequency 60Hz motion pipeline detects angular velocity spikes coinciding with sudden deceleration impact shocks as the two screens meet face-to-face, instantaneously registering the smash.',
    subtext: 'Hardware vectoring runs entirely on-device with zero latency and ultra-low battery consumption.',
  },
  {
    id: 'compatibility',
    question: 'Is it compatible with normal phones?',
    answer:
      'Designed exclusively for foldable devices. SMASH IT! was engineered from the ground up to take advantage of dual-screen foldable hardware and hinge kinematics. Standard single-slab smartphones cannot physically snap shut, which is the core mechanic of the game.',
    subtext: 'Supported hardware includes the iPhone Duo and certified dual-screen foldable hardware running DuoOS.',
  },
  {
    id: 'sponge',
    question: 'How do I wipe the screen?',
    answer:
      'Tap the digital sponge in the bottom left corner. After a successful slap, reopen your phone flat to admire the neon-green inkblot splat. Tapping the digital sponge instantly cleans the display and triggers the next swarm wave.',
    subtext: 'You can also shake your phone lightly to trigger the auto-clean haptic rinse in settings.',
  },
];

export default function SupportPage() {
  const [activeFaq, setActiveFaq] = useState<string | null>('sensor');
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
    <div className="relative w-full min-h-screen py-12 sm:py-16 px-4 sm:px-6">
      {/* Ambient background glow */}
      <div className="absolute top-10 left-1/2 -translate-x-1/2 w-[600px] h-[300px] bg-splat-green/10 blur-[140px] rounded-full pointer-events-none -z-10" />
      <div className="absolute inset-0 arcade-grid opacity-20 pointer-events-none -z-10" />

      <div className="max-w-4xl mx-auto">
        
        {/* Support Header */}
        <div className="text-center mb-12 sm:mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-zinc-900 border border-zinc-800 text-xs font-mono text-zinc-400 mb-4">
            <HelpCircle className="w-3.5 h-3.5 text-splat-green" />
            <span>APP STORE COMPLIANCE &amp; CUSTOMER SUPPORT</span>
          </div>

          <h1 className="text-4xl sm:text-6xl font-black uppercase tracking-tight text-white">
            SMASH IT<span className="text-comic-yellow">!</span>{' '}
            <span className="text-splat-green">Support &amp; Contact</span>
          </h1>

          <p className="mt-4 text-zinc-400 text-sm sm:text-base max-w-xl mx-auto">
            Need help with your foldable sensors, game waves, or App Store purchase? We’re here to help you keep swatting smoothly.
          </p>

          {/* Quick Support Email Bar */}
          <div className="mt-6 inline-flex flex-wrap items-center justify-center gap-3 p-3 rounded-2xl bg-zinc-900/90 border border-zinc-800">
            <span className="text-xs font-mono text-zinc-400">Direct Support Email:</span>
            <a
              href="mailto:support@erikgeiger.com"
              className="font-mono text-sm font-bold text-splat-green hover:underline flex items-center gap-1.5"
            >
              <Mail className="w-4 h-4" />
              <span>support@erikgeiger.com</span>
            </a>
            <button
              onClick={copyEmail}
              className="px-2.5 py-1 rounded bg-zinc-800 hover:bg-zinc-700 text-zinc-300 text-xs font-mono flex items-center gap-1 transition"
              title="Copy email to clipboard"
            >
              {copied ? (
                <>
                  <CheckCircle2 className="w-3 h-3 text-splat-green" />
                  <span className="text-splat-green">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3 h-3" />
                  <span>Copy</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* =========================================
            FAQ ACCORDION SECTION
            ========================================= */}
        <div className="mb-16">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl sm:text-3xl font-black uppercase text-white tracking-tight">
                Frequently Asked Questions
              </h2>
              <p className="text-xs sm:text-sm text-zinc-400">
                Common inquiries regarding foldable hardware mechanics and gameplay.
              </p>
            </div>
            <span className="text-xs font-mono text-splat-green font-bold px-2.5 py-1 rounded bg-zinc-900 border border-zinc-800">
              3 QUESTIONS
            </span>
          </div>

          <div className="space-y-3">
            {FAQ_DATA.map((faq) => {
              const isOpen = activeFaq === faq.id;
              return (
                <div
                  key={faq.id}
                  className="rounded-2xl bg-arcade-900/80 border border-zinc-800 overflow-hidden transition-all duration-200 hover:border-zinc-700"
                >
                  <button
                    onClick={() => toggleFaq(faq.id)}
                    className="w-full flex items-center justify-between p-5 sm:p-6 text-left group"
                    aria-expanded={isOpen}
                  >
                    <span className="text-base sm:text-lg font-bold text-white group-hover:text-splat-green transition pr-4">
                      {faq.question}
                    </span>
                    <motion.div
                      animate={{ rotate: isOpen ? 180 : 0 }}
                      transition={{ duration: 0.2 }}
                      className="w-8 h-8 rounded-full bg-zinc-800 flex items-center justify-center flex-shrink-0 group-hover:bg-zinc-700"
                    >
                      <ChevronDown className="w-4 h-4 text-zinc-300 group-hover:text-splat-green" />
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

        {/* =========================================
            CONTACT FORM SECTION
            ========================================= */}
        <div className="p-6 sm:p-10 rounded-3xl bg-arcade-900/90 border-2 border-zinc-800 shadow-comic-lg">
          <div className="max-w-xl mx-auto text-center mb-8">
            <h3 className="text-2xl sm:text-3xl font-black uppercase text-white tracking-tight">
              Send us a Message
            </h3>
            <p className="text-xs sm:text-sm text-zinc-400 mt-1">
              Have an inquiry or feature request? Submit the form below or contact{' '}
              <a href="mailto:support@erikgeiger.com" className="text-splat-green hover:underline">
                support@erikgeiger.com
              </a>.
            </p>
          </div>

          {formSubmitted ? (
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="p-8 rounded-2xl bg-zinc-950 border border-splat-green/40 text-center flex flex-col items-center gap-3"
            >
              <div className="w-12 h-12 rounded-full bg-splat-green/10 border border-splat-green flex items-center justify-center">
                <CheckCircle2 className="w-6 h-6 text-splat-green" />
              </div>
              <h4 className="text-xl font-bold text-white">Message Received!</h4>
              <p className="text-sm text-zinc-400 max-w-md">
                Thank you for contacting SMASH IT! Support. Our hardware engineering team will review your inquiry and reply to <span className="text-splat-green font-mono">{formData.email}</span> within 24 hours.
              </p>
              <button
                onClick={() => {
                  setFormSubmitted(false);
                  setFormData({ name: '', email: '', message: '' });
                }}
                className="mt-3 px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-xs font-bold text-zinc-200 transition"
              >
                Send Another Message
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
                  className="w-full px-4 py-3 rounded-xl bg-zinc-950 border border-zinc-800 text-white placeholder-zinc-600 focus:outline-none focus:border-splat-green focus:ring-1 focus:ring-splat-green transition text-sm"
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
                  className="w-full px-4 py-3 rounded-xl bg-zinc-950 border border-zinc-800 text-white placeholder-zinc-600 focus:outline-none focus:border-splat-green focus:ring-1 focus:ring-splat-green transition text-sm"
                />
              </div>

              <div>
                <label htmlFor="message" className="block text-xs font-mono uppercase text-zinc-400 mb-1.5 font-bold">
                  Message / Issue Description
                </label>
                <textarea
                  id="message"
                  required
                  rows={4}
                  placeholder="Describe your question or feedback..."
                  value={formData.message}
                  onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl bg-zinc-950 border border-zinc-800 text-white placeholder-zinc-600 focus:outline-none focus:border-splat-green focus:ring-1 focus:ring-splat-green transition text-sm resize-none"
                />
              </div>

              <button
                type="submit"
                className="w-full flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-splat-green text-black font-black uppercase text-base border-2 border-black shadow-comic hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 transition active:scale-[0.99]"
              >
                <Send className="w-4 h-4 fill-black" />
                <span>Submit Inquiry</span>
              </button>

              <p className="text-[11px] text-zinc-600 text-center font-mono mt-2">
                Note: All inquiries are handled securely in accordance with Apple Developer App Store guidelines.
              </p>
            </form>
          )}
        </div>

        {/* Compliance Footer Information */}
        <div className="mt-12 p-6 rounded-2xl bg-zinc-950/60 border border-zinc-900 text-xs text-zinc-500 font-mono flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <Smartphone className="w-4 h-4 text-splat-green" />
            <span>SMASH IT! v1.0.0 (Build 2026.10)</span>
          </div>
          <div>Developer: Erik Geiger</div>
          <div>Exclusively for Foldable Smartphones</div>
        </div>

      </div>
    </div>
  );
}
