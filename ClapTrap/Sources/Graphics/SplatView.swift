import SwiftUI

/// Data model representing a persistent bug splat impact
public struct SplatterRecord: Identifiable {
    public let id = UUID()
    public let primaryPosition: CGPoint
    public let mirroredPosition: CGPoint
    public let insectType: InsectType
    public let rotationAngle: Double
    public let scale: CGFloat
    public let seed: Int
    public let timestamp: Date
    public let normalizedX: CGFloat
    public let normalizedY: CGFloat
    
    public init(
        primaryPosition: CGPoint,
        hingeX: CGFloat,
        insectType: InsectType,
        scale: CGFloat = 1.0,
        referenceScreenSize: CGSize? = nil
    ) {
        self.primaryPosition = primaryPosition
        // Calculate mirrored coordinate for geometry reference
        let mirroredX = 2.0 * hingeX - primaryPosition.x
        self.mirroredPosition = CGPoint(x: mirroredX, y: primaryPosition.y)
        self.insectType = insectType
        self.rotationAngle = Double.random(in: 0...(2 * .pi))
        self.scale = scale * insectType.baseScale
        self.seed = Int.random(in: 1...99999)
        self.timestamp = Date()
        
        let size = referenceScreenSize ?? ClapTrapGameEngine.shared.dualScreenSize
        let screenW = max(100.0, size.width)
        let screenH = max(100.0, size.height)
        self.normalizedX = primaryPosition.x / screenW
        self.normalizedY = primaryPosition.y / screenH
    }
    
    /// Returns the exact, stable position on the playfield table.
    /// Preserves exact coordinates, and smoothly maintains relative table position if orientation changes.
    public func position(for screenSize: CGSize) -> CGPoint {
        if screenSize.width <= 0 || screenSize.height <= 0 {
            return primaryPosition
        }
        let originalW = normalizedX > 0.001 ? (primaryPosition.x / normalizedX) : screenSize.width
        if abs(screenSize.width - originalW) < 2.0 {
            return primaryPosition
        }
        return CGPoint(
            x: normalizedX * screenSize.width,
            y: normalizedY * screenSize.height
        )
    }
}

/// Renders exactly ONE single dead fly splat decal per kill — realistic, authentic, and stationary.
public struct SplatView: View {
    public let splatter: SplatterRecord
    
    public init(splatter: SplatterRecord) {
        self.splatter = splatter
    }
    
    public var body: some View {
        SingleSplatDecal(
            insectType: splatter.insectType,
            scale: splatter.scale,
            seed: splatter.seed,
            isMirroredDecal: false
        )
        .rotationEffect(.radians(splatter.rotationAngle))
    }
}

/// Single splat decal drawing cartoon bug juice, severed spiky legs, squashed compound eyes, and droplets
public struct SingleSplatDecal: View {
    public let insectType: InsectType
    public let scale: CGFloat
    public let seed: Int
    public let isMirroredDecal: Bool
    
    public init(insectType: InsectType, scale: CGFloat, seed: Int, isMirroredDecal: Bool) {
        self.insectType = insectType
        self.scale = scale
        self.seed = seed
        self.isMirroredDecal = isMirroredDecal
    }
    
    public var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
            let baseRadius: CGFloat = 26.0 * scale
            
            // 1. Organic Randomized Bezier Guts Splat Polygon
            var splatCore = Path()
            let pointCount = 12
            var points: [CGPoint] = []
            
            for i in 0..<pointCount {
                let angle = (Double(i) / Double(pointCount)) * 2.0 * .pi
                // Deterministic pseudo-random spikes based on seed and index
                let pseudoRand = abs(sin(Double(seed * 7 + i * 31)))
                let radius = baseRadius * CGFloat(0.55 + pseudoRand * 0.9)
                let pt = CGPoint(
                    x: center.x + radius * cos(angle),
                    y: center.y + radius * sin(angle)
                )
                points.append(pt)
            }
            
            splatCore.move(to: points[0])
            for i in 0..<pointCount {
                let current = points[i]
                let next = points[(i + 1) % pointCount]
                let mid = CGPoint(x: (current.x + next.x) * 0.5, y: (current.y + next.y) * 0.5)
                splatCore.addQuadCurve(to: mid, control: current)
            }
            splatCore.closeSubpath()
            
            // Splat Color Theme based on insect
            let primaryJuiceColor: Color
            let darkHemolymphColor: Color
            
            switch insectType {
            case .housefly:
                primaryJuiceColor = Color(red: 0.50, green: 0.95, blue: 0.10) // Neon Chartreuse Green
                darkHemolymphColor = Color(red: 0.12, green: 0.35, blue: 0.08)
            case .mosquito:
                primaryJuiceColor = Color(red: 0.85, green: 0.10, blue: 0.15) // Squashed Blood Red!
                darkHemolymphColor = Color(red: 0.45, green: 0.05, blue: 0.08)
            case .mutantHorsefly:
                primaryJuiceColor = Color(red: 0.80, green: 0.98, blue: 0.15) // Radioactive Lime
                darkHemolymphColor = Color(red: 0.25, green: 0.40, blue: 0.05)
            case .wasp:
                primaryJuiceColor = Color(red: 0.95, green: 0.85, blue: 0.05) // Toxic Yellow
                darkHemolymphColor = Color(red: 0.45, green: 0.35, blue: 0.02)
            }
            
