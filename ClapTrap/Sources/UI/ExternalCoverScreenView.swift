import SwiftUI

/// External Cover Screen Interface:
/// Shown exclusively when the foldable phone is closed.
/// 100% focused on game narrative and action:
/// - When clapping, immediately reveals ANIMATED whether the fly was TRAPPED or ESCAPED!
/// - If TRAPPED: Shows animated squished/trapped insect with victory stats, and prompts opening hinge to advance wave!
/// - If MISSED: Triggers GAME OVER, shows animated escaping fly, and prompts opening hinge to start a new game!
/// - If Initial: Prompts player to unfold phone flat to start the game.
/// The game NEVER runs on this cover screen under any circumstance. Zero external assets.
public struct ExternalCoverScreenView: View {
    @ObservedObject var gameEngine = ClapTrapGameEngine.shared
    
    @State private var pulse: Bool = false
    @State private var foldAnimationAngle: Double = 30.0
    
    // Idle state trapped fly animation
    @State private var idleFlyPos: CGPoint = CGPoint(x: 120, y: 50)
    @State private var idleFlyVelocity: CGPoint = CGPoint(x: 2.8, y: 2.1)
    @State private var idleFlyTimer: Timer?
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Sleek OLED Obsidian Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.07, blue: 0.11),
                        Color(red: 0.02, green: 0.02, blue: 0.04)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Dynamic Ambient Radial Glow based on outcome
                RadialGradient(
                    colors: [
                        ambientGlowColor.opacity(0.22),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: size.width * 0.95
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer().frame(height: 28)
                    
                    // 1. TOP HEADER (Outcome or Game Branding)
                    headerView
                    
                    Spacer()
                    
                    // 2. CENTRAL ANIMATED DISPLAY (Trapped, Escaped Game Over, or Idle)
                    centralAnimatedContent
                    
                    Spacer()
                    
                    // 3. STATS & REACTION BADGES
                    statsBadgesView
                    
                    // 4. ACTION CALL TO ACTION (Open hinge to advance / retry)
                    actionPromptCard
                    
                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                startIdleFlyAnimation()
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    foldAnimationAngle = 80.0
                    pulse = true
                }
            }
            .onDisappear {
                idleFlyTimer?.invalidate()
                idleFlyTimer = nil
            }
        }
    }
    
    // MARK: - Dynamic State Queries
    
    private var isTrapped: Bool {
        if let outcome = gameEngine.lastOutcome, outcome.hit {
            return true
        }
        return false
    }
    
    private var isGameOver: Bool {
        if gameEngine.gameState == .gameOver {
            return true
        }
        if let outcome = gameEngine.lastOutcome, !outcome.hit {
            return true
        }
        return false
    }
    
    private var ambientGlowColor: Color {
        if isGameOver {
            return .red
        } else if isTrapped {
            return .green
        } else {
            return .cyan
        }
    }
    
    // MARK: - 1. Header View
    
    @ViewBuilder
    private var headerView: some View {
        if isGameOver {
            VStack(spacing: 4) {
                Text("💨 MISSED! 💨")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .red.opacity(0.8), radius: 10)
                
                Text("GAME OVER")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                    .tracking(4)
            }
        } else if isTrapped {
            VStack(spacing: 4) {
                Text("🎯 TRAPPED! 🎯")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .green, .cyan], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .green.opacity(0.8), radius: 12)
                
                Text("TARGET NEUTRALIZED")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(.green)
                    .tracking(3)
            }
        } else {
            // Initial Brand Title
            VStack(spacing: 6) {
                Text("CLAPTRAP")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .yellow.opacity(0.6), radius: 10)
                
                Text("THE FOLDABLE FLY SWATTER")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.cyan)
                    .tracking(3)
            }
        }
    }
    
    // MARK: - 2. Central Animated Content
    
    @ViewBuilder
    private var centralAnimatedContent: some View {
        if isGameOver {
            // ANIMATED ESCAPED FLY (Fly zips mockingly away through empty container!)
            ProceduralEscapedFlyAnimationView(
                mockingText: gameEngine.lastOutcome?.mockingText ?? "The fly escaped your folding clap!"
            )
        } else if isTrapped, let outcome = gameEngine.lastOutcome {
            // ANIMATED TRAPPED SQUISHED FLY (Twitching legs, neon splat, orbiting stars!)
            ProceduralTrappedFlyAnimationView(outcome: outcome)
        } else {
            // IDLE VIEW: Trapped fly bumping in container + folding phone graphic
            VStack(spacing: 16) {
                ProceduralFoldablePhoneGraphic(foldAngle: foldAnimationAngle)
                    .frame(width: 170, height: 110)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.7), .yellow.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 250, height: 95)
                    
                    InsectSpriteView(
                        insect: ActiveInsect(type: .housefly, startPosition: idleFlyPos),
                        globalScale: 0.75
                    )
                    .position(idleFlyPos)
                    
                    HStack(spacing: 6) {
                        Text("🪰")
                        Text("FLY TRAPPED INSIDE PHONE")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    .offset(y: 32)
                }
                .frame(width: 250, height: 95)
            }
        }
    }
    
    // MARK: - 3. Stats & Score Badges
    
    @ViewBuilder
    private var statsBadgesView: some View {
        if isGameOver {
            VStack(spacing: 6) {
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("FINAL SCORE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(gameEngine.score)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1, height: 30)
                    
                    VStack(spacing: 2) {
                        Text("WAVES SURVIVED")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(max(0, gameEngine.currentWave - 1))")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                
                if gameEngine.score >= gameEngine.highScore && gameEngine.score > 0 {
                    Text("🏆 ALL-TIME HIGH SCORE! 🏆")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                }
            }
        } else if isTrapped, let outcome = gameEngine.lastOutcome {
            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    if outcome.reactionTimeMs > 0 {
                        Text("⚡️ \(outcome.reactionTimeMs)ms")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if outcome.isMach2 {
                        Text("🚀 MACH 2 (+500)")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Text("+\(outcome.pointsEarned) PTS")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Text("TOTAL SCORE: \(gameEngine.score)  •  WAVE \(gameEngine.currentWave) COMPLETE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow.opacity(0.9))
            }
        } else {
            // Idle stats
            if gameEngine.highScore > 0 {
                Text("🏆 HIGH SCORE: \(gameEngine.highScore) PTS")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.yellow.opacity(0.85))
            }
        }
    }
    
    // MARK: - 4. Action Prompt Card
    
    @ViewBuilder
    private var actionPromptCard: some View {
        if isGameOver {
            // GAME OVER: Open hinge to start new game!
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.yellow)
                    
                    Text("OPEN HINGE TO START NEW GAME")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                }
                
                Text("UNFOLD PHONE FLAT (180°) TO RETRY FROM WAVE 1")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(colors: [.red, .orange, .yellow], startPoint: .leading, endPoint: .trailing),
                                lineWidth: 1.6
                            )
                    )
            )
            .shadow(color: .red.opacity(pulse ? 0.7 : 0.25), radius: pulse ? 12 : 5)
            .scaleEffect(pulse ? 1.02 : 0.98)
            
        } else if isTrapped {
            // TRAPPED: Open hinge to advance to next wave!
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.and.right.circle.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.yellow)
                    
                    Text("OPEN HINGE FOR WAVE \(gameEngine.currentWave + 1)")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                }
                
                Text("UNFOLD PHONE FLAT (180°) TO UNLEASH THE FLY SWATTER")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(colors: [.green, .yellow, .cyan], startPoint: .leading, endPoint: .trailing),
                                lineWidth: 1.6
                            )
                    )
            )
            .shadow(color: .green.opacity(pulse ? 0.7 : 0.25), radius: pulse ? 12 : 5)
            .scaleEffect(pulse ? 1.02 : 0.98)
            
        } else {
            // INITIAL IDLE: Open hinge to start game
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.and.right.circle.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.yellow)
                    
                    Text("OPEN HINGE TO START GAME")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                }
                
                Text("UNFOLD PHONE FLAT (180°) TO ENTER PICNIC TABLE & PLAY")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(colors: [.yellow, .orange, .cyan], startPoint: .leading, endPoint: .trailing),
                                lineWidth: 1.6
                            )
                    )
            )
            .shadow(color: .yellow.opacity(pulse ? 0.65 : 0.2), radius: pulse ? 12 : 4)
            .scaleEffect(pulse ? 1.02 : 0.98)
        }
    }
    
    // MARK: - Idle Trapped Fly Animation
    
    private func startIdleFlyAnimation() {
        idleFlyTimer?.invalidate()
        idleFlyTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            var x = idleFlyPos.x + idleFlyVelocity.x
            var y = idleFlyPos.y + idleFlyVelocity.y
            var vx = idleFlyVelocity.x
            var vy = idleFlyVelocity.y
            
            let minX: CGFloat = 25
            let maxX: CGFloat = 225
            let minY: CGFloat = 18
            let maxY: CGFloat = 74
            
            if x <= minX || x >= maxX {
                vx = -vx + CGFloat.random(in: -0.4...0.4)
                x = max(minX, min(maxX, x))
            }
            if y <= minY || y >= maxY {
                vy = -vy + CGFloat.random(in: -0.4...0.4)
                y = max(minY, min(maxY, y))
            }
            
            idleFlyPos = CGPoint(x: x, y: y)
            idleFlyVelocity = CGPoint(x: vx, y: vy)
        }
    }
}

