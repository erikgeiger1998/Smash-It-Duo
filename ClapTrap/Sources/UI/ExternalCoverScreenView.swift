import SwiftUI

/// External Cover Screen Interface:
/// Shown when the foldable phone is closed.
/// 100% focused on game narrative and action:
/// Features the trapped buzzing fly behind the glass and prompts
/// the player to open the hinge to unleash the fly swatter.
public struct ExternalCoverScreenView: View {
    public let onOpenHinge: () -> Void
    
    @State private var trappedFlyPos: CGPoint = CGPoint(x: 140, y: 180)
    @State private var trappedFlyVelocity: CGPoint = CGPoint(x: 2.8, y: 2.2)
    @State private var foldAnimationAngle: Double = 25.0
    @State private var pulse: Bool = false
    
    public init(onOpenHinge: @escaping () -> Void) {
        self.onOpenHinge = onOpenHinge
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Sleek Dark OLED Cover Screen Background
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.09, blue: 0.13),
                        Color(red: 0.02, green: 0.03, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Subtle Ambient Glow
                RadialGradient(
                    colors: [
                        Color.cyan.opacity(0.14),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: size.width * 0.85
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer().frame(height: 30)
                    
                    // Game Title & Tagline
                    VStack(spacing: 6) {
                        Text("CLAPTRAP")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                        
                        Text("THE FOLDABLE FLY SWATTER")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.cyan)
                            .tracking(3)
                    }
                    
                    Spacer()
                    
                    // Central Trapped Fly Container (bumping frantically behind the closed glass!)
                    VStack(spacing: 14) {
                        ProceduralFoldablePhoneGraphic(foldAngle: foldAnimationAngle)
                            .frame(width: 160, height: 110)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(colors: [.cyan.opacity(0.6), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                                )
                                .frame(width: 240, height: 90)
                            
                            // Animated Trapped Fly
                            InsectSpriteView(
                                insect: ActiveInsect(type: .housefly, startPosition: trappedFlyPos),
                                globalScale: 0.75
                            )
                            .position(trappedFlyPos)
                            
                            Text("🪰 FLY TRAPPED INSIDE PHONE")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                                .offset(y: 30)
                        }
                        .frame(width: 240, height: 90)
                    }
                    
                    Spacer()
                    
                    // Main Call to Action: OPEN HINGE TO START GAME!
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left.and.right.circle.fill")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.yellow)
                            
                            Text("OPEN HINGE TO START GAME")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                        .scaleEffect(pulse ? 1.05 : 0.96)
                        
                        Text("UNFOLD PHONE FLAT (180°) TO REVEAL THE PICNIC TABLE & UNLEASH THE FLY SWATTER!")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                        
                        // Interactive Unfold Button
                        Button(action: onOpenHinge) {
                            HStack(spacing: 8) {
                                Image(systemName: "iphone.gen3")
                                Text("OPEN HINGE FLAT TO PLAY")
                                Image(systemName: "arrow.up.right.and.arrow.down.left.rectangle.fill")
                            }
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: .yellow.opacity(0.7), radius: 10)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 6)
                    }
                    
                    Spacer().frame(height: 40)
                }
            }
            .onAppear {
                startTrappedFlyAnimation(bounds: CGSize(width: 240, height: 90))
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    foldAnimationAngle = 80.0
                    pulse = true
                }
            }
        }
    }
    
    private func startTrappedFlyAnimation(bounds: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { timer in
            var x = trappedFlyPos.x + trappedFlyVelocity.x
            var y = trappedFlyPos.y + trappedFlyVelocity.y
            var vx = trappedFlyVelocity.x
            var vy = trappedFlyVelocity.y
            
            let minX: CGFloat = 25
            let maxX: CGFloat = 215
            let minY: CGFloat = 18
            let maxY: CGFloat = 72
            
            if x <= minX || x >= maxX {
                vx = -vx + CGFloat.random(in: -0.5...0.5)
                x = max(minX, min(maxX, x))
            }
            if y <= minY || y >= maxY {
                vy = -vy + CGFloat.random(in: -0.5...0.5)
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
            leftHalf.addRoundedRect(in: CGRect(x: midX - halfW, y: midY - phoneH / 2, width: halfW, height: phoneH), cornerSize: CGSize(width: 6, height: 6))
            context.fill(leftHalf, with: .color(Color(red: 0.15, green: 0.18, blue: 0.22)))
            context.stroke(leftHalf, with: .color(Color.cyan.opacity(0.8)), lineWidth: 2)
            
            // Right Half Phone Screen (Rotates around center seam based on foldAngle!)
            let foldRad = foldAngle * .pi / 180.0
            let projW = halfW * cos(foldRad)
            
            var rightHalf = Path()
            rightHalf.addRoundedRect(in: CGRect(x: midX, y: midY - phoneH / 2, width: max(8, projW), height: phoneH), cornerSize: CGSize(width: 6, height: 6))
            context.fill(rightHalf, with: .color(Color(red: 0.20, green: 0.24, blue: 0.30)))
            context.stroke(rightHalf, with: .color(Color.yellow.opacity(0.9)), lineWidth: 2)
            
            // Glowing Hinge Crease
            var hingeLine = Path()
            hingeLine.move(to: CGPoint(x: midX, y: midY - phoneH / 2))
            hingeLine.addLine(to: CGPoint(x: midX, y: midY + phoneH / 2))
            context.stroke(hingeLine, with: .color(Color.white), lineWidth: 3)
            
            // Glow aura
            context.stroke(hingeLine, with: .color(Color.yellow.opacity(0.5)), lineWidth: 7)
        }
    }
}
