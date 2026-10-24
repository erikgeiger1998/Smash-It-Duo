import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        obsidian: {
          950: "#050608",
          900: "#090A0F",
          850: "#0F121C",
          800: "#161B2B",
          700: "#242C44",
          border: "#1E253A",
        },
        bugJuice: {
          DEFAULT: "#39FF14",
          lime: "#22c55e",
          glow: "#50fa7b",
          dark: "#15803d",
        },
        arcade: {
          gold: "#FFD700",
          yellow: "#FFE600",
          orange: "#FF5E00",
          crimson: "#FF2A55",
          red: "#FF3B30",
          cyan: "#00F0FF",
        },
        table: {
          light: "#A06533",
          wood: "#8A5326",
          dark: "#5C3517",
          groove: "#3B200D",
        },
      },
      boxShadow: {
        "comic-sm": "3px 3px 0px 0px #000000",
        "comic": "5px 5px 0px 0px #000000",
        "comic-lg": "8px 8px 0px 0px #000000",
        "neon-green": "0 0 25px rgba(57, 255, 20, 0.5), 0 0 50px rgba(57, 255, 20, 0.2)",
        "neon-gold": "0 0 25px rgba(255, 215, 0, 0.5), 0 0 50px rgba(255, 215, 0, 0.2)",
        "neon-crimson": "0 0 25px rgba(255, 42, 85, 0.5)",
      },
      animation: {
        "pulse-fast": "pulse 1.2s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        "wiggle": "wiggle 0.3s ease-in-out infinite",
        "radar": "radar 2s linear infinite",
      },
      keyframes: {
        wiggle: {
          "0%, 100%": { transform: "rotate(-3deg)" },
          "50%": { transform: "rotate(3deg)" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
