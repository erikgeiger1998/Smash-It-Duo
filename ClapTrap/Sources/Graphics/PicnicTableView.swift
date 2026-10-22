import SwiftUI

/// Top-down procedural sunny wooden picnic table with rich wood-grain texture,
/// plank grooves, central hinge fold crease shadow, and checkered picnic cloth accents.
public struct PicnicTableView: View {
    public var hingeAngle: Double = 180.0
    
    public init(hingeAngle: Double = 180.0) {
        self.hingeAngle = hingeAngle
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let midX = size.width / 2.0
            
            ZStack {
                // 1. Procedural Wood Grain Planks (Canvas)
                Canvas { context, canvasSize in
                    let plankCount = 6
                    let plankHeight = canvasSize.height / CGFloat(plankCount)
                    
                    // Wood color palette (Oak, Walnut, Amber)
                    let plankBaseColors: [Color] = [
                        Color(red: 0.58, green: 0.35, blue: 0.18), // Warm Oak
                        Color(red: 0.52, green: 0.30, blue: 0.14), // Medium Walnut
                        Color(red: 0.62, green: 0.38, blue: 0.20), // Honey Oak
                        Color(red: 0.48, green: 0.27, blue: 0.12), // Deep Walnut
                        Color(red: 0.56, green: 0.33, blue: 0.16), // Golden Oak
                        Color(red: 0.50, green: 0.28, blue: 0.13)  // Rich Teak
                    ]
                    
                    for i in 0..<plankCount {
                        let y = CGFloat(i) * plankHeight
                        let plankRect = CGRect(x: 0, y: y, width: canvasSize.width, height: plankHeight)
                        
                        // Base plank fill with directional grain gradient
                        let baseColor = plankBaseColors[i % plankBaseColors.count]
                        let darkerColor = baseColor.opacity(0.85)
                        let gradient = Gradient(colors: [baseColor, darkerColor, baseColor])
                        context.fill(Path(plankRect), with: .linearGradient(gradient, startPoint: CGPoint(x: 0, y: y), endPoint: CGPoint(x: 0, y: y + plankHeight)))
                        
                        // Procedural wavy wood-grain lines
                        let grainLinesCount = 9
                        for g in 0..<grainLinesCount {
                            let lineY = y + (CGFloat(g) + 0.5) * (plankHeight / CGFloat(grainLinesCount))
                            var grainPath = Path()
                            grainPath.move(to: CGPoint(x: 0, y: lineY))
                            
                            let waveFreq = 0.015 + Double(g % 3) * 0.008
                            let waveAmp: CGFloat = 2.0 + CGFloat(g % 4) * 1.5
                            let phaseOffset = Double(i * 13 + g * 37)
                            
                            var x: CGFloat = 0
                            while x <= canvasSize.width {
                                let curY = lineY + sin(Double(x) * waveFreq + phaseOffset) * waveAmp
                                grainPath.addLine(to: CGPoint(x: x, y: curY))
                                x += 15
                            }
                            
                            let grainAlpha = 0.12 + (Double(g % 3) * 0.06)
                            let grainColor = (g % 2 == 0)
                                ? Color(red: 0.35, green: 0.18, blue: 0.08).opacity(grainAlpha)
                                : Color(red: 0.75, green: 0.50, blue: 0.28).opacity(grainAlpha * 0.7)
                            
                            context.stroke(grainPath, with: .color(grainColor), lineWidth: 1.2)
                        }
                        
                        // Wood Knot simulation on alternating planks
                        if i % 2 == 1 {
                            let knotX = (canvasSize.width * 0.25) + CGFloat((i * 120) % Int(canvasSize.width * 0.5))
                            let knotY = y + plankHeight * 0.5
                            
                            for r in 1...4 {
                                let knotRect = CGRect(
                                    x: knotX - CGFloat(r * 9),
                                    y: knotY - CGFloat(r * 5),
                                    width: CGFloat(r * 18),
                                    height: CGFloat(r * 10)
                                )
                                context.stroke(Path(ellipseIn: knotRect), with: .color(Color(red: 0.30, green: 0.15, blue: 0.06).opacity(0.18)), lineWidth: 1.0)
                            }
                        }
                        
                        // Dark Plank Groove Separator
                        if i > 0 {
                            let groovePath = Path(CGRect(x: 0, y: y - 1.5, width: canvasSize.width, height: 3.0))
                            context.fill(groovePath, with: .color(Color(red: 0.20, green: 0.10, blue: 0.04).opacity(0.75)))
                            
                            // Top highlight line for 3D bevel
                            var bevelPath = Path()
                            bevelPath.move(to: CGPoint(x: 0, y: y + 1.5))
                            bevelPath.addLine(to: CGPoint(x: canvasSize.width, y: y + 1.5))
                            context.stroke(bevelPath, with: .color(Color(red: 0.85, green: 0.65, blue: 0.40).opacity(0.25)), lineWidth: 1.0)
                        }
                    }
                }
                
                // 2. Procedural Checkered Picnic Runner (Left side accent)
                CheckeredPicnicRunnerView()
                    .frame(width: 80)
                    .position(x: 40, y: size.height / 2)
                
                // 3. Central Fold Hinge Shadow & Crease Zone
                // Visual crease line with depth shadow that deepens as the device folds
                let foldProgress = (180.0 - hingeAngle) / 180.0 // 0.0 (flat) to 1.0 (closed)
                let creaseShadowWidth: CGFloat = 16.0 + CGFloat(foldProgress * 24.0)
                
                HStack(spacing: 0) {
                    // Left crease shadow
                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.18 + foldProgress * 0.45)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: creaseShadowWidth)
                    
                    // Central physical hinge crease line
                    Rectangle()
                        .fill(Color.black.opacity(0.40 + foldProgress * 0.45))
                        .frame(width: 2.0)
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                    
                    // Right crease shadow
                    LinearGradient(
                        colors: [Color.black.opacity(0.18 + foldProgress * 0.45), Color.black.opacity(0.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: creaseShadowWidth)
                }
                .position(x: midX, y: size.height / 2.0)
                
                // 4. Warm Sunny Ambient Vignette Overlay
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.70).opacity(0.16),
                        Color(red: 0.90, green: 0.75, blue: 0.45).opacity(0.08),
                        Color.black.opacity(0.35)
                    ]),
                    center: .center,
                    startRadius: size.width * 0.2,
                    endRadius: size.width * 0.95
                )
                .blendMode(.multiply)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
    }
}

