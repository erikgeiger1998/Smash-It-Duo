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
            let isCover = isExternalCoverScreen(size: screenSize)
            let isClosedOrCover = isCover || foldSensor.isClosed
            
            Group {
                if isClosedOrCover {
                    // 1. EXTERNAL COVER SCREEN (Phone Closed)
                    // The game NEVER runs on this cover screen under any circumstance (portrait or landscape).
                    // Strictly shows whether the fly was trapped or escaped, and prompts player to unfold.
                    ExternalCoverScreenView()
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                } else {
                    // 2. UNFOLDED INNER DUAL-SCREEN PLAYFIELD
                    dualScreenPlayfield(screenSize: screenSize)
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                }
            }
            .overlay(
                Group {
                    if gameEngine.isGameMenuPresented {
                        GameMenuView(onDismiss: {
                            gameEngine.isGameMenuPresented = false
                        })
                        .transition(.opacity)
                    } else if gameEngine.isGamePaused {
                        GamePauseOverlayView()
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
            )
            .onAppear {
                updateScreenConfiguration(size: screenSize)
            }
            .onChange(of: proxy.size) { newSize in
                updateScreenConfiguration(size: newSize)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
    }
    
    // MARK: - Screen Geometry & Hardware Unfold Handling
    
    /// Any single phone / external cover screen has its short dimension <= 500pt
    /// (typically ~380-430pt), whether held in portrait or landscape!
    /// An unfolded inner dual-screen has BOTH dimensions >= 580pt (typically ~750-950pt).
    private func isExternalCoverScreen(size: CGSize) -> Bool {
        let minDimension = min(size.width, size.height)
        return minDimension < 580.0
    }
    
    private func updateScreenConfiguration(size: CGSize) {
        let isCover = isExternalCoverScreen(size: size)
        
        if !isCover {
            gameEngine.dualScreenSize = size
            // Unfolded to inner dual-screen!
            if foldSensor.isCoverScreen || foldSensor.isClosed {
                foldSensor.reopenFlat()
            }
        } else {
            // Folded closed onto external cover screen (portrait OR landscape)!
            if !foldSensor.isCoverScreen {
                foldSensor.isCoverScreen = true
                
                // PHYSICAL PHONE / EMULATOR CLOSURE = THE SWAT STRIKE!
                // The instant the device completely folds shut, this triggers the swat!
                if gameEngine.gameState == .landed || gameEngine.gameState == .hunting {
                    foldSensor.triggerHardwareSlamShut(velocity: 1100.0)
                } else {
                    ProceduralSoundEngine.shared.stopBuzz()
                }
            }
        }
    }
    
    // MARK: - Dual Screen Playfield
    
    @ViewBuilder
    private func dualScreenPlayfield(screenSize: CGSize) -> some View {
        let midX = screenSize.width / 2.0
        let foldProgress = (180.0 - foldSensor.hingeAngle) / 180.0
        
        ZStack {
            // Full Edge-to-Edge Theme Background Base to prevent any black bars
            gameEngine.currentTheme.baseBackgroundColor
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            // 1. DUAL-SCREEN BOOK FOLD PLAYFIELD
            // Splits cleanly into Left Screen and Right Screen, folding inward
            // symmetrically toward the central hinge seam!
            // The whole background is strictly underneath the dead flies, active insect, and food bait!
            HStack(spacing: 0) {
                // LEFT SCREEN HALF
                ZStack {
                    // Picnic Table & Left Content
                    PicnicTableView(hingeAngle: foldSensor.hingeAngle, theme: gameEngine.currentTheme)
                        .frame(width: screenSize.width, height: screenSize.height)
                        .offset(x: midX * 0.5)
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
                    PicnicTableView(hingeAngle: foldSensor.hingeAngle, theme: gameEngine.currentTheme)
                        .frame(width: screenSize.width, height: screenSize.height)
                        .offset(x: -midX * 0.5)
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
            // Natural Inward Fold Gesture (Two-Thumb / Swipe Inward to Fold)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        handleInwardDragChanged(value: value, midX: midX)
                    }
                    .onEnded { value in
                        handleInwardDragEnded(value: value, midX: midX)
                    }
            )
            
            // 2. PERSISTENT DEAD FLIES SPLATTER LAYER (ON TABLE SURFACE)
            // Exactly ONE dead fly per kill — realistic, stationary, and never duplicated!
            // Each dead fly remains fixed on the exact spot where it was killed without shifting.
            ForEach(gameEngine.persistentSplatters) { splatter in
                SplatView(splatter: splatter)
                    .position(splatter.position(for: screenSize))
            }
            
            // 3. CENTERED FOOD BAIT PROP (On Table Surface)
            FoodBaitPlateView(bait: gameEngine.currentBait)
                .position(x: midX, y: screenSize.height * 0.52)
                .scaleEffect(max(0.1, 1.0 - foldProgress * 0.6))
            
            // 4. ACTIVE INSECT LAYER
            // Always rendered ON TOP of the entire background (both left and right screen halves)
            // and above the food bait, ensuring the fly, its wings, and its flight shadow never
            // get clipped by the center crease or fly behind the table!
            if let insect = gameEngine.activeInsect, insect.state != .swatted {
                InsectSpriteView(insect: insect)
                    .position(insect.position)
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
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
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
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                            Text("SAFETY NOTICE: Fold phone gently.")
                        }
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                    }
                    
                    Text("+\(outcome.pointsEarned) PTS")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                }
            } else if outcome.isStung {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.shield.fill")
                        Text("STUNG BY WASP!")
                    }
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
                    HStack(spacing: 6) {
                        Image(systemName: "wind")
                        Text("MISSED! ESCAPED!")
                    }
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.orange)
                    
                    Text(outcome.mockingText)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: onContinue) {
                HStack(spacing: 4) {
                    Text("NEXT WAVE")
                    Image(systemName: "arrow.right")
                }
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
                Button(action: {
                    ClapTrapGameEngine.shared.openMenu(tab: 2)
                }) {
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "scope")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("TARGET INTEL & LEGEND")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.white.opacity(0.75))
                            Spacer()
                            Text("DETAILS")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        HStack(spacing: 6) {
                            BestiaryPill(name: "HOUSEFLY", desc: "SWAT", color: .green)
                            BestiaryPill(name: "MOSQUITO", desc: "FASTER", color: .cyan)
                            BestiaryPill(name: "HORSEFLY", desc: "2x FOLD", color: .purple)
                            BestiaryPill(name: "WASP", desc: "FORBIDDEN", color: .red)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: onStartGame) {
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("START HUNTING")
                            Image(systemName: "play.fill")
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
                
                // Action Buttons: Bestiary Guide & Settings
                HStack(spacing: 10) {
                    Button(action: {
                        ClapTrapGameEngine.shared.openMenu(tab: 2)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.pages.fill")
                                .foregroundColor(.yellow)
                            Text("BESTIARY")
                        }
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                    
                    Button(action: {
                        ClapTrapGameEngine.shared.openMenu(tab: 0)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.cyan)
                            Text("SETTINGS")
                        }
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                if ClapTrapGameEngine.shared.highScore > 0 {
                    Text("ALL-TIME HIGH SCORE: \(ClapTrapGameEngine.shared.highScore)")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.yellow.opacity(0.9))
                }
                
                Spacer().frame(height: 40)
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
        "I reached Wave \(wave) with \(score) pts in ClapTrap: The Foldable Fly Swatter on my Foldable iPhone!"
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
                        HStack(spacing: 6) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("NEW HIGH SCORE!")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.green)
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                        }
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

