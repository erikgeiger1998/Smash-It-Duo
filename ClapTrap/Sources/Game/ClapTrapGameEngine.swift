import SwiftUI
import Combine

public enum GameState: Equatable {
    case menu
    case hunting
    case landed
    case swatted
    case revealing
    case gameOver
}

public struct SwatOutcome {
    public let hit: Bool
    public let insectType: InsectType
    public let reactionTimeMs: Int
    public let slamVelocity: Double
    public let isMach2: Bool
    public let pointsEarned: Int
    public let praiseText: String
    public let mockingText: String
    public let isStung: Bool
    public let isBossDamagedOnly: Bool
}

/// The Central Game Engine powering ClapTrap: The Foldable Fly Swatter.
/// Manages state machine transitions, wave progression, insect flight physics across
/// the dual-screen foldable layout, reaction window timing, and hit verification.
public final class ClapTrapGameEngine: ObservableObject {
    public static let shared = ClapTrapGameEngine()
    
    // MARK: - Published Game State
    @Published public var gameState: GameState = .menu
    @Published public var currentWave: Int = 1
    @Published public var score: Int = 0
    @Published public var highScore: Int = 0
    @Published public var streak: Int = 0
    @Published public var lives: Int = 3
    @Published public var activeInsect: ActiveInsect?
    @Published public var persistentSplatters: [SplatterRecord] = []
    @Published public var lastOutcome: SwatOutcome?
    @Published public var showCrackedScreenOverlay: Bool = false
    @Published public var crackedScreenImpactPoint: CGPoint = .zero
    @Published public var isSpongeWiping: Bool = false
    @Published public var isGameMenuPresented: Bool = false
    @Published public var menuInitialTab: Int = 0
    
    public func openMenu(tab: Int = 0) {
        self.menuInitialTab = tab
        self.isGameMenuPresented = true
    }
    
    // Reaction timer progress for HUD (1.0 = full time remaining, 0.0 = time's up)
    @Published public var reactionProgress: Double = 1.0
    
    // Screen geometry cache
    public var dualScreenSize: CGSize = CGSize(width: 800, height: 600) {
        didSet {
            hingeX = dualScreenSize.width / 2.0
        }
    }
    public var hingeX: CGFloat = 400.0
    
    // MARK: - Safe Playfield Boundaries (Prevents insects from ever leaving or landing outside the screen)
    public var safeMinX: CGFloat {
        // Safe clearance from left screen bezel and checkered cloth edge (runner ends at x = 80)
        return 90.0
    }
    
    public var safeMaxX: CGFloat {
        // Safe clearance from right screen bezel
        return max(safeMinX + 120.0, dualScreenSize.width - 90.0)
    }
    
    public var safeMinY: CGFloat {
        // Safe clearance beneath the top cockpit HUD console
        return 145.0
    }
    
    public var safeMaxY: CGFloat {
        // Safe clearance above the bottom screen bezel
        return max(safeMinY + 120.0, dualScreenSize.height - 110.0)
    }
    
    // MARK: - Dependencies & Subscriptions
    private let soundEngine = ProceduralSoundEngine.shared
    private let foldSensor = FoldSensorManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var gameLoopTimer: AnyCancellable?
    
    // Landing & Reaction Timing
    private var landingDate: Date?
    private var flightPathBezierT: Double = 0.0
    private var bezierStart: CGPoint = .zero
    private var bezierControl1: CGPoint = .zero
    private var bezierControl2: CGPoint = .zero
    private var bezierEnd: CGPoint = .zero
    
    // Persistence Key
    private let highScoreKey = "ClapTrap_HighScore_Key"
    
