import SwiftUI

/// External Cover Screen Interface:
/// Shown exclusively when the foldable phone is closed.
/// 100% CARTOON ARCADE FUN - vibrant, playful, juicy, and expressive!
/// Features:
/// - Sunny outdoor picnic table with warm wood planks and red-and-white checkered cloth.
/// - 3D bouncy cartoon game logo with cute fly swatter accents.
/// - Chubby, mischievous cartoon housefly with big shiny googly eyes, rubbing its legs greedily on a slice of juicy watermelon!
/// - Animated cartoon comic speech bubble with funny rotating taunts.
/// - Big, chunky cartoon wooden sign prompting the player to unfold the phone to squash the fly.
/// - When clapped: Comic starburst "SPLAT!" when trapped, or laughing fly when missed!
/// Zero external assets. 100% procedural code graphics and animation.
public struct ExternalCoverScreenView: View {
    @ObservedObject var gameEngine = ClapTrapGameEngine.shared
    
    @State private var bouncePulse: Bool = false
    @State private var quipIndex: Int = 0
    @State private var quipTimer: Timer?
    @State private var eyeLookOffset: CGFloat = 0.0
    @State private var legRubPhase: Bool = false
    @State private var wingFlapPhase: Bool = false
    
    private let funnyQuips = [
        "Mmm... tasty picnic treat!",
        "Bet you cannot squish me!",
        "Fold gently, protect your screen!",
        "Open the phone if you dare!",
        "Free crumbs! Do not mind if I do!",
        "Close smoothly, no need to slam!",
        "Too swift for two hands!",
        "Save your hinges, fold calmly!"
    ]
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let isLandscape = size.width > size.height
            