            // Core visceral bug juice fill with radial gradient
            let juiceGradient = Gradient(colors: [
                primaryJuiceColor.opacity(0.95),
                darkHemolymphColor.opacity(0.85),
                primaryJuiceColor.opacity(0.40)
            ])
            context.fill(splatCore, with: .radialGradient(juiceGradient, center: center, startRadius: 2, endRadius: baseRadius * 1.3))
            
            // 2. High-viscosity inner goo puddles
            var innerGoo = Path()
            innerGoo.addEllipse(in: CGRect(
                x: center.x - baseRadius * 0.45,
                y: center.y - baseRadius * 0.45,
                width: baseRadius * 0.9,
                height: baseRadius * 0.9
            ))
            context.fill(innerGoo, with: .color(primaryJuiceColor))
            
            // Specular shiny highlight on wet bug juice
            var specularHighlight = Path()
            specularHighlight.addEllipse(in: CGRect(
                x: center.x - baseRadius * 0.3,
                y: center.y - baseRadius * 0.35,
                width: baseRadius * 0.45,
                height: baseRadius * 0.25
            ))
            context.fill(specularHighlight, with: .color(Color.white.opacity(0.75)))
            
            // 3. Severed Squished Fly Legs sticking out at funny angles!
            let legAngles: [Double] = [0.4, 1.2, 2.5, 3.6, 4.8, 5.7]
            for (idx, baseA) in legAngles.enumerated() {
                let jitter = sin(Double(seed + idx * 19)) * 0.3
                let finalAngle = baseA + jitter
                
                var legPath = Path()
                let startR = baseRadius * 0.5
                let kneeR = baseRadius * 1.3
                let tipR = baseRadius * 1.8
                
                let startPt = CGPoint(x: center.x + startR * cos(finalAngle), y: center.y + startR * sin(finalAngle))
                let kneePt = CGPoint(x: center.x + kneeR * cos(finalAngle + 0.35), y: center.y + kneeR * sin(finalAngle + 0.35))
                let tipPt = CGPoint(x: center.x + tipR * cos(finalAngle - 0.2), y: center.y + tipR * sin(finalAngle - 0.2))
                
                legPath.move(to: startPt)
                legPath.addLine(to: kneePt)
                legPath.addLine(to: tipPt)
                
                context.stroke(legPath, with: .color(Color(red: 0.10, green: 0.10, blue: 0.12)), style: StrokeStyle(lineWidth: 2.0 * scale, lineCap: .round, lineJoin: .miter))
            }
            
            // 4. Squished Red Compound Eye remnant
            var eyeRemnant = Path()
            eyeRemnant.addEllipse(in: CGRect(x: center.x + 4 * scale, y: center.y - 8 * scale, width: 9 * scale, height: 6 * scale))
            context.fill(eyeRemnant, with: .color(Color(red: 0.90, green: 0.05, blue: 0.10)))
            
            // Eye gleam
            context.fill(Path(ellipseIn: CGRect(x: center.x + 6 * scale, y: center.y - 7 * scale, width: 2.5 * scale, height: 2 * scale)), with: .color(Color.white.opacity(0.85)))
            
            // 5. Severed Iridescent Wing Scrap
            var wingFragment = Path()
            wingFragment.move(to: CGPoint(x: center.x - 6 * scale, y: center.y + 6 * scale))
            wingFragment.addLine(to: CGPoint(x: center.x - 22 * scale, y: center.y + 18 * scale))
            wingFragment.addLine(to: CGPoint(x: center.x - 12 * scale, y: center.y + 24 * scale))
            wingFragment.closeSubpath()
            context.fill(wingFragment, with: .color(Color.white.opacity(0.45)))
            context.stroke(wingFragment, with: .color(Color.black.opacity(0.3)), lineWidth: 0.8)
            
            // 6. Radiating Droplets / Splatter Satellites
            let dropletCount = 14
            for d in 0..<dropletCount {
                let dropAngle = (Double(d) / Double(dropletCount)) * 2.0 * .pi + Double(seed % 30)
                let dropDist = baseRadius * CGFloat(1.4 + abs(sin(Double(seed * 3 + d * 17))) * 1.5)
                let dropRadius = CGFloat(2.0 + abs(cos(Double(seed + d * 23))) * 3.5) * scale
                
                let dropPos = CGPoint(
                    x: center.x + dropDist * cos(dropAngle),
                    y: center.y + dropDist * sin(dropAngle)
                )
                
                var dropPath = Path()
                dropPath.addEllipse(in: CGRect(x: dropPos.x - dropRadius, y: dropPos.y - dropRadius, width: dropRadius * 2, height: dropRadius * 2))
                context.fill(dropPath, with: .color(primaryJuiceColor.opacity(0.9)))
            }
        }
        .frame(width: 140 * scale, height: 140 * scale)
    }
}