    private init() {
        self.highScore = UserDefaults.standard.integer(forKey: highScoreKey)
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Listen for hardware / simulated slam events from FoldSensorManager
        foldSensor.slamEventPublisher
            .sink { [weak self] impactData in
                self?.handleDeviceSlamShut(impactData: impactData)
            }
            .store(in: &cancellables)
        
        // Listen for phone reopening
        foldSensor.$hingeAngle
            .sink { [weak self] angle in
                self?.handleHingeAngleChange(angle)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Game Lifecycle
    
    /// Triggered automatically when the physical foldable phone is opened from the cover screen
    public func handleDeviceUnfolded() {
        soundEngine.playUnfoldHingeSound()
        if gameState == .gameOver {
            startGame()
        } else if let outcome = lastOutcome, outcome.hit {
            advanceToNextWave()
        } else if gameState == .menu {
            startGame()
        }
    }
    
    public func startGame() {
        self.score = 0
        self.streak = 0
        self.lives = 3
        self.currentWave = 1
        self.lastOutcome = nil
        self.showCrackedScreenOverlay = false
        self.gameState = .hunting
        
        startWave()
        startGameLoop()
    }
    
    public func returnToMenu() {
        soundEngine.stopBuzz()
        gameLoopTimer?.cancel()
        self.gameState = .menu
        self.activeInsect = nil
    }
    
    private func startGameLoop() {
        gameLoopTimer?.cancel()
        gameLoopTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateFrame(dt: 1.0 / 60.0)
            }
    }
    
    private func startWave() {
        let insectType = determineInsectForWave(currentWave)
        
        // Pick a spawn point well within the safe screen boundaries
        // Alternating between left screen and right screen!
        let spawnLeft = Bool.random()
        let startX: CGFloat = spawnLeft ? safeMinX + 15.0 : safeMaxX - 15.0
        let startY: CGFloat = CGFloat.random(in: safeMinY...safeMaxY)
        let startPos = CGPoint(x: startX, y: startY)
        
        var insect = ActiveInsect(type: insectType, startPosition: startPos)
        insect.state = .flying
        insect.altitude = 1.0
        
        // Flight time before landing gets slightly snappier at higher waves
        let waveWaitReduction = min(1.8, Double(max(0, currentWave - 1)) * 0.08)
        insect.flightTimeBeforeLanding = max(1.7, 3.6 - waveWaitReduction)
        
        self.activeInsect = insect
        self.flightPathBezierT = 0.0
        generateNextBezierFlightSegment(from: startPos)
    }
    
    private func determineInsectForWave(_ wave: Int) -> InsectType {
        if wave % 15 == 0 {
            return .wasp // Boss Trap Wave!
        } else if wave % 10 == 0 || wave == 5 {
            return .mutantHorsefly // Boss Wave!
        } else if wave >= 6 {
            // Mixed waves: Mosquitoes or Houseflies
            return (wave % 2 == 0) ? .mosquito : .housefly
        } else {
            return .housefly
        }
    }
    
    // MARK: - Frame Update (Physics & State Transitions)
    
    private func updateFrame(dt: Double) {
        guard var insect = activeInsect else { return }
        
        switch insect.state {
        case .flying:
            updateFlyingInsect(&insect, dt: dt)
            
        case .descending:
            updateDescendingInsect(&insect, dt: dt)
            
        case .landed:
            updateLandedInsect(&insect, dt: dt)
            
        case .escaped, .swatted:
            break
        }
        
        self.activeInsect = insect
    }
    
    // MARK: - Flight Physics & Bezier Navigation across Dual Screen
    
    private func updateFlyingInsect(_ insect: inout ActiveInsect, dt: Double) {
        // Wings flutter continuously
        let flutterRate = insect.type == .mosquito ? 90.0 : 55.0
        insect.wingFlutterPhase += dt * flutterRate
        
        // Step along Bezier path (subtle acceleration as waves progress)
        let waveFlightSpeed = min(0.35, Double(max(0, currentWave - 1)) * 0.018)
        flightPathBezierT += dt * (0.45 + waveFlightSpeed)
        
        if flightPathBezierT >= 1.0 {
            flightPathBezierT = 0.0
            generateNextBezierFlightSegment(from: insect.position)
        }
        
        let newPos = evaluateCubicBezier(
            p0: bezierStart,
            p1: bezierControl1,
            p2: bezierControl2,
            p3: bezierEnd,
            t: flightPathBezierT
        )
        
        // Compute heading angle
        let dx = newPos.x - insect.position.x
        let dy = newPos.y - insect.position.y
        if abs(dx) > 0.01 || abs(dy) > 0.01 {
            insect.headingAngle = atan2(dy, dx) + .pi / 2.0
        }
        
        // Strict boundary clamp so the insect NEVER leaves or extends outside the screen
        insect.position.x = min(safeMaxX, max(safeMinX, newPos.x))
        insect.position.y = min(safeMaxY, max(safeMinY, newPos.y))
        insect.altitude = 1.0
        
        // Spatial 3D Stereo Audio Buzzing update
        let normX = Float((insect.position.x - hingeX) / (dualScreenSize.width / 2.0))
        soundEngine.updateInsectSpatialBuzz(
            normalizedX: normX,
            altitude: Float(insect.altitude),
            insectType: insect.type,
            active: true
        )
        
        // Countdown to landing
        insect.flightTimeBeforeLanding -= dt
        if insect.flightTimeBeforeLanding <= 0.0 {
            // Begin descent trajectory towards the table (often near the watermelon bait!)
            initiateLandingSequence(&insect)
        }
    }
    
    private func initiateLandingSequence(_ insect: inout ActiveInsect) {
        insect.state = .descending
        
        // 60% chance to land right around the watermelon bait near the hinge!
        let landNearBait = Double.random(in: 0...1) < 0.60
        let landX: CGFloat
        let landY: CGFloat
        
        if landNearBait {
            // Clustered around the juicy watermelon bait at (hingeX - 8, height * 0.52)
            let baitX = hingeX - 8.0
            let baitY = dualScreenSize.height * 0.52
            landX = min(safeMaxX, max(safeMinX, baitX + CGFloat.random(in: -65...65)))
            landY = min(safeMaxY, max(safeMinY, baitY + CGFloat.random(in: -45...45)))
        } else {
            // Or landed safely on the warm wooden table planks on either left or right screen!
            landX = CGFloat.random(in: safeMinX...safeMaxX)
            landY = CGFloat.random(in: safeMinY...safeMaxY)
        }
        
        insect.targetPosition = CGPoint(x: landX, y: landY)
    }
    
    private func updateDescendingInsect(_ insect: inout ActiveInsect, dt: Double) {
        // Wings flutter while descending
        insect.wingFlutterPhase += dt * 50.0
        
        // Smoothly approach target landing position
        let dx = insect.targetPosition.x - insect.position.x
        let dy = insect.targetPosition.y - insect.position.y
        let dist = sqrt(dx * dx + dy * dy)
        
        if dist > 3.0 {
            insect.position.x += dx * CGFloat(dt * 3.5)
            insect.position.y += dy * CGFloat(dt * 3.5)
            // Clamp position so descent stays strictly within screen
            insect.position.x = min(safeMaxX, max(safeMinX, insect.position.x))
            insect.position.y = min(safeMaxY, max(safeMinY, insect.position.y))
            insect.altitude = max(0.0, insect.altitude - dt * 1.4)
            
            let normX = Float((insect.position.x - hingeX) / (dualScreenSize.width / 2.0))
            soundEngine.updateInsectSpatialBuzz(
                normalizedX: normX,
                altitude: Float(insect.altitude),
                insectType: insect.type,
                active: true
            )
        } else {
            // Fully Landed!
            insect.position = insect.targetPosition
            insect.altitude = 0.0
            insect.state = .landed
            self.gameState = .landed
            
            // Progressive reaction window: speeds up as waves progress!
            let window = calculateLandingWindow(for: insect.type, wave: currentWave)
            insect.totalLandDuration = window
            insect.landTimeRemaining = window
            insect.timeElapsedSinceLanding = 0.0
            self.landingDate = Date()
            self.reactionProgress = 1.0
            
            soundEngine.triggerInsectLandingHaptic()
        }
    }
    
    // MARK: - Progressive Wave Escalation Logic
    
    /// Calculates the landing reaction window for a given wave.
    /// Time ticks down faster on higher waves, demanding quicker reflexes to advance!
    public func calculateLandingWindow(for insectType: InsectType, wave: Int) -> Double {
        let waveFactor = Double(max(0, wave - 1))
        let speedup = min(2.65, waveFactor * 0.12)
        let minFloor: Double
        switch insectType {
        case .mosquito: minFloor = 0.85
        case .housefly: minFloor = 0.95
        case .mutantHorsefly: minFloor = 1.10
        case .wasp: minFloor = 2.20
        }
        return max(minFloor, insectType.baseReactionWindow - speedup)
    }
    
    private func updateLandedInsect(_ insect: inout ActiveInsect, dt: Double) {
        // Fly is landed: wings stop fluttering, front legs rub together!
        insect.legRubPhase += dt * 16.0
        
        // Subtle walking steps - strictly clamped so landed insect never creeps off the screen
        insect.walkStepPhase += dt * 4.0
        let jitterX = cos(insect.walkStepPhase) * 0.3
        let jitterY = sin(insect.walkStepPhase) * 0.3
        insect.position.x = min(safeMaxX, max(safeMinX, insect.position.x + jitterX))
        insect.position.y = min(safeMaxY, max(safeMinY, insect.position.y + jitterY))
        
        insect.timeElapsedSinceLanding += dt
        insect.landTimeRemaining -= dt
        self.reactionProgress = max(0.0, insect.landTimeRemaining / insect.totalLandDuration)
        
        let normX = Float((insect.position.x - hingeX) / (dualScreenSize.width / 2.0))
        soundEngine.updateInsectSpatialBuzz(
            normalizedX: normX,
            altitude: 0.0, // On table!
            insectType: insect.type,
            active: true
        )
        
        // Did time expire without clapping?
        if insect.landTimeRemaining <= 0.0 {
            handleLandingTimeout(&insect)
        }
    }
    
    private func handleLandingTimeout(_ insect: inout ActiveInsect) {
        if insect.type == .wasp {
            // Player successfully WAITED and didn't clap the wasp!
            // PATIENCE BONUS!
            insect.state = .escaped
            soundEngine.playGodlikeFanfare()
            let patienceBonus = 500
            self.score += patienceBonus
            self.streak += 1
            
            self.lastOutcome = SwatOutcome(
                hit: true,
                insectType: .wasp,
                reactionTimeMs: 0,
                slamVelocity: 0,
                isMach2: false,
                pointsEarned: patienceBonus,
                praiseText: "PATIENCE MASTER!",
                mockingText: "You wisely avoided the wasp stinger!",
                isStung: false,
                isBossDamagedOnly: false
            )
            advanceToNextWave()
        } else {
            // Normal insect escaped!
            insect.state = .escaped
            soundEngine.playWhiffSound()
            self.streak = 0
            
            // Fly takes off again!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                guard let self = self, self.gameState == .landed else { return }
                self.gameState = .hunting
                self.startWave()
            }
        }
    }
    
