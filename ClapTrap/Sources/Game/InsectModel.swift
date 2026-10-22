import SwiftUI

/// Distinct insect species with unique visual traits, audio profiles, and mechanics.
public enum InsectType: String, CaseIterable, Identifiable {
    case housefly = "Housefly"
    case mosquito = "Mosquito"
    case mutantHorsefly = "Mutant Horsefly"
    case wasp = "The Wasp"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .housefly: return "Common Housefly"
        case .mosquito: return "Stealth Mosquito"
        case .mutantHorsefly: return "Mutant Horsefly (BOSS)"
        case .wasp: return "Yellowjacket Wasp (TRAP!)"
        }
    }
    
    public var description: String {
        switch self {
        case .housefly: return "Clap it when it rubs its legs!"
        case .mosquito: return "Tiny, erratic & lightning fast."
        case .mutantHorsefly: return "ARMORED! Requires a Double-Clap!"
        case .wasp: return "DO NOT CLAP! Clapping stings you!"
        }
    }
    
    public var baseReactionWindow: Double {
        switch self {
        case .housefly: return 3.20 // Generous 3.2s landing window: fold smoothly without smashing!
        case .mosquito: return 2.20 // Agile but provides plenty of time (2.2s)
        case .mutantHorsefly: return 3.00 // Armored boss (3.0s)
        case .wasp: return 3.80 // Long warning window (3.8s) so player clearly identifies it and stays calm
        }
    }
    
    public var baseScore: Int {
        switch self {
        case .housefly: return 100
        case .mosquito: return 250
        case .mutantHorsefly: return 750
        case .wasp: return 500 // Patience reward if left alone
        }
    }
    
    public var baseScale: CGFloat {
        switch self {
        case .housefly: return 1.0
        case .mosquito: return 0.65
        case .mutantHorsefly: return 1.65
        case .wasp: return 1.25
        }
    }
    
    public var initialHealth: Int {
        switch self {
        case .mutantHorsefly: return 2
        default: return 1
        }
    }
}

public enum InsectBehaviorState: Equatable {
    case flying
    case descending
    case landed
    case escaped
    case swatted
}

/// Dynamic active insect instance in the game
public struct ActiveInsect: Identifiable {
    public let id = UUID()
    public var type: InsectType
    public var state: InsectBehaviorState = .flying
    
    // Position & Transform
    public var position: CGPoint
    public var targetPosition: CGPoint
    public var headingAngle: Double = 0.0 // Radians
    public var altitude: Double = 1.0 // 1.0 = flying high (shadow offset), 0.0 = landed flat on table
    
    // Procedural Animation States
    public var wingFlutterPhase: Double = 0.0
    public var legRubPhase: Double = 0.0
    public var walkStepPhase: Double = 0.0
    
    // Timers & Health
    public var health: Int
    public var maxHealth: Int
    public var landTimeRemaining: Double = 0.0
    public var totalLandDuration: Double = 0.0
    public var timeElapsedSinceLanding: Double = 0.0
    public var flightTimeBeforeLanding: Double = 3.5
    
    public init(type: InsectType, startPosition: CGPoint) {
        self.type = type
        self.position = startPosition
        self.targetPosition = startPosition
        self.health = type.initialHealth
        self.maxHealth = type.initialHealth
        self.flightTimeBeforeLanding = Double.random(in: 2.2...5.5)
    }
}