// MARK: - Procedural Trapped Fly Animation (Victory Screen)
struct ProceduralTrappedFlyAnimationView: View {
    let outcome: SwatOutcome
    
    @State private var legTwitch: Bool = false
    @State private var starAngle: Double = 0.0
    @State private var shockwaveScale: CGFloat = 0.8
    @State private var shockwaveOpacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // Glowing Containment Pod Glass Box
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.07, green: 0.12, blue: 0.09).opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(colors: [.green, .yellow, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )
                .frame(width: 260, height: 160)
            
            // Shockwave Pulse Ring
            Circle()
                .stroke(Color.green.opacity(shockwaveOpacity), lineWidth: 2)
                .frame(width: 110, height: 110)
                .scaleEffect(shockwaveScale)
            
            // Procedural Bug Juice Splatter Behind Insect
            ProceduralBugJuiceSplat(color: .green)
                .frame(width: 130, height: 100)
            
            // Squished Twitching Insect
            ZStack {
                // Comical twitching legs
                ForEach(0..<6) { idx in
                    let angle = Double(idx) * 60.0 + (legTwitch ? 12.0 : -8.0)
                    Rectangle()
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                        .frame(width: 22, height: 2.2)
                        .offset(x: 18)
                        .rotationEffect(.degrees(angle))
                }
                
                // Squished Body Ellipse
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.15, green: 0.35, blue: 0.25), Color(red: 0.05, green: 0.08, blue: 0.1)],
                            center: .center,
                            startRadius: 4,
                            endRadius: 28
                        )
                    )
                    .frame(width: 48, height: 34)
                    .scaleEffect(x: legTwitch ? 1.08 : 0.94, y: legTwitch ? 0.94 : 1.06)
                
                // Translucent Flattened Wings
                HStack(spacing: -6) {
                    Ellipse()
                        .fill(Color.cyan.opacity(0.55))
                        .frame(width: 32, height: 16)
                        .rotationEffect(.degrees(-35))
                    Ellipse()
                        .fill(Color.cyan.opacity(0.55))
                        .frame(width: 32, height: 16)
                        .rotationEffect(.degrees(35))
                }
                
                // Stunned "X" Eyes
                HStack(spacing: 12) {
                    Text("✖")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.red)
                    Text("✖")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.red)
                }
            }
            
            // Orbiting Cartoon Dizziness Stars
            ForEach(0..<3) { idx in
                let offsetAngle = starAngle + Double(idx) * 120.0
                let rad = offsetAngle * .pi / 180.0
                let starX = cos(rad) * 38.0
                let starY = sin(rad) * 24.0 - 15.0
                
                Text("⭐️")
                    .font(.system(size: 12))
                    .offset(x: starX, y: starY)
            }
            
            // Status Tag
            Text("🪰 TRAPPED IN CLOSED SCREEN")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundColor(.green)
                .offset(y: 64)
        }
        .frame(width: 260, height: 160)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.18).repeatForever(autoreverses: true)) {
                legTwitch = true
            }
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                starAngle = 360.0
            }
            withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                shockwaveScale = 1.4
                shockwaveOpacity = 0.0
            }
        }
    }
}

