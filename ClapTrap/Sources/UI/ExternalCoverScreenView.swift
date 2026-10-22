import SwiftUI

/// External Cover Screen Interface:
/// Shown exclusively when the foldable phone is closed.
/// 100% focused on game immersion:
/// - Prompts player to unfold phone flat (180°) to enter the dual-screen picnic table.
/// - The game NEVER runs on this cover screen.
/// - Features an animated trapped fly bumping frantically against the glass.
/// - Features a procedural unfolding phone animation.
/// - Zero buttons to bypass physical unfolding.
public struct ExternalCoverScreenView: View {
    @State private var trappedFlyPos: CGPoint = CGPoint(x: 120, y: 50)
    @State private var trappedFlyVelocity: CGPoint = CGPoint(x: 2.6, y: 2.1)
    @State private var foldAnimationAngle: Double = 30.0
    @State private var pulse: Bool = false
    @State private var trappedFlyTimer: Timer?
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Sleek OLED Obsidian Background
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.08, blue: 0.12),
                        Color(red: 0.02, green: 0.03, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Ambient Radial Glow
                RadialGradient(
                    colors: [
                        Color.cyan.opacity(0.18),
                        Color.yellow.opacity(0.06),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 30,
                    endRadius: size.width * 0.95
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    Spacer().frame(height: 36)
                    
                    // Game Title & Arcade Branding
                    VStack(spacing: 8) {
                        Text("CLAPTRAP")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange, .red],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .yellow.opacity(0.6), radius: 12)
                        
                        Text("THE FOLDABLE FLY SWATTER")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.cyan)
                            .tracking(3)
                    }
                    
                    Spacer()
                    
                    // Central Trapped Fly Container (bumping frantically behind closed glass)
                    VStack(spacing: 16) {
                        // Procedural animated unfolding phone graphic
                        ProceduralFoldablePhoneGraphic(foldAngle: foldAnimationAngle)
                            .frame(width: 170, height: 120)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.cyan.opacity(0.7), .yellow.opacity(0.4), .white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .frame(width: 250, height: 95)
                            
                            // Animated Trapped Insect bumping inside viewport
                            InsectSpriteView(
                                insect: ActiveInsect(type: .housefly, startPosition: trappedFlyPos),
                                globalScale: 0.75
                            )
                            .position(trappedFlyPos)
                            
                            // Trapped Fly Status Label
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
                    
                    Spacer()
                    
                    // Call to Action: Open Hinge to Unleash the Game!
                    VStack(spacing: 12) {
                        // Pulsing Unfold Card
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.left.and.right.circle.fill")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.yellow)
                                
                                Text("OPEN HINGE TO START GAME")
                                    .font(.system(size: 15, weight: .black, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                            
                            Text("UNFOLD PHONE FLAT (180°) TO ENTER PICNIC TABLE & UNLEASH FLY SWATTER")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.yellow, .orange, .cyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1.6
                                        )
                                )
                        )
                        .shadow(color: .yellow.opacity(pulse ? 0.65 : 0.2), radius: pulse ? 14 : 5)
                        .scaleEffect(pulse ? 1.03 : 0.98)
                        .padding(.horizontal, 24)
                        
                        // All-time best record
                        if ClapTrapGameEngine.shared.highScore > 0 {
                            Text("🏆 HIGH SCORE: \(ClapTrapGameEngine.shared.highScore) PTS")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow.opacity(0.8))
                                .padding(.top, 4)
                        }
                    }
                    
                    Spacer().frame(height: 38)
                }
            }
            .onAppear {
                startTrappedFlyAnimation(bounds: CGSize(width: 250, height: 95))
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    foldAnimationAngle = 80.0
                    pulse = true
                }
            }
            .onDisappear {
                trappedFlyTimer?.invalidate()
                trappedFlyTimer = nil
            }
        }
    }
    
    private func startTrappedFlyAnimation(bounds: CGSize) {
        trappedFlyTimer?.invalidate()
        trappedFlyTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            var x = trappedFlyPos.x + trappedFlyVelocity.x
            var y = trappedFlyPos.y + trappedFlyVelocity.y
            var vx = trappedFlyVelocity.x
            var vy = trappedFlyVelocity.y
            
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
            
            trappedFlyPos = CGPoint(x: x, y: y)
            trappedFlyVelocity = CGPoint(x: vx, y: vy)
        }
    }
}

/// Procedural Graphic of an unfolding dual-screen foldable smartphone
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