            ZStack {
                // 1. SUNNY PICNIC TABLE & CHECKERED BLANKET BACKGROUND
                CartoonPicnicTableBackground()
                    .edgesIgnoringSafeArea(.all)
                
                // Sunny Warm Light Beam Overlay
                RadialGradient(
                    colors: [
                        Color.yellow.opacity(0.18),
                        Color.orange.opacity(0.08),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 40,
                    endRadius: max(size.width, size.height) * 0.8
                )
                .edgesIgnoringSafeArea(.all)
                
                if isLandscape {
                    // LANDSCAPE COVER SCREEN (Side-by-Side Cartoon Layout)
                    HStack(spacing: 20) {
                        // Left Column: Logo + Cartoon Fly / Outcome
                        VStack(spacing: 6) {
                            Spacer()
                            
                            CartoonGameLogoView(isGameOver: isGameOver, isTrapped: isTrapped)
                                .scaleEffect(0.8)
                            
                            Spacer()
                            
                            if isGameOver {
                                CartoonEscapedFlyStage(
                                    mockingText: gameEngine.lastOutcome?.mockingText ?? "Too slow! The fly dodged your clap!"
                                )
                                .scaleEffect(0.76)
                            } else if isTrapped, let outcome = gameEngine.lastOutcome {
                                CartoonTrappedFlyStage(outcome: outcome)
                                    .scaleEffect(0.76)
                            } else {
                                CartoonIdleMischiefFlyStage(
                                    currentQuip: funnyQuips[quipIndex],
                                    eyeOffset: eyeLookOffset,
                                    legRub: legRubPhase,
                                    wingFlap: wingFlapPhase
                                )
                                .scaleEffect(0.76)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: size.width * 0.48)
                        
                        // Right Column: Stats & Wooden Call-to-Action Sign
                        VStack(spacing: 12) {
                            Spacer()
                            
                            if isGameOver || isTrapped {
                                outcomeStatsPill
                            }
                            
                            CartoonWoodenSignPrompt(
                                isGameOver: isGameOver,
                                isTrapped: isTrapped,
                                currentWave: gameEngine.currentWave,
                                bounce: bouncePulse
                            )
                            .onTapGesture {
                                FoldSensorManager.shared.reopenFlat()
                            }
                            
                            safetyDisclaimerView
                                .padding(.top, 2)
                            
                            Spacer()
                        }
                        .frame(maxWidth: size.width * 0.46)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                } else {
                    // PORTRAIT COVER SCREEN (Vertical Cartoon Layout)
                    VStack(spacing: 12) {
                        Spacer().frame(height: 14)
                        
                        // 2. BOUNCY 3D CARTOON LOGO
                        CartoonGameLogoView(isGameOver: isGameOver, isTrapped: isTrapped)
                            .scaleEffect(bouncePulse ? 1.02 : 0.98)
                        
                        Spacer()
                        
                        // 3. CENTRAL CHARACTER / OUTCOME STAGE
                        if isGameOver {
                            // Comic Whiff: Laughing fly zipping away!
                            CartoonEscapedFlyStage(
                                mockingText: gameEngine.lastOutcome?.mockingText ?? "Too slow! The fly dodged your clap!"
                            )
                        } else if isTrapped, let outcome = gameEngine.lastOutcome {
                            // Comic Splat: Squished fly with dizziness stars!
                            CartoonTrappedFlyStage(outcome: outcome)
                        } else {
                            // Mischievous Cartoon Fly on a Juicy Watermelon Wedge!
                            CartoonIdleMischiefFlyStage(
                                currentQuip: funnyQuips[quipIndex],
                                eyeOffset: eyeLookOffset,
                                legRub: legRubPhase,
                                wingFlap: wingFlapPhase
                            )
                        }
                        
                        Spacer()
                        
                        // 4. STATS POD (if game over or trapped)
                        if isGameOver || isTrapped {
                            outcomeStatsPill
                        }
                        
                        // 5. CHUNKY CARTOON WOODEN CALL-TO-ACTION SIGN
                        CartoonWoodenSignPrompt(
                            isGameOver: isGameOver,
                            isTrapped: isTrapped,
                            currentWave: gameEngine.currentWave,
                            bounce: bouncePulse
                        )
                        .onTapGesture {
                            FoldSensorManager.shared.reopenFlat()
                        }
                        
                        // 6. GENTLE FOLD SAFETY NOTICE
                        safetyDisclaimerView
                            .padding(.top, 2)
                        
                        Spacer().frame(height: 18)
                    }
                    .padding(.horizontal, 18)
                }
                
                // Top Right Settings & Legenda Buttons (Cover Screen)
                VStack {
                    HStack(spacing: 8) {
                        Spacer()
                        
                        Button(action: {
                            gameEngine.openMenu(tab: 2)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "scope")
                                    .font(.system(size: 13, weight: .bold))
                                Text("LEGENDA")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                            .foregroundColor(Color(red: 0.35, green: 0.15, blue: 0.05))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.85))
                                    .shadow(color: .black.opacity(0.18), radius: 4, y: 1)
                            )
                        }
                        
                        Button(action: {
                            gameEngine.openMenu(tab: 0)
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0.35, green: 0.15, blue: 0.05))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.85))
                                        .shadow(color: .black.opacity(0.18), radius: 4, y: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, isLandscape ? 8 : 14)
                    
                    Spacer()
                }
            }
            .onAppear {
                startCartoonAnimations()
            }
            .onDisappear {
                quipTimer?.invalidate()
                quipTimer = nil
            }
        }
    }
    
    // MARK: - State Queries
    
    private var isTrapped: Bool {
        gameEngine.lastOutcome?.hit == true
    }
    
    private var isGameOver: Bool {
        gameEngine.gameState == .gameOver || (gameEngine.lastOutcome != nil && gameEngine.lastOutcome?.hit == false)
    }
    
    // MARK: - Safety Disclaimer Badge
    private var safetyDisclaimerView: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(red: 0.55, green: 0.28, blue: 0.12))
            Text("SAFETY NOTICE: Fold phone gently.")
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 0.45, green: 0.20, blue: 0.08))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.70))
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.55, green: 0.28, blue: 0.12).opacity(0.35), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Animation Timers
    
    private func startCartoonAnimations() {
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            bouncePulse = true
        }
        
        // Rapid leg rubbing
        withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) {
            legRubPhase = true
        }
        
        // Wings flapping
        withAnimation(.easeInOut(duration: 0.06).repeatForever(autoreverses: true)) {
            wingFlapPhase = true
        }
        
        // Eyes looking around
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            eyeLookOffset = 4.0
        }
        
        // Speech bubble rotation
        quipTimer?.invalidate()
        quipTimer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                quipIndex = (quipIndex + 1) % funnyQuips.count
            }
        }
    }
    
    // MARK: - Outcome Stats Pill
    
    @ViewBuilder
    private var outcomeStatsPill: some View {
        HStack(spacing: 12) {
            if isTrapped, let outcome = gameEngine.lastOutcome {
                if outcome.reactionTimeMs > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("\(outcome.reactionTimeMs)ms")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.45))
                    .cornerRadius(10)
                }
                
                HStack(spacing: 4) {
                    Text("+\(outcome.pointsEarned)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                    Text("PTS")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.85))
                .cornerRadius(10)
            } else {
                HStack(spacing: 6) {
                    Text("SCORE: \(gameEngine.score)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                    Text("•")
                        .foregroundColor(.white.opacity(0.6))
                    Text("WAVES: \(max(0, gameEngine.currentWave - 1))")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.55))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - 1. Cartoon Picnic Table & Checkered Blanket Background
struct CartoonPicnicTableBackground: View {
    var body: some View {
        Canvas { context, size in
            // Warm Oak Wood Planks
            let plankColors = [
                Color(red: 0.82, green: 0.58, blue: 0.36),
                Color(red: 0.88, green: 0.64, blue: 0.40),
                Color(red: 0.78, green: 0.54, blue: 0.32),
                Color(red: 0.85, green: 0.60, blue: 0.38)
            ]
            
            let plankHeight: CGFloat = 85
            let totalPlanks = Int(ceil(size.height / plankHeight)) + 1
            
            for i in 0..<totalPlanks {
                let y = CGFloat(i) * plankHeight
                let rect = CGRect(x: 0, y: y, width: size.width, height: plankHeight - 3)
                let color = plankColors[i % plankColors.count]
                
                // Base Plank
                context.fill(Path(rect), with: .color(color))
                
                // Subtle Wood Grain Path
                var grain = Path()
                let midY = y + plankHeight * 0.45
                grain.move(to: CGPoint(x: 0, y: midY))
                grain.addCurve(
                    to: CGPoint(x: size.width, y: midY - 6),
                    control1: CGPoint(x: size.width * 0.35, y: midY + 12),
                    control2: CGPoint(x: size.width * 0.65, y: midY - 14)
                )
                context.stroke(grain, with: .color(Color(red: 0.68, green: 0.45, blue: 0.25).opacity(0.35)), lineWidth: 2)
                
                // Plank Seam Shadow
                let seamRect = CGRect(x: 0, y: y + plankHeight - 3, width: size.width, height: 3)
                context.fill(Path(seamRect), with: .color(Color(red: 0.40, green: 0.25, blue: 0.15)))
            }
            
            // Red-and-White Checkered Picnic Gingham Cloth (Draped diagonally across table)
            let clothW = size.width * 0.88
            let clothH = size.height * 0.48
            let clothOrigin = CGPoint(x: (size.width - clothW) / 2.0, y: size.height * 0.22)
            let clothRect = CGRect(origin: clothOrigin, size: CGSize(width: clothW, height: clothH))
            
            // Cloth Drop Shadow
            var clothPath = Path()
            clothPath.addRoundedRect(in: clothRect.insetBy(dx: -4, dy: -4), cornerSize: CGSize(width: 22, height: 22))
            context.fill(clothPath, with: .color(Color.black.opacity(0.28)))
            
            // White Cloth Base
            var innerCloth = Path()
            innerCloth.addRoundedRect(in: clothRect, cornerSize: CGSize(width: 20, height: 20))
            context.fill(innerCloth, with: .color(Color(red: 0.98, green: 0.98, blue: 0.96)))
            
            // Checkered Red Squares inside cloth
            let gridSize: CGFloat = 34
            let cols = Int(clothW / gridSize) + 1
            let rows = Int(clothH / gridSize) + 1
            
            var clippedContext = context
            clippedContext.clip(to: innerCloth)
            
            for r in 0..<rows {
                for c in 0..<cols {
                    let rx = clothOrigin.x + CGFloat(c) * gridSize
                    let ry = clothOrigin.y + CGFloat(r) * gridSize
                    let sq = CGRect(x: rx, y: ry, width: gridSize, height: gridSize)
                    
                    if (r + c) % 2 == 0 {
                        // Light Red Check
                        clippedContext.fill(Path(sq), with: .color(Color(red: 0.92, green: 0.28, blue: 0.32).opacity(0.75)))
                    } else if r % 2 == 0 {
                        // Deep Intersection Red Check
                        clippedContext.fill(Path(sq), with: .color(Color(red: 0.82, green: 0.18, blue: 0.22).opacity(0.92)))
                    }
                }
            }
            
            // Stitching Border on Cloth
            context.stroke(
                innerCloth,
                with: .color(Color(red: 0.75, green: 0.15, blue: 0.20)),
                style: StrokeStyle(lineWidth: 3, dash: [8, 5])
            )
        }
    }
}

// MARK: - 2. Bouncy 3D Cartoon Game Logo
struct CartoonGameLogoView: View {
    let isGameOver: Bool
    let isTrapped: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            if isGameOver {
                // Defeat Header
                VStack(spacing: 2) {
                    Text("MISSED!")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: Color(red: 0.5, green: 0.1, blue: 0.1), radius: 0, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 8)
                    
                    Text("GAME OVER")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                }
            } else if isTrapped {
                // Trapped Victory Header
                VStack(spacing: 2) {
                    Text("SPLAT!")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .green, .cyan], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: Color(red: 0.1, green: 0.4, blue: 0.2), radius: 0, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 8)
                    
                    Text("FLY TRAPPED")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.15, green: 0.65, blue: 0.3))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                }
            } else {
                // Main Cartoon Game Logo: "CLAPTRAP"
                ZStack {
                    // Back Swatters crossed
                    HStack(spacing: 80) {
                        CartoonFlySwatterPaddle(color: .red)
                            .rotationEffect(.degrees(-25))
                        CartoonFlySwatterPaddle(color: .blue)
                            .rotationEffect(.degrees(25))
                    }
                    .frame(height: 50)
                    .offset(y: -5)
                    
                    // 3D Layered Cartoon Text
                    VStack(spacing: -8) {
                        HStack(spacing: 2) {
                            Text("CLAP")
                                .font(.system(size: 46, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                                )
                            Text("TRAP")
                                .font(.system(size: 46, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [Color(red: 1.0, green: 0.35, blue: 0.45), .red], startPoint: .top, endPoint: .bottom)
                                )
                        }
                        .shadow(color: Color(red: 0.45, green: 0.18, blue: 0.08), radius: 0, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 7)
                        
                        // Wooden Plaquette Ribbon
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("THE FOLDABLE FLY SWATTER")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(1)
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.35, green: 0.20, blue: 0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.yellow.opacity(0.8), lineWidth: 1.5)
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    }
                }
            }
        }
    }
}

