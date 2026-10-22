import SwiftUI

/// Main Game Interface: Renders the dual-screen foldable iPhone layout
/// with 100% active hardware sensors (Proximity + CMMotionManager Gyroscope & Accelerometer)
/// and natural inward fold gestures. Zero debug UI.
public struct FoldableDualScreenContainer: View {
    @ObservedObject var gameEngine = ClapTrapGameEngine.shared
    @ObservedObject var foldSensor = FoldSensorManager.shared
    
    // Inward gesture tracking
    @State private var dragLastX: CGFloat = 0.0
    @State private var dragLastTime: Date = Date()
    @State private var isDraggingFold: Bool = false
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            let screenSize = proxy.size
            let isExternalCoverScreen = (screenSize.width / screenSize.height) < 0.70
            
            Group {
                if isExternalCoverScreen {
                    // 1. EXTERNAL COVER SCREEN (Phone Closed)
                    // The game NEVER runs on this cover screen under any circumstance.
                    // Strictly shows the trapped buzzing fly and prompts player to unfold.
                    ExternalCoverScreenView()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    // 2. UNFOLDED INNER DUAL-SCREEN PLAYFIELD
                    dualScreenPlayfield(screenSize: screenSize)
                }
            }
            .onAppear {
                updateScreenConfiguration(size: screenSize)
            }
            .onChange(of: proxy.size) { newSize in
                updateScreenConfiguration(size: newSize)
            }
        }
    }
    
    // MARK: - Screen Geometry & Hardware Unfold Handling
    
    private func updateScreenConfiguration(size: CGSize) {
        gameEngine.dualScreenSize = size
        let aspectRatio = size.width / size.height
        
        if aspectRatio >= 0.70 {
            // Unfolded to inner dual-screen!
            if foldSensor.isCoverScreen {
                foldSensor.isCoverScreen = false
                gameEngine.handleDeviceUnfolded()
            }
        } else {
            // Folded closed onto narrow external cover screen!
            if !foldSensor.isCoverScreen {
                foldSensor.isCoverScreen = true
                ProceduralSoundEngine.shared.stopBuzz()
            }
        }
    }
    
    // MARK: - Dual Screen Playfield
    
    @ViewBuilder
    private func dualScreenPlayfield(screenSize: CGSize) -> some View {
        let midX = screenSize.width / 2.0
        let foldProgress = (180.0 - foldSensor.hingeAngle) / 180.0
        
        ZStack {
            // 1. DUAL-SCREEN BOOK FOLD PLAYFIELD
            // Splits cleanly into Left Screen and Right Screen, folding inward
            // symmetrically toward the central hinge seam!
            HStack(spacing: 0) {
                // LEFT SCREEN HALF
                ZStack {
                    // Picnic Table & Left Content
                    PicnicTableView(hingeAngle: foldSensor.hingeAngle)
                        .frame(width: screenSize.width, height: screenSize.height)
                        .offset(x: midX * 0.5)
                    
                    // Centered Bait Prop
                    WatermelonBaitView()
                        .position(x: midX - 8, y: screenSize.height * 0.52)
                    
                    // Persistent Splatters on Left Half
                    ForEach(gameEngine.persistentSplatters) { splatter in
                        SplatView(splatter: splatter)
                    }
                    
                    // Active Insect
                    if let insect = gameEngine.activeInsect, insect.state != .swatted {
                        InsectSpriteView(insect: insect)
                            .position(insect.position)
                    }
                }
                .frame(width: midX, height: screenSize.height)
                .clipped()
                // 3D fold left half inward toward central crease
                .rotation3DEffect(
                    .degrees(foldProgress * 75.0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .trailing,
                    perspective: 0.5
                )
                
                // RIGHT SCREEN HALF
                ZStack {
                    // Picnic Table & Right Content
                    PicnicTableView(hingeAngle: foldSensor.hingeAngle)
                        .frame(width: screenSize.width, height: screenSize.height)
                        .offset(x: -midX * 0.5)
                    
                    // Centered Bait Prop
                    WatermelonBaitView()
                        .position(x: -8, y: screenSize.height * 0.52)
                    
                    // Persistent Splatters on Right Half
                    ForEach(gameEngine.persistentSplatters) { splatter in
                        SplatView(splatter: splatter)
                            .offset(x: -midX)
                    }
                    
                    // Active Insect
                    if let insect = gameEngine.activeInsect, insect.state != .swatted {
                        InsectSpriteView(insect: insect)
                            .offset(x: -midX)
                            .position(x: insect.position.x - midX, y: insect.position.y)
                    }
                }
                .frame(width: midX, height: screenSize.height)
                .clipped()
                // 3D fold right half inward toward central crease
                .rotation3DEffect(
                    .degrees(-foldProgress * 75.0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    perspective: 0.5
                )
            }
            .edgesIgnoringSafeArea(.all)
            // Natural Inward Fold Gesture & Tap-to-Clap
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        handleInwardDragChanged(value: value, midX: midX)
                    }
                    .onEnded { value in
                        handleInwardDragEnded(value: value, midX: midX)
                    }
            )
            .onTapGesture {
                handleDirectScreenClapTap()
            }
            
            // 2. HUD LAYER (Score, Wave, Streak, Lives, Clean Screen Sponge)
            if gameEngine.gameState != .menu && gameEngine.gameState != .gameOver {
                VStack {
                    GameHUDView()
                    Spacer()
                }
            }
            
            // 3. REVEAL AFTERMATH BANNER (When reopened after a swat)
            if gameEngine.gameState == .revealing, let outcome = gameEngine.lastOutcome {
                SwatAftermathBanner(outcome: outcome) {
                    gameEngine.advanceToNextWave()
                }
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
            
            // 4. MENU SCREEN
            if gameEngine.gameState == .menu {
                TitleMenuView(
                    onStartGame: {
                        gameEngine.startGame()
                    }
                )
                .transition(.opacity)
            }
            
            // 5. GAME OVER SCREEN
            if gameEngine.gameState == .gameOver {
                GameOverBragView(
                    score: gameEngine.score,
                    highScore: gameEngine.highScore,
                    wave: gameEngine.currentWave,
                    onRetry: {
                        gameEngine.startGame()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // 6. CRACKED SCREEN EASTER EGG OVERLAY
            if gameEngine.showCrackedScreenOverlay {
                CrackedGlassOverlay(impactPoint: gameEngine.crackedScreenImpactPoint) {
                    gameEngine.showCrackedScreenOverlay = false
                }
            }
            
            // 7. SPONGE WIPE FOAM OVERLAY
            if gameEngine.isSpongeWiping {
                SpongeWipeAnimationOverlay {}
            }
        }
    }
    
    // MARK: - Natural Gesture Controls
    
    private func handleInwardDragChanged(value: DragGesture.Value, midX: CGFloat) {
        let now = Date()
        let dt = max(0.001, now.timeIntervalSince(dragLastTime))
        let dx = value.location.x - dragLastX
        let velocity = abs(dx / CGFloat(dt))
        
        self.dragLastX = value.location.x
        self.dragLastTime = now
        self.isDraggingFold = true
        
        let distFromEdge: CGFloat
        if value.startLocation.x < midX {
            distFromEdge = value.location.x
        } else {
            distFromEdge = (midX * 2.0) - value.location.x
        }
        
        let progress = max(0.0, min(1.0, distFromEdge / midX))
        foldSensor.handleFoldGestureProgress(progress: progress, velocity: velocity)
    }
    
    private func handleInwardDragEnded(value: DragGesture.Value, midX: CGFloat) {
        self.isDraggingFold = false
        let dx = value.translation.width
        let speed = abs(value.predictedEndTranslation.width - dx)
        let didSnap = foldSensor.hingeAngle < 80.0 || speed > 300.0
        
        foldSensor.handleFoldGestureEnded(didSnapShut: didSnap, velocity: speed * 3.0)
    }
    
    private func handleDirectScreenClapTap() {
        if gameEngine.gameState == .landed {
            foldSensor.triggerDirectClapSwat(velocity: 1350.0)
        }
    }
}

// MARK: - Swat Aftermath Banner
struct SwatAftermathBanner: View {
    let outcome: SwatOutcome
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            if outcome.hit {
                VStack(spacing: 4) {
                    Text(outcome.praiseText)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                    
                    if outcome.reactionTimeMs > 0 {
                        Text("\(outcome.reactionTimeMs)ms REACTION TIME")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    if outcome.isMach2 {
                        Text("🚀 MACH 2 CLAP! (+500 BONUS)")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                    
                    Text("+\(outcome.pointsEarned) PTS")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                }
            } else if outcome.isStung {
                VStack(spacing: 4) {
                    Text("🐝 YOU GOT STUNG! 🐝")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                    
                    Text(outcome.mockingText)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("-1 LIFE")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.red)
                }
            } else {
                VStack(spacing: 4) {
                    Text("💨 WHIFF! MISSED! 💨")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text(outcome.mockingText)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: onContinue) {
                Text("NEXT WAVE ➔")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            outcome.hit ? Color.green : (outcome.isStung ? Color.red : Color.orange),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: .black.opacity(0.6), radius: 8)
    }
}

// MARK: - Title Menu View
struct TitleMenuView: View {
    let onStartGame: () -> Void
    @State private var pulse: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Spacer()
                
                VStack(spacing: 4) {
                    Text("CLAPTRAP")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .yellow.opacity(0.6), radius: 12)
                    
                    Text("THE FOLDABLE FLY SWATTER")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)
                        .tracking(3)
                }
                
                // Bestiary Showcase Cards
                VStack(spacing: 6) {
                    Text("TARGET INTEL")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 8) {
                        BestiaryPill(name: "HOUSEFLY", desc: "Clap on land", color: .green)
                        BestiaryPill(name: "MOSQUITO", desc: "460Hz Fast", color: .cyan)
                        BestiaryPill(name: "HORSEFLY", desc: "2x Clap Boss", color: .purple)
                        BestiaryPill(name: "WASP", desc: "DO NOT CLAP!", color: .red)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: onStartGame) {
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                            Text("TAP TO START HUNTING")
                            Image(systemName: "hand.tap.fill")
                        }
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: .yellow.opacity(pulse ? 0.9 : 0.4), radius: pulse ? 16 : 6)
                    .scaleEffect(pulse ? 1.03 : 0.98)
                }
                .padding(.horizontal, 24)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
                
                if ClapTrapGameEngine.shared.highScore > 0 {
                    Text("ALL-TIME HIGH SCORE: \(ClapTrapGameEngine.shared.highScore)")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.yellow.opacity(0.9))
                }
                
                Spacer().frame(height: 50)
            }
        }
    }
}

