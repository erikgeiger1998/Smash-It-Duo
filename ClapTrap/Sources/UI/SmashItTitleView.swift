import SwiftUI

/// Cool, playful, and animated title component for Smash it!
/// Features 3D cartoon pop typography with individual bouncing letter physics,
/// a rotating comic action starburst, floating sparkle particles, a squashing exclamation mark,
/// and an interactive cartoon smash rebound on tap with tactile feedback.
public struct SmashItTitleView: View {
    let onSmashTapped: (() -> Void)?
    
    // Continuous idle animation states
    @State private var wavePhase: Double = 0.0
    @State private var starburstRotation: Double = 0.0
    @State private var exclamationWiggle: Bool = false
    @State private var particleDrift: Bool = false
    
    // Interactive smash impact animation states
    @State private var isSmashed: Bool = false
    @State private var shockwaveScale: CGFloat = 0.2
    @State private var shockwaveOpacity: Double = 0.0
    @State private var sparkleBurst: Bool = false
    
    public init(onSmashTapped: (() -> Void)? = nil) {
        self.onSmashTapped = onSmashTapped
    }
    
    // Letter definitions with playful tilt angles and color palettes
    private struct TitleChar: Identifiable {
        let id: Int
        let char: String
        let baseTilt: Double
        let isItWord: Bool
        let isExclamation: Bool
    }
    
    private let titleCharacters: [TitleChar] = [
        TitleChar(id: 0, char: "S", baseTilt: -6.0, isItWord: false, isExclamation: false),
        TitleChar(id: 1, char: "M", baseTilt: -3.0, isItWord: false, isExclamation: false),
        TitleChar(id: 2, char: "A", baseTilt: 0.0, isItWord: false, isExclamation: false),
        TitleChar(id: 3, char: "S", baseTilt: 3.0, isItWord: false, isExclamation: false),
        TitleChar(id: 4, char: "H", baseTilt: 6.0, isItWord: false, isExclamation: false),
        TitleChar(id: 5, char: " ", baseTilt: 0.0, isItWord: false, isExclamation: false),
        TitleChar(id: 6, char: "i", baseTilt: -4.0, isItWord: true, isExclamation: false),
        TitleChar(id: 7, char: "t", baseTilt: 4.0, isItWord: true, isExclamation: false),
        TitleChar(id: 8, char: "!", baseTilt: 8.0, isItWord: true, isExclamation: true)
    ]
    