// MARK: - Mini Cartoon Fly Swatter
struct CartoonFlySwatterPaddle: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let paddleRect = CGRect(x: size.width * 0.15, y: 0, width: size.width * 0.7, height: size.height * 0.75)
            var paddle = Path()
            paddle.addRoundedRect(in: paddleRect, cornerSize: CGSize(width: 8, height: 8))
            
            // Paddle Rim
            context.fill(paddle, with: .color(color.opacity(0.85)))
            
            // Grid holes inside paddle
            let rows = 4
            let cols = 3
            let stepX = paddleRect.width / CGFloat(cols + 1)
            let stepY = paddleRect.height / CGFloat(rows + 1)
            
            for r in 1...rows {
                for c in 1...cols {
                    let hx = paddleRect.minX + CGFloat(c) * stepX
                    let hy = paddleRect.minY + CGFloat(r) * stepY
                    let hole = Path(ellipseIn: CGRect(x: hx - 2.5, y: hy - 2.5, width: 5, height: 5))
                    context.fill(hole, with: .color(Color.black.opacity(0.35)))
                }
            }
            
            // Swatter Handle
            var handle = Path()
            handle.addRoundedRect(in: CGRect(x: size.width * 0.45, y: size.height * 0.7, width: size.width * 0.1, height: size.height * 0.3), cornerSize: CGSize(width: 3, height: 3))
            context.fill(handle, with: .color(Color(red: 0.2, green: 0.2, blue: 0.25)))
        }
        .frame(width: 38, height: 48)
    }
}