    // MARK: - Bezier Path Helper
    
    private func generateNextBezierFlightSegment(from start: CGPoint) {
        bezierStart = start
        
        // Dynamic Screen-Crossing Flight:
        // 75% chance to cross the central hinge to fly over to the opposite screen half!
        let shouldCrossHinge = Double.random(in: 0...1) < 0.75
        let endX: CGFloat
        
        if shouldCrossHinge {
            if start.x < hingeX {
                // Fly from Left Screen over to the Right Screen!
                let rightMin = min(safeMaxX - 20.0, hingeX + 40.0)
                endX = CGFloat.random(in: rightMin...safeMaxX)
            } else {
                // Fly from Right Screen over to the Left Screen!
                let leftMax = max(safeMinX + 20.0, hingeX - 40.0)
                endX = CGFloat.random(in: safeMinX...leftMax)
            }
        } else {
            // Dynamic wander across the whole safe dual-screen playfield
            endX = CGFloat.random(in: safeMinX...safeMaxX)
        }
        
        let endY = CGFloat.random(in: safeMinY...safeMaxY)
        bezierEnd = CGPoint(x: endX, y: endY)
        
        // Organic wandering control points - STRICTLY clamped inside safe bounds!
        let segMidX = (start.x + endX) / 2.0
        let jitterX: CGFloat = min(120.0, (safeMaxX - safeMinX) * 0.3)
        let jitterY: CGFloat = 90.0
        
        bezierControl1 = CGPoint(
            x: min(safeMaxX, max(safeMinX, segMidX + CGFloat.random(in: -jitterX...jitterX))),
            y: min(safeMaxY, max(safeMinY, start.y + CGFloat.random(in: -jitterY...jitterY)))
        )
        bezierControl2 = CGPoint(
            x: min(safeMaxX, max(safeMinX, segMidX + CGFloat.random(in: -jitterX...jitterX))),
            y: min(safeMaxY, max(safeMinY, endY + CGFloat.random(in: -jitterY...jitterY)))
        )
    }
    