    public var body: some View {
        ZStack {
            // 1. ROTATING CARTOON COMIC STARBURST (Behind the Title)
            CartoonTitleStarburst()
                .frame(width: 320, height: 190)
                .rotationEffect(.degrees(starburstRotation))
                .opacity(0.85)
                .scaleEffect(isSmashed ? 1.25 : 1.0)
            
            // 2. EXPANDING SHOCKWAVE RING (Triggered on Tap / Smash)
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.yellow, .orange, .pink, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 6
                )
                .frame(width: 220, height: 220)
                .scaleEffect(shockwaveScale)
                .opacity(shockwaveOpacity)
            
            // 3. FLOATING PLAYFUL CARTOON PARTICLES (Sparks & Stars)
            floatingParticlesLayer
            
            // 4. MAIN 3D CARTOON TITLE TEXT WITH WAVE BOUNCE
            VStack(spacing: 8) {
                HStack(spacing: 3) {
                    ForEach(titleCharacters) { item in
                        if item.char == " " {
                            Spacer().frame(width: 12)
                        } else {
                            animatedLetter(item: item)
                        }
                    }
                }
                .contentShape(Rectangle())
                .scaleEffect(
                    x: isSmashed ? 1.22 : 1.0,
                    y: isSmashed ? 0.78 : 1.0
                )
                .offset(y: isSmashed ? 12.0 : 0.0)
                .onTapGesture {
                    triggerSmashInteraction()
                }
                
                // 5. PLAYFUL SUBTITLE RIBBON & EXCLUSIVITY BADGE
                VStack(spacing: 6) {
                    // Wooden / Arcade Ribbon: "THE FOLDABLE FLY SWATTER"
                    HStack(spacing: 6) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.yellow)
                        
                        Text("THE FOLDABLE FLY SWATTER")
                            .font(.system(size: 11.5, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1.5)
                        
                        Image(systemName: "sparkle")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.35, green: 0.18, blue: 0.10))
                                .offset(y: 3)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.55, green: 0.28, blue: 0.14), Color(red: 0.38, green: 0.18, blue: 0.08)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.85), lineWidth: 1.5)
                                )
                        }
                    )
                    .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    
                    // Exclusivity Badge
                    HStack(spacing: 5) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.cyan)
                        Text("EXCLUSIVE TO iPHONE DUO")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(.cyan)
                            .tracking(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.cyan.opacity(0.18))
                            .overlay(Capsule().stroke(Color.cyan.opacity(0.55), lineWidth: 1))
                    )
                }
            }
        }
        .onAppear {
            startIdleAnimations()
        }
    }
    
    // MARK: - Animated Individual Letter
    
    @ViewBuilder
    private func animatedLetter(item: TitleChar) -> some View {
        let waveOffset = sin(wavePhase + Double(item.id) * 0.55) * 6.0
        let tiltOffset = cos(wavePhase + Double(item.id) * 0.45) * 3.0
        
        let letterGradient = item.isItWord
            ? LinearGradient(
                colors: [Color(red: 0.25, green: 0.98, blue: 0.85), Color(red: 0.10, green: 0.70, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
              )
            : LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.25), Color(red: 1.0, green: 0.55, blue: 0.10), Color(red: 1.0, green: 0.20, blue: 0.25)],
                startPoint: .top,
                endPoint: .bottom
              )
        
        let shadowColor = item.isItWord
            ? Color(red: 0.05, green: 0.28, blue: 0.45)
            : Color(red: 0.45, green: 0.12, blue: 0.05)
        
        ZStack {
            // 3D Cartoon Extrusion Shadow Layer 3 (Deepest)
            Text(item.char)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(shadowColor)
                .offset(y: 6)
            
            // 3D Cartoon Extrusion Shadow Layer 2 (Mid)
            Text(item.char)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(shadowColor.opacity(0.8))
                .offset(y: 3)
            
            // Comic Black Outline (Stroke effect)
            Text(item.char)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .offset(x: 1, y: 1)
            
            // Main Vibrant Face
            Text(item.char)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(letterGradient)
                .overlay(
                    // Glossy Specular Top Highlight
                    Text(item.char)
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.85), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .mask(
                            Text(item.char)
                                .font(.system(size: 52, weight: .black, design: .rounded))
                        )
                )
        }
        .offset(y: waveOffset)
        .rotationEffect(.degrees(item.baseTilt + tiltOffset))
        .scaleEffect(item.isExclamation && exclamationWiggle ? 1.25 : 1.0)
    }
    
    // MARK: - Floating Cartoon Sparks & Particles
    
    private var floatingParticlesLayer: some View {
        ZStack {
            // Left sparkle
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.yellow)
                .offset(x: -125, y: particleDrift ? -38 : -22)
                .rotationEffect(.degrees(particleDrift ? 45 : 0))
                .scaleEffect(particleDrift ? 1.2 : 0.8)
                .shadow(color: .yellow.opacity(0.8), radius: 6)
            
            // Right bolt zap
            Image(systemName: "bolt.fill")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.cyan)
                .offset(x: 130, y: particleDrift ? -32 : -46)
                .rotationEffect(.degrees(particleDrift ? -25 : -10))
                .scaleEffect(particleDrift ? 0.9 : 1.3)
                .shadow(color: .cyan.opacity(0.8), radius: 6)
            
            // Top mini star
            Image(systemName: "sparkle")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.yellow)
                .offset(x: 45, y: particleDrift ? -58 : -48)
                .scaleEffect(particleDrift ? 1.3 : 0.7)
            
            // Bottom mini star
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.orange)
                .offset(x: -80, y: particleDrift ? 40 : 32)
                .scaleEffect(particleDrift ? 0.8 : 1.1)
        }
    }
    
    // MARK: - Animation Loops
    
    private func startIdleAnimations() {
        // Continuous smooth sine wave bobbing
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            wavePhase = .pi * 2.0
        }
        
        // Gentle rotation of the cartoon starburst
        withAnimation(.linear(duration: 24.0).repeatForever(autoreverses: false)) {
            starburstRotation = 360.0
        }
        
        // Wiggling exclamation mark
        withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) {
            exclamationWiggle = true
        }
        
        // Floating particles drift
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            particleDrift = true
        }
    }
    
    // MARK: - Interactive Smash
    
    private func triggerSmashInteraction() {
        ProceduralSoundEngine.shared.triggerInsectLandingHaptic()
        onSmashTapped?()
        
        // Squash down immediately
        withAnimation(.spring(response: 0.15, dampingFraction: 0.4, blendDuration: 0.1)) {
            isSmashed = true
            shockwaveScale = 0.2
            shockwaveOpacity = 0.9
        }
        
        // Shockwave expansion
        withAnimation(.easeOut(duration: 0.55)) {
            shockwaveScale = 1.6
            shockwaveOpacity = 0.0
        }
        
        // Rebound bounce back to resting state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55, blendDuration: 0.2)) {
                isSmashed = false
            }
        }
    }
}

// MARK: - Cartoon Title Starburst Shape
struct CartoonTitleStarburst: View {
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2.0
            let midY = size.height / 2.0
            let points = 24
            
            let maxRx = size.width * 0.48
            let maxRy = size.height * 0.48
            
            var path = Path()
            for i in 0..<points {
                let angle = Double(i) * (.pi * 2.0 / Double(points))
                let isOuter = (i % 2 == 0)
                let rx = isOuter ? maxRx : (maxRx * 0.65)
                let ry = isOuter ? maxRy : (maxRy * 0.65)
                let x = midX + cos(angle) * rx
                let y = midY + sin(angle) * ry
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            
            // Warm cartoon gradient fill
            context.fill(
                path,
                with: .radialGradient(
                    Gradient(colors: [Color.yellow.opacity(0.35), Color.orange.opacity(0.18), Color.clear]),
                    center: CGPoint(x: midX, y: midY),
                    startRadius: 20,
                    endRadius: maxRx
                )
            )
            
            // Soft comic outline
            context.stroke(
                path,
                with: .color(Color.yellow.opacity(0.4)),
                lineWidth: 1.5
            )
        }
    }
}