// MARK: - 3. Central Character: Chubby Mischief Fly on Watermelon!
struct CartoonIdleMischiefFlyStage: View {
    let currentQuip: String
    let eyeOffset: CGFloat
    let legRub: Bool
    let wingFlap: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Comic Speech Bubble
            ZStack {
                // Speech Bubble Body
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.25, green: 0.15, blue: 0.1), lineWidth: 2.5)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                
                // Speech Bubble Pointer
                TrianglePointer()
                    .fill(Color.white)
                    .frame(width: 14, height: 9)
                    .offset(x: -20, y: 22)
                
                Text(currentQuip)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.15, blue: 0.1))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
            }
            .frame(height: 42)
            .padding(.horizontal, 28)
            .transition(.scale.combined(with: .opacity))
            
            // The Chubby Cartoon Fly + Juicy Watermelon Slice
            ZStack {
                // Juicy Watermelon Slice underneath!
                CartoonWatermelonWedgeView()
                    .offset(y: 28)
                
                // Chubby Cartoon Fly sitting on the fruit
                ChubbyCartoonFlyCharacter(
                    eyeOffset: eyeOffset,
                    legRub: legRub,
                    wingFlap: wingFlap
                )
                .offset(y: -18)
            }
            .frame(width: 250, height: 180)
        }
    }
}