    private func evaluateCubicBezier(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, t: Double) -> CGPoint {
        let u = 1.0 - t
        let tt = t * t
        let uu = u * u
        let uuu = uu * u
        let ttt = tt * t
        
        let x = uuu * p0.x + 3.0 * uu * t * p1.x + 3.0 * u * tt * p2.x + ttt * p3.x
        let y = uuu * p0.y + 3.0 * uu * t * p1.y + 3.0 * u * tt * p2.y + ttt * p3.y
        return CGPoint(x: x, y: y)
    }
    
    // MARK: - Fold & Slam Impact Handling
    
    private func handleDeviceSlamShut(impactData: FoldSensorManager.SlamImpactData) {
        guard gameState == .hunting || gameState == .landed else { return }
        
        self.gameState = .swatted
        soundEngine.stopBuzz()
        
        guard let insect = activeInsect else { return }
        
        // 1. WAS THE INSECT LANDED?
        if insect.state == .landed {
            let reactionMs: Int
            if let landDate = self.landingDate {
                reactionMs = Int(Date().timeIntervalSince(landDate) * 1000.0)
            } else {
                reactionMs = 350
            }
            
            // Check for WASP (TRAP HAZARD!)
            if insect.type == .wasp {
                // Clapped the wasp! STUNG!
                handleWaspStungOutcome(velocity: impactData.velocityDegPerSec, reactionMs: reactionMs)
                return
            }
            
            // Check for MUTANT HORSEFLY (BOSS)
            if insect.type == .mutantHorsefly && insect.health > 1 {
                // Damaged boss, needs 1 more clap!
                handleBossDamagedOutcome(velocity: impactData.velocityDegPerSec)
                return
            }
            
            // SUCCESSFUL SWAT!
            handleSuccessfulSwatOutcome(insect: insect, impactData: impactData, reactionMs: reactionMs)
            
        } else {
            // WHIFFED IN MID-AIR!
            handleAirWhiffOutcome(velocity: impactData.velocityDegPerSec)
        }
    }
    
