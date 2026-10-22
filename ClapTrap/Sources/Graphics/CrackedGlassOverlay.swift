import SwiftUI

/// Procedural "Too Hard!" Cracked Glass Screen Easter Egg Overlay.
/// Generates realistic sharp, jagged white/cyan translucent spiderweb fracture lines
/// radiating from the hinge outward across the screen, giving the user a 2-second
/// mini heart attack before fading out with a hilarious "Just kidding! +500 Brutality Bonus" relief banner.
public struct CrackedGlassOverlay: View {
    public let impactPoint: CGPoint
    public let onDismiss: () -> Void
    
    @State private var fractureProgress: CGFloat = 0.0
    @State private var showReliefBanner: Bool = false
    @State private var screenShakeOffset: CGFloat = 0.0
    @State private var opacity: Double = 1.0
    
    public init(impactPoint: CGPoint, onDismiss: @escaping () -> Void) {
        self.impactPoint = impactPoint
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let origin = (impactPoint.x == 0 && impactPoint.y == 0) ? CGPoint(x: size.width / 2.0, y: size.height / 2.0) : impactPoint
            
            ZStack {
                // 1. Ominous Flash & Vignette
                Color.cyan.opacity(0.12 * Double(fractureProgress))
                    .blendMode(.plusLighter)
                    .edgesIgnoringSafeArea(.all)
                
                // 2. Procedural Jagged Spiderweb Glass Fractures (Canvas)
                Canvas { context, canvasSize in
                    let rayCount = 18
                    let maxRadius = max(canvasSize.width, canvasSize.height) * 0.95
                    
                    var radialEndpoints: [CGPoint] = []
                    
                    // Radial Jagged Cracks
                    for i in 0..<rayCount {
                        let baseAngle = (Double(i) / Double(rayCount)) * 2.0 * .pi + 0.15
                        var rayPath = Path()
                        rayPath.move(to: origin)
                        
                        let segments = 7
                        var currentPt = origin
                        
                        for s in 1...segments {
                            let segDist = (CGFloat(s) / CGFloat(segments)) * maxRadius * fractureProgress
                            let jitter = sin(Double(i * 17 + s * 29)) * 0.18
                            let angle = baseAngle + jitter
                            
                            let nextPt = CGPoint(
                                x: origin.x + segDist * cos(angle),
                                y: origin.y + segDist * sin(angle)
                            )
                            rayPath.addLine(to: nextPt)
                            currentPt = nextPt
                        }
                        
                        radialEndpoints.append(currentPt)
                        
                        // Sharp white crack line
                        context.stroke(rayPath, with: .color(Color.white.opacity(0.92)), lineWidth: 1.8)
                        // Cyan refraction glow
                        context.stroke(rayPath, with: .color(Color.cyan.opacity(0.65)), lineWidth: 3.5)
                    }
                    
                    // Concentric Jagged Spiderweb Rings
                    let ringCount = 5
                    for r in 1...ringCount {
                        let ringRadius = (CGFloat(r) / CGFloat(ringCount)) * maxRadius * 0.65 * fractureProgress
                        var webRing = Path()
                        
                        for i in 0..<rayCount {
                            let baseAngle = (Double(i) / Double(rayCount)) * 2.0 * .pi + 0.15
                            let jitter = sin(Double(i * 17 + r * 23)) * 0.14
                            let angle = baseAngle + jitter
                            
                            let pt = CGPoint(
                                x: origin.x + ringRadius * cos(angle),
                                y: origin.y + ringRadius * sin(angle)
                            )
                            
                            if i == 0 {
                                webRing.move(to: pt)
                            } else {
                                webRing.addLine(to: pt)
                            }
                        }
                        webRing.closeSubpath()
                        
                        context.stroke(webRing, with: .color(Color.white.opacity(0.78)), lineWidth: 1.2)
                        context.stroke(webRing, with: .color(Color.cyan.opacity(0.40)), lineWidth: 2.2)
                    }
                    
                    // Center impact shatter pulverization core
                    var corePath = Path()
                    corePath.addEllipse(in: CGRect(x: origin.x - 22, y: origin.y - 22, width: 44, height: 44))
                    context.fill(corePath, with: .color(Color.white.opacity(0.70)))
                }
                .edgesIgnoringSafeArea(.all)
                .offset(x: screenShakeOffset)
                
                // 3. Shock Warning / "Too Hard!" Banner
                VStack(spacing: 12) {
                    if !showReliefBanner {
                        // Heart attack warning
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("CRITICAL IMPACT")
                                Image(systemName: "exclamationmark.triangle.fill")
                            }
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.red)
                            .shadow(color: .black, radius: 4)
                            
                            Text("FAST SLAM DETECTED")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Relief banner & Safety warning: Just Kidding!
                        VStack(spacing: 8) {
                            Text("JUST KIDDING!")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(.green)
                            
                            Text("YOUR SCREEN IS INTACT, BUT PLEASE FOLD GENTLY")
                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white.opacity(0.95))
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.yellow)
                                Text("SAFETY NOTICE: Fold phone gently.")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.1, green: 0.12, blue: 0.16).opacity(0.95))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(colors: [.yellow, .green, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                                )
                        )
                        .shadow(color: .cyan.opacity(0.6), radius: 15)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .position(x: size.width / 2.0, y: size.height * 0.35)
            }
            .opacity(opacity)
            .onAppear {
                triggerCrackSequence()
            }
        }
    }
    
    private func triggerCrackSequence() {
        // Instant fracture expansion
        withAnimation(.easeOut(duration: 0.08)) {
            fractureProgress = 1.0
        }
        
        // Rapid screen shake
        for s in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(s) * 0.04) {
                screenShakeOffset = (s % 2 == 0) ? -10.0 : 10.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            screenShakeOffset = 0.0
        }
        
        // 1.5 seconds of mini heart attack, then reveal joke!
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showReliefBanner = true
            }
        }
        
        // Dismiss after relief banner
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                onDismiss()
            }
        }
    }
}