// Speech Bubble Pointer Shape
struct TrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Chubby Cartoon Fly Character
struct ChubbyCartoonFlyCharacter: View {
    let eyeOffset: CGFloat
    let legRub: Bool
    let wingFlap: Bool
    
    var body: some View {
        ZStack {
            // Translucent Fluttering Cartoon Wings
            HStack(spacing: -10) {
                // Left Wing
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.75), Color.cyan.opacity(0.45)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Ellipse()
                            .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                    )
                    .frame(width: 44, height: 26)
                    .rotationEffect(.degrees(wingFlap ? -38 : -18), anchor: .bottomTrailing)
                
                // Right Wing
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.75), Color.cyan.opacity(0.45)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Ellipse()
                            .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                    )
                    .frame(width: 44, height: 26)
                    .rotationEffect(.degrees(wingFlap ? 38 : 18), anchor: .bottomLeading)
            }
            .offset(y: -18)
            
            // 4 Jointed Spiky Cartoon Legs (Vector Capsules)
            HStack(spacing: 56) {
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 14, height: 3.5)
                        .rotationEffect(.degrees(35))
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 15, height: 3.5)
                        .rotationEffect(.degrees(70))
                }
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 14, height: 3.5)
                        .rotationEffect(.degrees(-35))
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 15, height: 3.5)
                        .rotationEffect(.degrees(-70))
                }
            }
            .offset(y: 4)
            
            // Chubby Plump Abdomen (Metallic Greenish Blue)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.18, green: 0.55, blue: 0.45),
                            Color(red: 0.08, green: 0.22, blue: 0.28),
                            Color(red: 0.04, green: 0.10, blue: 0.15)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 35
                    )
                )
                .overlay(
                    Ellipse()
                        .stroke(Color(red: 0.25, green: 0.75, blue: 0.55).opacity(0.6), lineWidth: 2)
                )
                .frame(width: 58, height: 50)
                .shadow(color: .black.opacity(0.4), radius: 6, y: 4)
            
            // Abdomen Segments
            VStack(spacing: 5) {
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 36, height: 3)
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 44, height: 3)
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 34, height: 3)
            }
            .offset(y: 6)
            
            // Thorax & Head
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.22, green: 0.24, blue: 0.28), Color.black],
                        center: .top,
                        startRadius: 4,
                        endRadius: 22
                    )
                )
                .frame(width: 36, height: 36)
                .offset(y: -14)
            
            // ENORMOUS SHINY GOOGLY RED EYES!
            HStack(spacing: 2) {
                // Left Eye
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(red: 1.0, green: 0.25, blue: 0.35), Color(red: 0.65, green: 0.08, blue: 0.15)],
                                center: .topLeading,
                                startRadius: 2,
                                endRadius: 14
                            )
                        )
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                    
                    // Pupil looking around
                    Circle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                        .offset(x: eyeOffset - 2, y: 1)
                    
                    // Cute anime shiny glints
                    Circle()
                        .fill(Color.white)
                        .frame(width: 5, height: 5)
                        .offset(x: -4, y: -4)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2.5, height: 2.5)
                        .offset(x: 3, y: 3)
                }
                
                // Right Eye
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(red: 1.0, green: 0.25, blue: 0.35), Color(red: 0.65, green: 0.08, blue: 0.15)],
                                center: .topLeading,
                                startRadius: 2,
                                endRadius: 14
                            )
                        )
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                    
                    // Pupil looking around
                    Circle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                        .offset(x: eyeOffset - 2, y: 1)
                    
                    // Cute anime shiny glints
                    Circle()
                        .fill(Color.white)
                        .frame(width: 5, height: 5)
                        .offset(x: -4, y: -4)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2.5, height: 2.5)
                        .offset(x: 3, y: 3)
                }
            }
            .offset(y: -22)
            
            // Front 2 legs rubbing greedily together!
            HStack(spacing: legRub ? -2 : 4) {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 14, height: 3.5)
                    .rotationEffect(.degrees(legRub ? 25 : 10))
                Capsule()
                    .fill(Color.black)
                    .frame(width: 14, height: 3.5)
                    .rotationEffect(.degrees(legRub ? -25 : -10))
            }
            .offset(y: -4)
        }
    }
}

