import type { Metadata, Viewport } from 'next';
import './globals.css';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';

export const metadata: Metadata = {
  title: 'SMASH IT! DUO — The Foldable Fly Swatter Game for iPhone Duo',
  description:
    "Don't tap it. Clap it. The world's first physical reflex game built exclusively for the foldable iPhone Duo. Physically slam your dual screens shut to crush pests with 60Hz hinge vectoring & CoreHaptics recoil.",
  keywords: [
    'Smash It Duo',
    'iPhone Duo',
    'Foldable Smartphone Game',
    'Foldable Fly Swatter',
    'CoreMotion',
    'CoreHaptics',
    'App Store',
    'Erik Geiger',
  ],
  authors: [{ name: 'Erik Geiger' }],
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  themeColor: '#090A0F',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark scroll-smooth">
      <body className="min-h-screen bg-obsidian-900 text-white flex flex-col antialiased selection:bg-bugJuice selection:text-black arcade-dots">
        <Navbar />
        <main className="flex-1 flex flex-col">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