// MARK: - Game Pause Overlay View
public struct GamePauseOverlayView: View {
    @ObservedObject var gameEngine = ClapTrapGameEngine.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Dark Frosted Backdrop
            Color.black.opacity(0.68)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            // Chunky Cartoon Arcade Pause Dialogue Card
            VStack(spacing: 16) {
                // Header Banner
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(.yellow)
                        
                        Text("GAME PAUSED")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                            )
                    }
                    .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                    
                    Text("TAKE A BREATHER • YOUR REFLEXES ARE WAITING")
                        .font(.system(size: 9.5, weight: .black, design: .monospaced))
                        .foregroundColor(.white.opacity(0.65))
                        .tracking(1.5)
                }
                
                // Stats Card
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("WAVE")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(gameEngine.currentWave)")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("SCORE")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(gameEngine.score)")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                }
                
                // Action Buttons Stack
                VStack(spacing: 10) {
                    // Big Resume Button
                    Button(action: {
                        gameEngine.resumeGame()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .black))
                            Text("RESUME GAME")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: .yellow.opacity(0.4), radius: 8, y: 2)
                    }
                    
                    HStack(spacing: 10) {
                        // Settings Button
                        Button(action: {
                            gameEngine.openMenu(tab: 0)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "gearshape.fill")
                                Text("SETTINGS")
                            }
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Bestiary / Legend Button
                        Button(action: {
                            gameEngine.openMenu(tab: 2)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "scope")
                                Text("LEGEND")
                            }
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    
                    // Quit to Menu
                    Button(action: {
                        gameEngine.isGamePaused = false
                        gameEngine.returnToMenu()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "house.fill")
                            Text("QUIT TO MENU")
                        }
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.red.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.12))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.6), radius: 24, y: 8)
        }
    }
}