// MARK: - Juicy Cartoon Watermelon Slice
struct CartoonWatermelonWedgeView: View {
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2.0
            let bottomY = size.height * 0.78
            let r: CGFloat = 85.0
            
            // Outer Green Striped Rind
            var rind = Path()
            rind.addArc(center: CGPoint(x: midX, y: bottomY - 30), radius: r, startAngle: .degrees(15), endAngle: .degrees(165), clockwise: false)
            context.stroke(rind, with: .color(Color(red: 0.14, green: 0.55, blue: 0.25)), lineWidth: 14)
            
            // Pale Green / White Inner Rind
            var paleRind = Path()
            paleRind.addArc(center: CGPoint(x: midX, y: bottomY - 30), radius: r - 5, startAngle: .degrees(18), endAngle: .degrees(162), clockwise: false)
            context.stroke(paleRind, with: .color(Color(red: 0.88, green: 0.95, blue: 0.82)), lineWidth: 6)
            
            // Juicy Red Wedge
            var wedge = Path()
            wedge.move(to: CGPoint(x: midX, y: bottomY - 30))
            wedge.addArc(center: CGPoint(x: midX, y: bottomY - 30), radius: r - 8, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
            wedge.closeSubpath()
            
            context.fill(
                wedge,
                with: .linearGradient(
                    Gradient(colors: [Color(red: 1.0, green: 0.25, blue: 0.35), Color(red: 0.85, green: 0.12, blue: 0.20)]),
                    startPoint: CGPoint(x: midX, y: bottomY - 60),
                    endPoint: CGPoint(x: midX, y: bottomY + 20)
                )
            )
            
            // Black Glossy Teardrop Seeds
            let seedPositions = [
                CGPoint(x: midX - 35, y: bottomY + 12),
                CGPoint(x: midX - 15, y: bottomY + 22),
                CGPoint(x: midX + 15, y: bottomY + 20),
                CGPoint(x: midX + 38, y: bottomY + 10),
                CGPoint(x: midX - 22, y: bottomY - 5),
                CGPoint(x: midX + 20, y: bottomY - 8)
            ]
            
            for pt in seedPositions {
                let seed = Path(ellipseIn: CGRect(x: pt.x - 3.5, y: pt.y - 5.5, width: 7, height: 11))
                context.fill(seed, with: .color(Color(red: 0.15, green: 0.08, blue: 0.05)))
                // Tiny seed gloss highlight
                let gloss = Path(ellipseIn: CGRect(x: pt.x - 1.5, y: pt.y - 4, width: 2.5, height: 4))
                context.fill(gloss, with: .color(Color.white.opacity(0.8)))
            }
        }
        .frame(width: 210, height: 100)
    }
}