// MARK: - Procedural Escaped Fly Animation (Game Over Screen)
struct ProceduralEscapedFlyAnimationView: View {
    let mockingText: String
    
    @State private var flyX: CGFloat = -110.0
    @State private var flyY: CGFloat = 10.0
    @State private var wingFlap: Bool = false
    @State private var puffOpacity: Double = 0.8
    @State private var puffScale: CGFloat = 0.6
    
    var body: some View {
        ZStack {
            // Cracked / Empty Chamber Glass Box
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.14, green: 0.05, blue: 0.05).opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )
                .frame(width: 260, height: 160)
            
            // Empty Swat Target Ring
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                .foregroundColor(.red.opacity(0.5))
                .frame(width: 80, height: 80)
            
            // Cartoon Puff of Smoke where fly was supposed to be
            ZStack {
                Text("💨")
                    .font(.system(size: 34))
                    .opacity(puffOpacity)
                    .scaleEffect(puffScale)
            }
            
            // Animated Escaping Fly Zipping Mockingly Across Chamber
            ZStack {
                // Fly Wings fluttering at 60Hz
                HStack(spacing: -4) {
                    Ellipse()
                        .fill(Color.white.opacity(wingFlap ? 0.7 : 0.3))
                        .frame(width: 20, height: 10)
                        .rotationEffect(.degrees(wingFlap ? -45 : -15))
                    Ellipse()
                        .fill(Color.white.opacity(wingFlap ? 0.7 : 0.3))
                        .frame(width: 20, height: 10)
                        .rotationEffect(.degrees(wingFlap ? 45 : 15))
                }
                
                // Fly Body
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 22, height: 14)
                