    private func handleSuccessfulSwatOutcome(
        insect: ActiveInsect,
        impactData: FoldSensorManager.SlamImpactData,
        reactionMs: Int
    ) {
        soundEngine.playSplatSound(slamVelocity: impactData.velocityDegPerSec)
        
        // Trigger the signature decaying dying insect vibration inside the closed phone!
        soundEngine.triggerDyingFlyVibration()
        
        // Register Symmetrical Mirrored Splatter across the hinge!
        let splatter = SplatterRecord(
            primaryPosition: insect.position,
            hingeX: self.hingeX,
            insectType: insect.type,
            scale: 1.0
        )
        persistentSplatters.append(splatter)
        
        // Scoring & Combos (Bonus awarded for safe, smooth folding rather than phone-breaking slams)
        streak += 1
        let streakMultiplier = min(5, 1 + (streak / 3))
        let safetyBonus = impactData.isMach2 ? 50 : 250 // Reward gentle closing!
        let basePts = insect.type.baseScore
        let totalPts = (basePts * streakMultiplier) + safetyBonus
        
        score += totalPts
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
        
        // Praise badge evaluation
        let praise: String
        if impactData.isMach2 {
            praise = "TOO HARD! FOLD GENTLY!"
        } else if reactionMs < 500 {
            praise = "LIGHTNING REFLEX!"
            soundEngine.playGodlikeFanfare()
        } else if reactionMs < 1200 {
            praise = "SMOOTH & SAFE SWAT!"
        } else if reactionMs < 2200 {
            praise = "PERFECT TIMING!"
        } else {
            praise = "TRAPPED IN TIME!"
        }
        
        self.lastOutcome = SwatOutcome(
            hit: true,
            insectType: insect.type,
            reactionTimeMs: reactionMs,
            slamVelocity: impactData.velocityDegPerSec,
            isMach2: impactData.isMach2,
            pointsEarned: totalPts,
            praiseText: praise,
            mockingText: "",
            isStung: false,
            isBossDamagedOnly: false
        )
        
        // Mach 2 "Too Hard!" Easter Egg check
        if impactData.isMach2 {
            self.crackedScreenImpactPoint = CGPoint(x: hingeX, y: insect.position.y)
            soundEngine.playGlassShatterSound()
            self.showCrackedScreenOverlay = true
        }
        
        self.activeInsect?.state = .swatted
    }
    