struct BestiaryPill: View {
    let name: String
    let desc: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(name)
                .font(.system(size: 8, weight: .black, design: .monospaced))
                .foregroundColor(color)
            Text(desc)
                .font(.system(size: 7, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.08))
        .cornerRadius(6)
    }
}

// MARK: - Game Over & Viral Brag View
struct GameOverBragView: View {
    let score: Int
    let highScore: Int
    let wave: Int
    let onRetry: () -> Void
    
    @State private var copied: Bool = false
    
    var bragText: String {
        "I reached Wave \(wave) with \(score) pts in ClapTrap: The Foldable Fly Swatter on my $2,000 Foldable iPhone! 🪰📱⚡️"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("GAME OVER")
                    .font(.system(size: 34, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                
                VStack(spacing: 8) {
                    Text("FINAL SCORE")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    Text("\(score)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                    
                    Text("WAVES SURVIVED: \(wave)")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                    
                    if score >= highScore && score > 0 {
                        Text("🏆 NEW HIGH SCORE! 🏆")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.06))
                .cornerRadius(16)
                
                Button(action: {
                    UIPasteboard.general.string = bragText
                    withAnimation { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { copied = false }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: copied ? "checkmark.circle.fill" : "square.and.arrow.up")
                        Text(copied ? "COPIED TO CLIPBOARD!" : "COPY BRAG CARD")
                    }
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(copied ? Color.green : Color.cyan)
                    .cornerRadius(10)
                }
                
                Button(action: onRetry) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.yellow)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 36)
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
        }
    }
}
