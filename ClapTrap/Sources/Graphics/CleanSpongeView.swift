import SwiftUI

/// Procedural Yellow/Green Kitchen Sponge with Scrubby Texture
/// Used to wipe persistent bug splats off the table and dual screen.
public struct CleanSpongeButton: View {
    public let splatCount: Int
    public let action: () -> Void
    
    @State private var isPressing: Bool = false
    
    public init(splatCount: Int, action: @escaping () -> Void) {
        self.splatCount = splatCount
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 8) {
                // Procedural Sponge Icon
                Canvas { context, size in
                    let w = size.width
                    let h = size.height
                    
                    // Drop shadow
                    context.fill(Path(roundedRect: CGRect(x: 2, y: 3, width: w - 4, height: h - 4), cornerRadius: 5), with: .color(Color.black.opacity(0.3)))
                    
                    // Yellow Cellulose Sponge Body
                    let bodyRect = CGRect(x: 2, y: 6, width: w - 4, height: h - 8)
                    context.fill(Path(roundedRect: bodyRect, cornerRadius: 4), with: .color(Color(red: 0.98, green: 0.85, blue: 0.20)))
                    
                    // Sponge pores
                    let porePositions: [CGPoint] = [
                        CGPoint(x: 8, y: 12), CGPoint(x: 18, y: 15), CGPoint(x: 12, y: 20),
                        CGPoint(x: 24, y: 10), CGPoint(x: 22, y: 22)
                    ]
                    for p in porePositions {
                        context.fill(Path(ellipseIn: CGRect(x: p.x, y: p.y, width: 3, height: 2.5)), with: .color(Color(red: 0.85, green: 0.70, blue: 0.12)))
                    }
                    
                    // Top Green Scrubby Scouring Pad Layer
                    let scrubRect = CGRect(x: 2, y: 2, width: w - 4, height: 6)
                    context.fill(Path(roundedRect: scrubRect, cornerRadius: 2), with: .color(Color(red: 0.12, green: 0.55, blue: 0.25)))
                }
                .frame(width: 32, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("WIPE SCREEN")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("\(splatCount) splat\(splatCount == 1 ? "" : "s")")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(splatCount > 0 ? .yellow : .white.opacity(0.6))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.15, green: 0.18, blue: 0.22).opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(splatCount > 0 ? Color.yellow.opacity(0.8) : Color.white.opacity(0.25), lineWidth: 1.2)
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isPressing ? 0.92 : 1.0)
    }
}

/// Animated Sponge Wipe Overlay that slides across the screen with soap bubbles when triggered
public struct SpongeWipeAnimationOverlay: View {
    public let onComplete: () -> Void
    @State private var spongePosition: CGFloat = -100
    @State private var bubbleOpacity: Double = 1.0
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            
            ZStack {
                // Soap suds & bubble trail
                Canvas { context, size in
                    let bubbleCount = 28
                    for b in 0..<bubbleCount {
                        let bx = (spongePosition - 80) + CGFloat(b * 12)
                        let by = CGFloat((b * 47) % Int(size.height))
                        let br = CGFloat(6 + (b * 7) % 14)
                        
                        // Soap bubble
                        var bubblePath = Path()
                        bubblePath.addEllipse(in: CGRect(x: bx - br, y: by - br, width: br * 2, height: br * 2))
                        
                        let bubbleGrad = Gradient(colors: [
                            Color.white.opacity(0.7),
                            Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.4),
                            Color(red: 1.0, green: 0.85, blue: 0.95).opacity(0.2)
                        ])
                        context.fill(bubblePath, with: .radialGradient(bubbleGrad, center: CGPoint(x: bx - br * 0.3, y: by - br * 0.3), startRadius: 1, endRadius: br))
                        context.stroke(bubblePath, with: .color(Color.white.opacity(0.8)), lineWidth: 1.0)
                    }
                }
                .opacity(bubbleOpacity)
                
                // Giant Yellow Sponge sliding across
                VStack(spacing: 0) {
                    // Green scour layer
                    Rectangle()
                        .fill(Color(red: 0.12, green: 0.60, blue: 0.25))
                        .frame(width: 80, height: 18)
                        .cornerRadius(6)
                    // Yellow sponge body
                    Rectangle()
                        .fill(Color(red: 0.98, green: 0.85, blue: 0.20))
                        .frame(width: 80, height: 50)
                        .cornerRadius(6)
                }
                .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                .position(x: spongePosition, y: h * 0.5)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.65)) {
                    spongePosition = w + 120
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        bubbleOpacity = 0.0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
                    onComplete()
                }
            }
        }
        .allowsHitTesting(false)
    }
}