                // Red Compound Eyes
                Circle()
                    .fill(Color.red)
                    .frame(width: 5, height: 5)
                    .offset(x: 8, y: -2)
            }
            .offset(x: flyX, y: flyY)
            
            // Comic Mocking Speech Bubble
            Text("😜 BZZZ! MISSED ME!")
                .font(.system(size: 8, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow)
                .cornerRadius(6)
                .offset(x: flyX > 20 ? 40 : -40, y: flyY - 26)
            
            // Mocking Reason Footer
            Text(mockingText.uppercased())
                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .offset(y: 64)
        }
        .frame(width: 260, height: 160)
        .onAppear {
            // Rapid wing flutter
            withAnimation(.easeInOut(duration: 0.08).repeatForever(autoreverses: true)) {
                wingFlap = true
            }
            // Puff of smoke expands and fades
            withAnimation(.easeOut(duration: 0.9).repeatForever(autoreverses: false)) {
                puffScale = 1.3
                puffOpacity = 0.0
            }
            // Fly loops back and forth zipping across
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                flyX = 100.0
                flyY = -25.0
            }
        }
    }
}

// MARK: - Procedural Bug Juice Splatter Shape
struct ProceduralBugJuiceSplat: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2.0
            let midY = size.height / 2.0
            
            var splatPath = Path()
            let points = 12
            for i in 0..<points {
                let angle = Double(i) * (.pi * 2.0 / Double(points))
                let radius = (i % 2 == 0) ? 36.0 : 20.0 + Double((i * 7) % 15)
                let x = midX + CGFloat(cos(angle) * radius)
                let y = midY + CGFloat(sin(angle) * radius)
                
                if i == 0 {
                    splatPath.move(to: CGPoint(x: x, y: y))
                } else {
                    splatPath.addLine(to: CGPoint(x: x, y: y))
                }
            }
            splatPath.closeSubpath()
            
            // Main Splat body
            context.fill(splatPath, with: .color(color.opacity(0.65)))
            
            // Random splatter droplets around
            let droplets = [
                CGPoint(x: midX - 42, y: midY - 22),
                CGPoint(x: midX + 38, y: midY - 28),
                CGPoint(x: midX - 35, y: midY + 28),
                CGPoint(x: midX + 44, y: midY + 18),
                CGPoint(x: midX - 15, y: midY - 38),
                CGPoint(x: midX + 22, y: midY + 36)
            ]
            for pt in droplets {
                let drop = Path(ellipseIn: CGRect(x: pt.x - 3, y: pt.y - 3, width: 6, height: 6))
                context.fill(drop, with: .color(color.opacity(0.8)))
            }
        }
    }
}

// MARK: - Procedural Graphic of an unfolding dual-screen foldable smartphone
struct ProceduralFoldablePhoneGraphic: View {
    let foldAngle: Double // degrees
    
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2.0
            let midY = size.height / 2.0
            let halfW: CGFloat = 55
            let phoneH: CGFloat = 85
            
            // Left Half Phone Screen
            var leftHalf = Path()
            leftHalf.addRoundedRect(
                in: CGRect(x: midX - halfW, y: midY - phoneH / 2, width: halfW, height: phoneH),
                cornerSize: CGSize(width: 6, height: 6)
            )
            context.fill(leftHalf, with: .color(Color(red: 0.15, green: 0.18, blue: 0.22)))
            context.stroke(leftHalf, with: .color(Color.cyan.opacity(0.8)), lineWidth: 2)
            
            // Right Half Phone Screen (Rotates around center seam based on foldAngle)
            let foldRad = foldAngle * .pi / 180.0
            let projW = halfW * cos(foldRad)
            
            var rightHalf = Path()
            rightHalf.addRoundedRect(
                in: CGRect(x: midX, y: midY - phoneH / 2, width: max(8, projW), height: phoneH),
                cornerSize: CGSize(width: 6, height: 6)
            )
            context.fill(rightHalf, with: .color(Color(red: 0.20, green: 0.24, blue: 0.30)))
            context.stroke(rightHalf, with: .color(Color.yellow.opacity(0.9)), lineWidth: 2)
            
            // Glowing Hinge Crease
            var hingeLine = Path()
            hingeLine.move(to: CGPoint(x: midX, y: midY - phoneH / 2))
            hingeLine.addLine(to: CGPoint(x: midX, y: midY + phoneH / 2))
            context.stroke(hingeLine, with: .color(Color.white), lineWidth: 3)
            
            // Glow aura
            context.stroke(hingeLine, with: .color(Color.yellow.opacity(0.55)), lineWidth: 7)
        }
    }
}
