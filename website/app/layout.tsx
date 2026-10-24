import type { Metadata, Viewport } from 'next';
import './globals.css';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';

export const metadata: Metadata = {
  title: 'SMASH IT! - The Foldable Fly Swatter Game',
  description:
    'The revolutionary foldable smartphone game. Physically snap your phone shut to squash buzzing flies with real hinge sensors, CoreMotion, and haptic feedback!',
  keywords: [
    'Smash It',
    'Foldable Phone Game',
    'Fly Swatter',
    'iPhone Duo',
    'Foldable Smartphone',
    'CoreMotion',
    'App Store',
  ],
  authors: [{ name: 'Erik Geiger' }],
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  themeColor: '#050608',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark scroll-smooth">
      <body className="min-h-screen bg-arcade-950 text-white flex flex-col antialiased selection:bg-splat-green selection:text-black">
        <Navbar />
        <main className="flex-1 flex flex-col">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