// MARK: - 4. Cartoon Splat / Trapped Outcome Stage
struct CartoonTrappedFlyStage: View {
    let outcome: SwatOutcome
    @State private var starAngle: Double = 0.0
    @State private var legWiggle: Bool = false
    
    var body: some View {
        ZStack {
            // Starburst Cartoon Explosion in Background
            CartoonComicStarburst(color: .yellow)
                .frame(width: 220, height: 160)
                .scaleEffect(legWiggle ? 1.05 : 0.96)
            
            // Big Neon Bug Juice Splat
            CartoonJuiceSplatterView(color: Color(red: 0.25, green: 0.85, blue: 0.25))
                .frame(width: 170, height: 130)
            
            // Squished Pancake Fly
            ZStack {
                // Splayed twitching legs
                ForEach(0..<6) { i in
                    let angle = Double(i) * 60.0 + (legWiggle ? 15.0 : -10.0)
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 26, height: 4)
                        .offset(x: 24)
                        .rotationEffect(.degrees(angle))
                }
                
                // Squished Body
                Ellipse()
                    .fill(Color(red: 0.1, green: 0.35, blue: 0.2))
                    .frame(width: 65, height: 45)
                    .overlay(
                        Ellipse()
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                // Comic Dizziness "X_X" Eyes
                HStack(spacing: 16) {
                    Text("X")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                    Text("X")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                }
            }
            
            // Orbiting Cartoon Dizziness Stars
            ForEach(0..<4) { i in
                let ang = starAngle + Double(i) * 90.0
                let rad = ang * .pi / 180.0
                let x = cos(rad) * 48.0
                let y = sin(rad) * 32.0 - 15.0
                
                Image(systemName: "sparkle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
                    .offset(x: x, y: y)
            }
            
            // Comic Word Bubble: SQUISHED!
            Text("SPLAT! TRAPPED")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Color.yellow)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                .offset(y: 65)
        }
        .frame(width: 260, height: 170)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                legWiggle = true
            }
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                starAngle = 360.0
            }
        }
    }
}

// MARK: - 5. Cartoon Escaped / Whiff Stage
struct CartoonEscapedFlyStage: View {
    let mockingText: String
    @State private var flyOffset: CGFloat = -90.0
    @State private var laughBob: Bool = false
    
    var body: some View {
        ZStack {
            // Comic Dust Cloud Puff
            CartoonComicStarburst(color: Color(red: 0.95, green: 0.85, blue: 0.75))
                .frame(width: 190, height: 140)
            
            // Empty Watermelon with a big bite taken out!
            CartoonWatermelonWedgeView()
                .offset(y: 28)
            
            // Comic Dust Poof
            Image(systemName: "wind")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.gray.opacity(0.55))
                .offset(x: -30, y: -10)
            
            // Cartoon Fly Flying Away Mocking the Player!
            VStack(spacing: 2) {
                Text("BZZZZ! MISSED ME!")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1.5))
                
                HStack(spacing: 4) {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.35))
                        .scaleEffect(x: -1, y: 1)
                        .offset(y: laughBob ? -4 : 4)
                }
            }
            .offset(x: flyOffset, y: -30)
            
            // Mocking reason banner
            Text(mockingText)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.45, green: 0.15, blue: 0.1))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .offset(y: 68)
        }
        .frame(width: 260, height: 170)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
                laughBob = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                flyOffset = 70.0
            }
        }
    }
}

// MARK: - Comic Starburst Burst Shape
struct CartoonComicStarburst: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2.0
            let midY = size.height / 2.0
            let points = 16
            
            var path = Path()
            for i in 0..<points {
                let angle = Double(i) * (.pi * 2.0 / Double(points))
                let r: CGFloat = (i % 2 == 0) ? size.width * 0.46 : size.width * 0.28
                let x = midX + cos(angle) * r
                let y = midY + sin(angle) * r
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            
            // Drop shadow
            context.fill(path.offsetBy(dx: 0, dy: 4), with: .color(Color.black.opacity(0.2)))
            // Starburst body
            context.fill(path, with: .color(color))
            // Thick comic outline
            context.stroke(path, with: .color(Color(red: 0.3, green: 0.15, blue: 0.05)), lineWidth: 3)
        }
    }
}