    private func handleWaspStungOutcome(velocity: Double, reactionMs: Int) {
        soundEngine.playStingSound()
        self.lives = 0
        self.streak = 0
        self.gameState = .gameOver
        
        self.lastOutcome = SwatOutcome(
            hit: false,
            insectType: .wasp,
            reactionTimeMs: reactionMs,
            slamVelocity: velocity,
            isMach2: false,
            pointsEarned: 0,
            praiseText: "",
            mockingText: "OUCH! STUNG! Wasps attack when folded!",
            isStung: true,
            isBossDamagedOnly: false
        )
    }
    
    private func handleBossDamagedOutcome(velocity: Double) {
        soundEngine.playSplatSound(slamVelocity: velocity)
        self.activeInsect?.health -= 1
        
        self.lastOutcome = SwatOutcome(
            hit: true,
            insectType: .mutantHorsefly,
            reactionTimeMs: 0,
            slamVelocity: velocity,
            isMach2: false,
            pointsEarned: 200,
            praiseText: "BOSS CRACKED!",
            mockingText: "DOUBLE-CLAP! It survived the 1st slap!",
            isStung: false,
            isBossDamagedOnly: true
        )
        
        // Horsefly takes off furiously for round 2!
        self.activeInsect?.state = .flying
        self.activeInsect?.flightTimeBeforeLanding = 1.2
    }
    
    private func handleAirWhiffOutcome(velocity: Double) {
        soundEngine.playWhiffSound()
        self.streak = 0
        self.lives = 0
        self.gameState = .gameOver
        
        let mockingMessages = [
            "Too slow! You just clapped your $2,000 phone for nothing.",
            "WHIFF! The fly dodged your folding hinge.",
            "Air slap! The fly is laughing at your screen.",
            "Too eager! Wait until it rubs its front legs!"
        ]
        
        self.lastOutcome = SwatOutcome(
            hit: false,
            insectType: activeInsect?.type ?? .housefly,
            reactionTimeMs: 0,
            slamVelocity: velocity,
            isMach2: false,
            pointsEarned: 0,
            praiseText: "",
            mockingText: mockingMessages.randomElement()!,
            isStung: false,
            isBossDamagedOnly: false
        )
    }
    
    // MARK: - Reopening & Reveal State
    
    private func handleHingeAngleChange(_ angle: Double) {
        // When device reopens past 140°, transition to REVEAL state
        if gameState == .swatted && angle > 130.0 {
            self.gameState = .revealing
            
            if lives <= 0 {
                self.gameState = .gameOver
                return
            }
            
            // Automatically advance to the next wave after player inspects the splat/aftermath
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
                guard let self = self, self.gameState == .revealing else { return }
                self.advanceToNextWave()
            }
        }
    }
    
    public func advanceToNextWave() {
        self.lastOutcome = nil
        self.currentWave += 1
        self.gameState = .hunting
        startWave()
    }
    
    // MARK: - Screen Sponge Cleaning
    
    public func wipeScreenWithSponge() {
        guard !persistentSplatters.isEmpty, !isSpongeWiping else { return }
        
        self.isSpongeWiping = true
        soundEngine.playSpongeWipeSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.persistentSplatters.removeAll()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.isSpongeWiping = false
        }
    }
}
