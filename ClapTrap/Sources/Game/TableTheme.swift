import SwiftUI

/// 11 Distinct Procedural Environments for catching flies:
/// 100% procedural code graphics with unique colors, textures, lighting, and gameplay atmospheres.
public enum TableTheme: String, CaseIterable, Identifiable {
    case classicPicnic = "Classic Picnic"
    case midnightGlow = "Midnight Glow (Dark)"
    case cyberpunkNeon = "Cyberpunk Diner"
    case espressoCafe = "Espresso Cafe"
    case kitchenTiles = "Checkerboard Tiles"
    case gardenLawn = "Garden Meadow"
    case arcadeCabinet = "Retro Synthwave"
    case craftWorkbench = "Artisan Blueprint"
    case zenTatami = "Zen Bamboo Tatami"
    case sweetCandy = "Bubblegum Diner"
    case spaceStarbase = "Cosmic Starbase"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .classicPicnic: return "Sunny Picnic Table"
        case .midnightGlow: return "Midnight Glow Desk"
        case .cyberpunkNeon: return "Cyberpunk Diner"
        case .espressoCafe: return "Espresso Cafe"
        case .kitchenTiles: return "Kitchen Subway Tiles"
        case .gardenLawn: return "Garden Meadow"
        case .arcadeCabinet: return "Retro Synthwave"
        case .craftWorkbench: return "Artisan Blueprint"
        case .zenTatami: return "Zen Bamboo Tatami"
        case .sweetCandy: return "Bubblegum Candy Shop"
        case .spaceStarbase: return "Cosmic Starbase"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .classicPicnic: return "Warm oak wood planks with red-and-white checkered cloth"
        case .midnightGlow: return "Dark nocturnal desk with glowing bioluminescent lightning flies!"
        case .cyberpunkNeon: return "Brushed titanium surface with pulsing magenta & cyan neon strips"
        case .espressoCafe: return "Rich dark roasted walnut espresso table with coffee rings"
        case .kitchenTiles: return "Glossy white & jade subway tiles with grout lines"
        case .gardenLawn: return "Lush green clover lawn with scattered wild meadow daisies"
        case .arcadeCabinet: return "Deep cosmic starfield cabinet with neon 80s perspective grid"
        case .craftWorkbench: return "Self-healing green cutting mat with precision millimeter grid"
        case .zenTatami: return "Natural woven bamboo tatami mat with dark teak lacquered border"
        case .sweetCandy: return "Pastel bubblegum pink & mint vinyl diner cloth with sprinkles"
        case .spaceStarbase: return "Deep space titanium alloy bulkhead with nebula starlight"
        }
    }
    
    public var icon: String {
        switch self {
        case .classicPicnic: return "sun.max.fill"
        case .midnightGlow: return "moon.stars.fill"
        case .cyberpunkNeon: return "bolt.horizontal.fill"
        case .espressoCafe: return "cup.and.saucer.fill"
        case .kitchenTiles: return "square.grid.2x2.fill"
        case .gardenLawn: return "leaf.fill"
        case .arcadeCabinet: return "gamecontroller.fill"
        case .craftWorkbench: return "ruler.fill"
        case .zenTatami: return "wind"
        case .sweetCandy: return "heart.fill"
        case .spaceStarbase: return "sparkles"
        }
    }
    
    public var themeAccentColor: Color {
        switch self {
        case .classicPicnic: return Color(red: 0.95, green: 0.70, blue: 0.20)
        case .midnightGlow: return Color(red: 0.20, green: 1.0, blue: 0.60)
        case .cyberpunkNeon: return Color(red: 1.0, green: 0.25, blue: 0.85)
        case .espressoCafe: return Color(red: 0.85, green: 0.55, blue: 0.30)
        case .kitchenTiles: return Color(red: 0.25, green: 0.85, blue: 0.70)
        case .gardenLawn: return Color(red: 0.30, green: 0.90, blue: 0.35)
        case .arcadeCabinet: return Color(red: 0.60, green: 0.35, blue: 1.0)
        case .craftWorkbench: return Color(red: 0.25, green: 0.80, blue: 0.50)
        case .zenTatami: return Color(red: 0.85, green: 0.75, blue: 0.45)
        case .sweetCandy: return Color(red: 1.0, green: 0.55, blue: 0.75)
        case .spaceStarbase: return Color(red: 0.35, green: 0.75, blue: 1.0)
        }
    }
    
    /// Whether this theme enables glowing bioluminescent insects / lightning flies in the dark!
    public var isGlowInTheDark: Bool {
        return self == .midnightGlow
    }
    
    /// Edge-to-edge backdrop base color beneath the dual folding screen
    public var baseBackgroundColor: Color {
        switch self {
        case .classicPicnic: return Color(red: 0.55, green: 0.33, blue: 0.16)
        case .midnightGlow: return Color(red: 0.04, green: 0.05, blue: 0.09)
        case .cyberpunkNeon: return Color(red: 0.07, green: 0.07, blue: 0.12)
        case .espressoCafe: return Color(red: 0.32, green: 0.18, blue: 0.10)
        case .kitchenTiles: return Color(red: 0.20, green: 0.32, blue: 0.30)
        case .gardenLawn: return Color(red: 0.18, green: 0.45, blue: 0.15)
        case .arcadeCabinet: return Color(red: 0.05, green: 0.03, blue: 0.10)
        case .craftWorkbench: return Color(red: 0.12, green: 0.30, blue: 0.20)
        case .zenTatami: return Color(red: 0.48, green: 0.38, blue: 0.22)
        case .sweetCandy: return Color(red: 0.85, green: 0.42, blue: 0.58)
        case .spaceStarbase: return Color(red: 0.05, green: 0.08, blue: 0.14)
        }
    }
}