/// Procedural Red-and-White Checkered Picnic Cloth Runner
struct CheckeredPicnicRunnerView: View {
    var body: some View {
        Canvas { context, size in
            let tileSize: CGFloat = 20.0
            let cols = Int(ceil(size.width / tileSize))
            let rows = Int(ceil(size.height / tileSize))
            
            // Drop shadow behind runner
            let shadowRect = CGRect(x: 4, y: 0, width: size.width, height: size.height)
            context.fill(Path(shadowRect), with: .color(Color.black.opacity(0.25)))
            
            let redColor = Color(red: 0.85, green: 0.18, blue: 0.22)
            let pinkOverlap = Color(red: 0.95, green: 0.55, blue: 0.58)
            let whiteCloth = Color(red: 0.98, green: 0.96, blue: 0.92)
            
            for c in 0..<cols {
                for r in 0..<rows {
                    let tileRect = CGRect(x: CGFloat(c) * tileSize, y: CGFloat(r) * tileSize, width: tileSize, height: tileSize)
                    let tileColor: Color
                    if c % 2 == 0 && r % 2 == 0 {
                        tileColor = redColor
                    } else if c % 2 == 1 && r % 2 == 1 {
                        tileColor = whiteCloth
                    } else {
                        tileColor = pinkOverlap
                    }
                    context.fill(Path(tileRect), with: .color(tileColor))
                }
            }
            
            // Fringe tassels on right edge
            var fringePath = Path()
            var y: CGFloat = 0
            while y < size.height {
                fringePath.move(to: CGPoint(x: size.width, y: y))
                fringePath.addLine(to: CGPoint(x: size.width + 5.0, y: y + 2.0))
                y += 4.0
            }
            context.stroke(fringePath, with: .color(whiteCloth.opacity(0.8)), lineWidth: 1.5)
        }
    }
}
