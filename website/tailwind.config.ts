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
        arcade: {
          950: "#050608",
          900: "#090b10",
          850: "#0e111a",
          800: "#151926",
          700: "#22273d",
          border: "#262c45",
        },
        splat: {
          green: "#39ff14",
          lime: "#22c55e",
          glow: "#50fa7b",
          dark: "#14532d",
        },
        comic: {
          yellow: "#ffe600",
          orange: "#ff5e00",
          red: "#ff2a55",
          cyan: "#00f0ff",
        },
      },
      boxShadow: {
        "comic-sm": "3px 3px 0px 0px #000000",
        "comic": "5px 5px 0px 0px #000000",
        "comic-lg": "8px 8px 0px 0px #000000",
        "comic-green": "0px 0px 30px rgba(57, 255, 20, 0.45)",
        "comic-orange": "0px 0px 30px rgba(255, 94, 0, 0.45)",
        "neon-glow": "0 0 20px rgba(57, 255, 20, 0.5), 0 0 40px rgba(57, 255, 20, 0.2)",
      },
      fontFamily: {
        comic: ["system-ui", "-apple-system", "BlinkMacSystemFont", "Segoe UI", "sans-serif"],
      },
      animation: {
        "pulse-fast": "pulse 1.2s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        "float": "float 3s ease-in-out infinite",
        "glitch": "glitch 1s linear infinite",
      },
      keyframes: {
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-8px)" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