// MARK: - Cartoon Juice Splatter
struct CartoonJuiceSplatterView: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2.0
            let midY = size.height / 2.0
            
            var splat = Path()
            let points = 14
            for i in 0..<points {
                let ang = Double(i) * (.pi * 2.0 / Double(points))
                let r: CGFloat = (i % 2 == 0) ? 55.0 : 26.0 + CGFloat((i * 9) % 22)
                let x = midX + cos(ang) * r
                let y = midY + sin(ang) * r
                if i == 0 { splat.move(to: CGPoint(x: x, y: y)) }
                else { splat.addLine(to: CGPoint(x: x, y: y)) }
            }
            splat.closeSubpath()
            
            context.fill(splat, with: .color(color.opacity(0.85)))
            context.stroke(splat, with: .color(Color.black.opacity(0.4)), lineWidth: 2)
            
            // Droplets around
            let drops = [
                CGPoint(x: midX - 55, y: midY - 25),
                CGPoint(x: midX + 50, y: midY - 30),
                CGPoint(x: midX - 40, y: midY + 35),
                CGPoint(x: midX + 45, y: midY + 25)
            ]
            for pt in drops {
                let d = Path(ellipseIn: CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8))
                context.fill(d, with: .color(color))
            }
        }
    }
}

// MARK: - 6. Chunky Cartoon Wooden Signboard (Call to Action)
struct CartoonWoodenSignPrompt: View {
    let isGameOver: Bool
    let isTrapped: Bool
    let currentWave: Int
    let bounce: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            // The Cartoon Wooden Sign
            HStack(spacing: 12) {
                // Cartoon Action Icon (SF Symbol)
                Image(systemName: isGameOver ? "arrow.counterclockwise.circle.fill" : (isTrapped ? "star.circle.fill" : "iphone.gen3"))
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(red: 0.35, green: 0.15, blue: 0.05))
                    .scaleEffect(bounce ? 1.15 : 0.95)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(titleText)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.35, green: 0.15, blue: 0.05), Color(red: 0.20, green: 0.08, blue: 0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text(subtitleText)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.55, green: 0.25, blue: 0.12))
                }
                
                Spacer()
                
                // Bouncing Arrow
                Image(systemName: "chevron.right.2")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(Color(red: 0.45, green: 0.20, blue: 0.08))
                    .offset(x: bounce ? 4 : -2)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // 3D Cartoon Wooden Drop Shadow
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.42, green: 0.22, blue: 0.10))
                        .offset(y: 5)
                    
                    // Golden Honey Wood Plank Face
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: signGradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(red: 0.45, green: 0.22, blue: 0.10), lineWidth: 3)
                        )
                    
                    // Shiny Specular Top Edge
                    VStack {
                        Capsule()
                            .fill(Color.white.opacity(0.45))
                            .frame(height: 3)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                        Spacer()
                    }
                }
            )
            .shadow(color: .black.opacity(0.3), radius: 8, y: 5)
            .scaleEffect(x: bounce ? 1.02 : 0.98, y: bounce ? 0.98 : 1.02)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var titleText: String {
        if isGameOver {
            return "OPEN TO RETRY!"
        } else if isTrapped {
            return "OPEN FOR WAVE \(currentWave + 1)!"
        } else {
            return "OPEN PHONE TO SQUASH!"
        }
    }
    
    private var subtitleText: String {
        if isGameOver {
            return "UNFOLD FLAT (180°) TO START NEW GAME"
        } else if isTrapped {
            return "UNFOLD FLAT TO CONTINUE PICNIC TABLE"
        } else {
            return "UNFOLD FLAT (180°) TO ENTER PICNIC TABLE"
        }
    }
    
    private var signGradientColors: [Color] {
        if isGameOver {
            return [Color(red: 1.0, green: 0.85, blue: 0.5), Color(red: 1.0, green: 0.65, blue: 0.35)]
        } else if isTrapped {
            return [Color(red: 0.9, green: 1.0, blue: 0.6), Color(red: 0.6, green: 0.9, blue: 0.4)]
        } else {
            return [Color(red: 1.0, green: 0.92, blue: 0.55), Color(red: 0.98, green: 0.74, blue: 0.28)]
        }
    }
}
