import SwiftUI

/// Procedural Bait Prop: A mouth-watering half-eaten slice of watermelon
/// with dark glossy seeds, bite marks, specular juice highlights,
/// plus an oozing amber drop of honey/jam near the hinge.
public struct WatermelonBaitView: View {
    public init() {}
    
    public var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.6)
            let radius: CGFloat = min(size.width, size.height) * 0.44
            
            // Soft drop shadow under the watermelon slice
            var shadowPath = Path()
            shadowPath.addArc(center: CGPoint(x: center.x + 4, y: center.y + 6), radius: radius + 2, startAngle: .degrees(190), endAngle: .degrees(350), clockwise: false)
            shadowPath.closeSubpath()
            context.fill(shadowPath, with: .color(Color.black.opacity(0.32)))
            
            // 1. Dark Green Outer Rind Arc
            var outerRind = Path()
            outerRind.addArc(center: center, radius: radius, startAngle: .degrees(195), endAngle: .degrees(345), clockwise: false)
            context.stroke(
                outerRind,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.12, green: 0.42, blue: 0.15),
                        Color(red: 0.20, green: 0.58, blue: 0.24),
                        Color(red: 0.08, green: 0.35, blue: 0.12)
                    ]),
                    startPoint: CGPoint(x: center.x - radius, y: center.y),
                    endPoint: CGPoint(x: center.x + radius, y: center.y)
                ),
                style: StrokeStyle(lineWidth: 10, lineCap: .round)
            )
            
            // 2. Pale Crisp Inner Rind (White/Pale Lime)
            var innerRind = Path()
            innerRind.addArc(center: center, radius: radius - 5, startAngle: .degrees(196), endAngle: .degrees(344), clockwise: false)
            context.stroke(
                innerRind,
                with: .color(Color(red: 0.90, green: 0.98, blue: 0.88)),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
            
            // 3. Juicy Red/Pink Pulp with Nibbled Bite Marks!
            var pulpPath = Path()
            let pulpRadius = radius - 8
            pulpPath.move(to: center)
            
            // Left edge
            let leftPt = CGPoint(x: center.x + pulpRadius * cos(.pi * 197 / 180), y: center.y + pulpRadius * sin(.pi * 197 / 180))
            pulpPath.addLine(to: leftPt)
            
            // Arc along bottom rind
            pulpPath.addArc(center: center, radius: pulpRadius, startAngle: .degrees(197), endAngle: .degrees(343), clockwise: false)
            
            // Bite marks on the top wedge edge (concave nibbles)
            let rightPt = CGPoint(x: center.x + pulpRadius * cos(.pi * 343 / 180), y: center.y + pulpRadius * sin(.pi * 343 / 180))
            
            // Bite 1
            let bite1Mid = CGPoint(x: (rightPt.x + center.x) * 0.72, y: center.y - 8)
            pulpPath.addQuadCurve(to: bite1Mid, control: CGPoint(x: (rightPt.x + center.x) * 0.85, y: center.y + 12))
            
            // Bite 2
            let bite2Mid = CGPoint(x: (rightPt.x + center.x) * 0.42, y: center.y - 12)
            pulpPath.addQuadCurve(to: bite2Mid, control: CGPoint(x: (rightPt.x + center.x) * 0.55, y: center.y + 10))
            
            pulpPath.closeSubpath()
            
            // Fill pulp with radial gradient from deep ruby core to bright pink
            let pulpGradient = Gradient(colors: [
                Color(red: 0.98, green: 0.16, blue: 0.32),
                Color(red: 0.90, green: 0.10, blue: 0.25),
                Color(red: 0.82, green: 0.06, blue: 0.20)
            ])
            context.fill(pulpPath, with: .radialGradient(pulpGradient, center: center, startRadius: 5, endRadius: pulpRadius))
            
            // 4. Glossy Watermelon Seeds with Specular Highlights
            let seedPositions: [CGPoint] = [
                CGPoint(x: center.x - 32, y: center.y - 18),
                CGPoint(x: center.x - 12, y: center.y - 30),
                CGPoint(x: center.x + 15, y: center.y - 24),
                CGPoint(x: center.x + 36, y: center.y - 14),
                CGPoint(x: center.x - 20, y: center.y - 8),
                CGPoint(x: center.x + 8, y: center.y - 10)
            ]
            
            for pt in seedPositions {
                // Teardrop seed shape
                var seedPath = Path()
                let seedRect = CGRect(x: pt.x - 3.5, y: pt.y - 6, width: 7, height: 12)
                seedPath.addEllipse(in: seedRect)
                
                context.fill(seedPath, with: .color(Color(red: 0.10, green: 0.05, blue: 0.05)))
                
                // Specular highlight on seed
                var seedGlint = Path()
                seedGlint.addEllipse(in: CGRect(x: pt.x - 1.5, y: pt.y - 4, width: 2.5, height: 4))
                context.fill(seedGlint, with: .color(Color.white.opacity(0.85)))
            }
            
            // 5. Glossy Specular Sugar Sheen / Juice Highlights on Pulp
            var sheenPath1 = Path()
            sheenPath1.addEllipse(in: CGRect(x: center.x - 28, y: center.y - 32, width: 22, height: 8))
            context.fill(sheenPath1, with: .color(Color.white.opacity(0.35)))
            
            var sheenPath2 = Path()
            sheenPath2.addEllipse(in: CGRect(x: center.x + 10, y: center.y - 36, width: 18, height: 6))
            context.fill(sheenPath2, with: .color(Color.white.opacity(0.40)))
            
            // 6. Oozing Honey / Jam Droplet near the hinge
            let dropCenter = CGPoint(x: center.x + 48, y: center.y + 12)
            
            // Drop shadow
            context.fill(
                Path(ellipseIn: CGRect(x: dropCenter.x - 7, y: dropCenter.y - 3, width: 16, height: 10)),
                with: .color(Color.black.opacity(0.25))
            )
            
            // Honey body
            let honeyGradient = Gradient(colors: [
                Color(red: 1.0, green: 0.82, blue: 0.20),
                Color(red: 0.95, green: 0.62, blue: 0.05),
                Color(red: 0.80, green: 0.45, blue: 0.0)
            ])
            var honeyDrop = Path()
            honeyDrop.addEllipse(in: CGRect(x: dropCenter.x - 8, y: dropCenter.y - 6, width: 16, height: 14))
            context.fill(honeyDrop, with: .radialGradient(honeyGradient, center: dropCenter, startRadius: 1, endRadius: 10))
            
            // Honey specular glossy highlight bead
            var honeyGlint = Path()
            honeyGlint.addEllipse(in: CGRect(x: dropCenter.x - 4, y: dropCenter.y - 4, width: 5, height: 4))
            context.fill(honeyGlint, with: .color(Color.white.opacity(0.88)))
        }
        .frame(width: 140, height: 110)
    }
}
