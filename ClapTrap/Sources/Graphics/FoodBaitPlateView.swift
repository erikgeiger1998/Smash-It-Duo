import SwiftUI

/// Top-down procedural playfield bait lures for attracting flies, mosquitoes, and bosses:
/// 100% procedural Canvas graphics with 10 distinct food dishes across Fruits, Fast Food, and Pasta,
/// complete with animated thermal atmospheric effects (rising hot steam wisps, frosty chill mist & ice crystals).
public struct FoodBaitPlateView: View {
    public let bait: FoodBaitType
    
    // Internal animation timer phase for rising steam / chill mist
    @State private var animPhase: Double = 0.0
    
    public init(bait: FoodBaitType = .chilledWatermelon) {
        self.bait = bait
    }
    
    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let phase = elapsed * 1.8
            
            ZStack {
                // 1. Procedural Dish Surface
                Canvas { context, size in
                    let center = CGPoint(x: size.width * 0.5, y: size.height * 0.58)
                    
                    switch bait {
                    case .chilledWatermelon:
                        drawWatermelon(context: context, size: size, center: center)
                    case .frostyStrawberry:
                        drawStrawberry(context: context, size: size, center: center)
                    case .icedOrangeWheel:
                        drawOrangeWheel(context: context, size: size, center: center)
                    case .cheesyBurger:
                        drawBurger(context: context, size: size, center: center)
                    case .pepperoniPizza:
                        drawPizza(context: context, size: size, center: center)
                    case .crispyFries:
                        drawFries(context: context, size: size, center: center)
                    case .sizzlingHotdog:
                        drawHotdog(context: context, size: size, center: center)
                    case .spaghettiBolognese:
                        drawSpaghetti(context: context, size: size, center: center)
                    case .creamyFettuccine:
                        drawFettuccine(context: context, size: size, center: center)
                    case .glazedDonut:
                        drawDonut(context: context, size: size, center: center)
                    }
                }
                .frame(width: 140, height: 110)
                
                // 2. Animated Thermal Atmosphere Layer (Steam / Frost / Glint)
                thermalEffectOverlay(phase: phase)
                    .frame(width: 140, height: 130)
                    .offset(y: -15)
                    .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: - Thermal Atmospheric Overlay (Hot Steam & Cold Frost)
    
    @ViewBuilder
    private func thermalEffectOverlay(phase: Double) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.65)
            
            switch bait.thermalEffect {
            case .hot:
                // Sizzling Hot Food: Curling, undulating rising steam wisps
                drawRisingSteamWisps(context: context, size: size, center: center, phase: phase)
                
            case .cold:
                // Chilled / Frosty Food: Frost vapor clouds and twinkling ice crystals
                drawColdChillMistAndCrystals(context: context, size: size, center: center, phase: phase)
                
            case .fresh:
                // Fresh Sweet Glaze: Pulsing specular sparkle glints
                drawFreshGlazeSparkles(context: context, size: size, center: center, phase: phase)
            }
        }
    }
    
    // MARK: - 1. HOT STEAM WISPS
    private func drawRisingSteamWisps(context: GraphicsContext, size: CGSize, center: CGPoint, phase: Double) {
        let streamOffsets: [CGFloat] = [-30, -10, 12, 32]
        
        for (i, baseX) in streamOffsets.enumerated() {
            let offsetPhase = phase + Double(i) * 1.57
            let cycle = offsetPhase.truncatingRemainder(dividingBy: 3.0) / 3.0 // 0.0 to 1.0
            
            let startY = center.y - 10
            let endY = startY - 45 - CGFloat(cycle * 30.0)
            let midY = (startY + endY) * 0.5
            
            let sway1 = sin(offsetPhase * 2.2) * 12.0
            let sway2 = cos(offsetPhase * 1.8) * 14.0
            
            var steam = Path()
            steam.move(to: CGPoint(x: center.x + baseX + sway1 * 0.3, y: startY))
            steam.addCurve(
                to: CGPoint(x: center.x + baseX + sway2, y: endY),
                control1: CGPoint(x: center.x + baseX + sway1, y: midY + 10),
                control2: CGPoint(x: center.x + baseX - sway2 * 0.5, y: midY - 10)
            )
            
            // Fades in as it lifts, then fades out as it disperses into air
            let alpha = sin(cycle * .pi) * 0.42
            let strokeColor = Color(red: 1.0, green: 0.95, blue: 0.88).opacity(alpha)
            
            context.stroke(
                steam,
                with: .color(strokeColor),
                style: StrokeStyle(lineWidth: 3.2 + CGFloat(cycle * 3.5), lineCap: .round)
            )
        }
    }
    
    // MARK: - 2. COLD CHILL MIST & ICE CRYSTALS
    private func drawColdChillMistAndCrystals(context: GraphicsContext, size: CGSize, center: CGPoint, phase: Double) {
        // Cold Rolling Mist hovering low over the dish
        for m in 0..<3 {
            let mPhase = phase * 0.8 + Double(m) * 2.1
            let driftX = sin(mPhase) * 15.0
            let mistY = center.y + 12 + cos(mPhase * 0.7) * 4.0
            let mistRect = CGRect(x: center.x - 45 + driftX, y: mistY, width: 90, height: 20)
            
            let mistGradient = Gradient(colors: [
                Color(red: 0.75, green: 0.92, blue: 1.0).opacity(0.18 + 0.08 * sin(mPhase)),
                Color.clear
            ])
            context.fill(Path(ellipseIn: mistRect), with: .radialGradient(mistGradient, center: CGPoint(x: mistRect.midX, y: mistRect.midY), startRadius: 2, endRadius: 40))
        }
        
        // Twinkling Diamond Ice Crystals
        let crystalPositions: [(CGFloat, CGFloat, Double)] = [
            (-32, -24, 0.0),
            (28, -20, 1.2),
            (-12, -34, 2.4),
            (15, -12, 3.6),
            (-24, 8, 4.8)
        ]
        
        for (ox, oy, cOffset) in crystalPositions {
            let sparkleTime = phase * 1.5 + cOffset
            let twinkle = max(0.0, sin(sparkleTime))
            if twinkle > 0.15 {
                let pt = CGPoint(x: center.x + ox, y: center.y + oy)
                let cSize: CGFloat = 3.5 * CGFloat(twinkle)
                
                var star = Path()
                star.move(to: CGPoint(x: pt.x - cSize, y: pt.y))
                star.addLine(to: CGPoint(x: pt.x + cSize, y: pt.y))
                star.move(to: CGPoint(x: pt.x, y: pt.y - cSize))
                star.addLine(to: CGPoint(x: pt.x, y: pt.y + cSize))
                
                context.stroke(star, with: .color(Color(red: 0.85, green: 0.98, blue: 1.0).opacity(twinkle * 0.9)), lineWidth: 1.2)
                context.fill(Path(ellipseIn: CGRect(x: pt.x - 1, y: pt.y - 1, width: 2, height: 2)), with: .color(Color.white))
            }
        }
    }
    
    // MARK: - 3. FRESH SWEET GLAZE SPARKLES
    private func drawFreshGlazeSparkles(context: GraphicsContext, size: CGSize, center: CGPoint, phase: Double) {
        let spots: [(CGFloat, CGFloat, Double)] = [
            (-22, -16, 0.0),
            (18, -22, 1.4),
            (-8, 12, 2.8),
            (24, 4, 4.2)
        ]
        
        for (ox, oy, offset) in spots {
            let pulse = max(0.0, sin(phase * 1.8 + offset))
            if pulse > 0.25 {
                let pt = CGPoint(x: center.x + ox, y: center.y + oy)
                let r: CGFloat = 3.0 * CGFloat(pulse)
                context.fill(Path(ellipseIn: CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)), with: .color(Color.white.opacity(pulse * 0.85)))
            }
        }
    }
    
    // MARK: - PROCEDURAL FOOD DRAWING METHODS
    
    // 1. CHILLED WATERMELON
    private func drawWatermelon(context: GraphicsContext, size: CGSize, center: CGPoint) {
        let radius: CGFloat = 55.0
        
        // Shadow
        var shadow = Path()
        shadow.addArc(center: CGPoint(x: center.x + 3, y: center.y + 6), radius: radius + 2, startAngle: .degrees(190), endAngle: .degrees(350), clockwise: false)
        shadow.closeSubpath()
        context.fill(shadow, with: .color(Color.black.opacity(0.32)))
        
        // Dark Green Rind
        var outerRind = Path()
        outerRind.addArc(center: center, radius: radius, startAngle: .degrees(195), endAngle: .degrees(345), clockwise: false)
        context.stroke(
            outerRind,
            with: .linearGradient(Gradient(colors: [Color(red: 0.12, green: 0.42, blue: 0.15), Color(red: 0.22, green: 0.60, blue: 0.26), Color(red: 0.08, green: 0.35, blue: 0.12)]), startPoint: CGPoint(x: center.x - radius, y: center.y), endPoint: CGPoint(x: center.x + radius, y: center.y)),
            style: StrokeStyle(lineWidth: 10, lineCap: .round)
        )
        
        // Pale Inner Rind
        var innerRind = Path()
        innerRind.addArc(center: center, radius: radius - 5, startAngle: .degrees(196), endAngle: .degrees(344), clockwise: false)
        context.stroke(innerRind, with: .color(Color(red: 0.90, green: 0.98, blue: 0.88)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
        
        // Ruby Pulp
        var pulp = Path()
        let pRadius = radius - 8
        pulp.move(to: center)
        let leftPt = CGPoint(x: center.x + pRadius * cos(.pi * 197 / 180), y: center.y + pRadius * sin(.pi * 197 / 180))
        pulp.addLine(to: leftPt)
        pulp.addArc(center: center, radius: pRadius, startAngle: .degrees(197), endAngle: .degrees(343), clockwise: false)
        let rightPt = CGPoint(x: center.x + pRadius * cos(.pi * 343 / 180), y: center.y + pRadius * sin(.pi * 343 / 180))
        pulp.addQuadCurve(to: CGPoint(x: (rightPt.x + center.x) * 0.72, y: center.y - 8), control: CGPoint(x: (rightPt.x + center.x) * 0.85, y: center.y + 12))
        pulp.addQuadCurve(to: CGPoint(x: (rightPt.x + center.x) * 0.42, y: center.y - 12), control: CGPoint(x: (rightPt.x + center.x) * 0.55, y: center.y + 10))
        pulp.closeSubpath()
        
        let pulpGrad = Gradient(colors: [Color(red: 0.98, green: 0.16, blue: 0.32), Color(red: 0.90, green: 0.10, blue: 0.25), Color(red: 0.80, green: 0.06, blue: 0.18)])
        context.fill(pulp, with: .radialGradient(pulpGrad, center: center, startRadius: 5, endRadius: pRadius))
        
        // Seeds
        let seeds = [CGPoint(x: center.x - 26, y: center.y - 16), CGPoint(x: center.x - 8, y: center.y - 24), CGPoint(x: center.x + 14, y: center.y - 18), CGPoint(x: center.x + 28, y: center.y - 10)]
        for pt in seeds {
            context.fill(Path(ellipseIn: CGRect(x: pt.x - 3, y: pt.y - 5, width: 6, height: 10)), with: .color(Color(red: 0.10, green: 0.05, blue: 0.05)))
            context.fill(Path(ellipseIn: CGRect(x: pt.x - 1, y: pt.y - 3, width: 2, height: 3)), with: .color(Color.white.opacity(0.85)))
        }
    }
    
    // 2. FROSTY STRAWBERRY
    private func drawStrawberry(context: GraphicsContext, size: CGSize, center: CGPoint) {
        // Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - 30, y: center.y + 8, width: 60, height: 20)), with: .color(Color.black.opacity(0.35)))
        
        // Heart berry body
        var berry = Path()
        berry.move(to: CGPoint(x: center.x, y: center.y + 24)) // Tip
        berry.addCurve(to: CGPoint(x: center.x - 32, y: center.y - 14), control1: CGPoint(x: center.x - 18, y: center.y + 20), control2: CGPoint(x: center.x - 34, y: center.y + 5))
        berry.addQuadCurve(to: CGPoint(x: center.x, y: center.y - 26), control: CGPoint(x: center.x - 30, y: center.y - 30))
        berry.addQuadCurve(to: CGPoint(x: center.x + 32, y: center.y - 14), control: CGPoint(x: center.x + 30, y: center.y - 30))
        berry.addCurve(to: CGPoint(x: center.x, y: center.y + 24), control1: CGPoint(x: center.x + 34, y: center.y + 5), control2: CGPoint(x: center.x + 18, y: center.y + 20))
        berry.closeSubpath()
        
        let berryGrad = Gradient(colors: [Color(red: 1.0, green: 0.18, blue: 0.32), Color(red: 0.85, green: 0.08, blue: 0.20), Color(red: 0.60, green: 0.02, blue: 0.12)])
        context.fill(berry, with: .radialGradient(berryGrad, center: CGPoint(x: center.x - 6, y: center.y - 8), startRadius: 4, endRadius: 36))
        
        // Golden Seed Pits
        let seedGrid: [CGPoint] = [
            CGPoint(x: center.x - 16, y: center.y - 12), CGPoint(x: center.x, y: center.y - 16), CGPoint(x: center.x + 16, y: center.y - 12),
            CGPoint(x: center.x - 18, y: center.y), CGPoint(x: center.x - 4, y: center.y - 2), CGPoint(x: center.x + 12, y: center.y),
            CGPoint(x: center.x - 10, y: center.y + 10), CGPoint(x: center.x + 4, y: center.y + 10), CGPoint(x: center.x - 2, y: center.y + 18)
        ]
        for s in seedGrid {
            context.fill(Path(ellipseIn: CGRect(x: s.x - 1.5, y: s.y - 2.5, width: 3, height: 5)), with: .color(Color(red: 1.0, green: 0.85, blue: 0.25)))
        }
        
        // Leafy Green Crown (Calyx)
        var crown = Path()
        crown.move(to: CGPoint(x: center.x, y: center.y - 26))
        crown.addLine(to: CGPoint(x: center.x - 28, y: center.y - 22))
        crown.addLine(to: CGPoint(x: center.x - 12, y: center.y - 28))
        crown.addLine(to: CGPoint(x: center.x - 18, y: center.y - 38))
        crown.addLine(to: CGPoint(x: center.x - 4, y: center.y - 30))
        crown.addLine(to: CGPoint(x: center.x + 4, y: center.y - 30))
        crown.addLine(to: CGPoint(x: center.x + 18, y: center.y - 38))
        crown.addLine(to: CGPoint(x: center.x + 12, y: center.y - 28))
        crown.addLine(to: CGPoint(x: center.x + 28, y: center.y - 22))
        crown.closeSubpath()
        context.fill(crown, with: .color(Color(red: 0.18, green: 0.65, blue: 0.22)))
        
        // Stem
        var stem = Path()
        stem.move(to: CGPoint(x: center.x, y: center.y - 28))
        stem.addQuadCurve(to: CGPoint(x: center.x + 4, y: center.y - 42), control: CGPoint(x: center.x + 8, y: center.y - 35))
        context.stroke(stem, with: .color(Color(red: 0.12, green: 0.48, blue: 0.16)), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
    }
    
    // 3. ICED ORANGE WHEEL
    private func drawOrangeWheel(context: GraphicsContext, size: CGSize, center: CGPoint) {
        let r: CGFloat = 38.0
        
        // Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - r + 3, y: center.y - r + 6, width: r * 2, height: r * 2)), with: .color(Color.black.opacity(0.32)))
        
        // Outer Orange Peel Ring
        let peelRect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        let peelGrad = Gradient(colors: [Color(red: 1.0, green: 0.52, blue: 0.05), Color(red: 0.92, green: 0.42, blue: 0.02)])
        context.fill(Path(ellipseIn: peelRect), with: .radialGradient(peelGrad, center: center, startRadius: r * 0.7, endRadius: r))
        
        // White Pith Ring
        let pithR = r - 4.5
        context.fill(Path(ellipseIn: CGRect(x: center.x - pithR, y: center.y - pithR, width: pithR * 2, height: pithR * 2)), with: .color(Color(red: 0.98, green: 0.96, blue: 0.90)))
        
        // 8 Juicy Translucent Pulp Segments
        let segCount = 8
        let segInnerR: CGFloat = 5.0
        let segOuterR = pithR - 3.0
        
        for i in 0..<segCount {
            let startAngle = Double(i) * (2.0 * .pi / Double(segCount)) + 0.08
            let endAngle = Double(i + 1) * (2.0 * .pi / Double(segCount)) - 0.08
            
            var seg = Path()
            seg.move(to: CGPoint(x: center.x + segInnerR * cos(startAngle), y: center.y + segInnerR * sin(startAngle)))
            seg.addLine(to: CGPoint(x: center.x + segOuterR * cos(startAngle), y: center.y + segOuterR * sin(startAngle)))
            seg.addArc(center: center, radius: segOuterR, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: false)
            seg.addLine(to: CGPoint(x: center.x + segInnerR * cos(endAngle), y: center.y + segInnerR * sin(endAngle)))
            seg.closeSubpath()
            
            let segGrad = Gradient(colors: [Color(red: 1.0, green: 0.68, blue: 0.12), Color(red: 0.98, green: 0.48, blue: 0.04)])
            context.fill(seg, with: .linearGradient(segGrad, startPoint: CGPoint(x: center.x, y: center.y), endPoint: CGPoint(x: center.x + segOuterR * cos(startAngle), y: center.y + segOuterR * sin(startAngle))))
        }
        
        // White Center Core
        context.fill(Path(ellipseIn: CGRect(x: center.x - 3.5, y: center.y - 3.5, width: 7, height: 7)), with: .color(Color(red: 0.98, green: 0.96, blue: 0.90)))
    }
    
    // 4. CHEESY SMASH BURGER
    private func drawBurger(context: GraphicsContext, size: CGSize, center: CGPoint) {
        let bW: CGFloat = 78.0
        
        // Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - bW * 0.5 + 4, y: center.y + 16, width: bW, height: 16)), with: .color(Color.black.opacity(0.35)))
        
        // Bottom Bun
        let bottomBun = Path(roundedRect: CGRect(x: center.x - bW * 0.46, y: center.y + 8, width: bW * 0.92, height: 14), cornerRadius: 5)
        context.fill(bottomBun, with: .color(Color(red: 0.82, green: 0.58, blue: 0.32)))
        
        // Beef Patty with char marks
        let pattyRect = CGRect(x: center.x - bW * 0.48, y: center.y + 2, width: bW * 0.96, height: 12)
        context.fill(Path(roundedRect: pattyRect, cornerRadius: 4), with: .color(Color(red: 0.32, green: 0.18, blue: 0.10)))
        
        // Melted Cheddar Cheese Layer with Drips
        var cheese = Path()
        cheese.move(to: CGPoint(x: center.x - bW * 0.50, y: center.y + 2))
        cheese.addLine(to: CGPoint(x: center.x + bW * 0.50, y: center.y + 2))
        cheese.addLine(to: CGPoint(x: center.x + bW * 0.44, y: center.y + 8))
        cheese.addLine(to: CGPoint(x: center.x + bW * 0.28, y: center.y + 14)) // Drip right
        cheese.addLine(to: CGPoint(x: center.x + bW * 0.18, y: center.y + 6))
        cheese.addLine(to: CGPoint(x: center.x - bW * 0.08, y: center.y + 12)) // Drip center
        cheese.addLine(to: CGPoint(x: center.x - bW * 0.24, y: center.y + 6))
        cheese.addLine(to: CGPoint(x: center.x - bW * 0.38, y: center.y + 13)) // Drip left
        cheese.closeSubpath()
        context.fill(cheese, with: .color(Color(red: 1.0, green: 0.76, blue: 0.08)))
        
        // Crisp Wavy Green Lettuce
        var lettuce = Path()
        lettuce.move(to: CGPoint(x: center.x - bW * 0.50, y: center.y - 2))
        var lx = center.x - bW * 0.50
        while lx <= center.x + bW * 0.50 {
            lettuce.addQuadCurve(to: CGPoint(x: lx + 12, y: center.y - 2), control: CGPoint(x: lx + 6, y: center.y + 4))
            lx += 12
        }
        lettuce.addLine(to: CGPoint(x: center.x + bW * 0.48, y: center.y - 4))
        lettuce.addLine(to: CGPoint(x: center.x - bW * 0.48, y: center.y - 4))
        lettuce.closeSubpath()
        context.fill(lettuce, with: .color(Color(red: 0.30, green: 0.78, blue: 0.25)))
        
        // Ripe Tomato Slice
        let tomato = Path(roundedRect: CGRect(x: center.x - bW * 0.44, y: center.y - 8, width: bW * 0.88, height: 7), cornerRadius: 3)
        context.fill(tomato, with: .color(Color(red: 0.92, green: 0.18, blue: 0.16)))
        
        // Curved Top Bun Dome
        var topBun = Path()
        topBun.move(to: CGPoint(x: center.x - bW * 0.48, y: center.y - 7))
        topBun.addCurve(
            to: CGPoint(x: center.x + bW * 0.48, y: center.y - 7),
            control1: CGPoint(x: center.x - bW * 0.42, y: center.y - 32),
            control2: CGPoint(x: center.x + bW * 0.42, y: center.y - 32)
        )
        topBun.closeSubpath()
        let bunGrad = Gradient(colors: [Color(red: 0.92, green: 0.68, blue: 0.38), Color(red: 0.78, green: 0.52, blue: 0.25)])
        context.fill(topBun, with: .linearGradient(bunGrad, startPoint: CGPoint(x: center.x, y: center.y - 28), endPoint: CGPoint(x: center.x, y: center.y - 7)))
        
        // White Sesame Seeds on top bun
        let sesames: [CGPoint] = [
            CGPoint(x: center.x - 20, y: center.y - 18), CGPoint(x: center.x - 6, y: center.y - 22),
            CGPoint(x: center.x + 8, y: center.y - 20), CGPoint(x: center.x + 22, y: center.y - 16),
            CGPoint(x: center.x - 12, y: center.y - 14), CGPoint(x: center.x + 4, y: center.y - 14)
        ]
        for s in sesames {
            context.fill(Path(ellipseIn: CGRect(x: s.x - 1.5, y: s.y - 2.5, width: 3, height: 5)), with: .color(Color(red: 0.98, green: 0.96, blue: 0.88)))
        }
    }
    
    // 5. PEPPERONI PIZZA SLICE
    private func drawPizza(context: GraphicsContext, size: CGSize, center: CGPoint) {
        // Shadow
        var pShadow = Path()
        pShadow.move(to: CGPoint(x: center.x + 4, y: center.y + 26))
        pShadow.addLine(to: CGPoint(x: center.x - 34, y: center.y - 18))
        pShadow.addLine(to: CGPoint(x: center.x + 42, y: center.y - 18))
        pShadow.closeSubpath()
        context.fill(pShadow, with: .color(Color.black.opacity(0.35)))
        
        // Triangle Pizza Wedge
        var wedge = Path()
        wedge.move(to: CGPoint(x: center.x, y: center.y + 24)) // Tip
        wedge.addLine(to: CGPoint(x: center.x - 36, y: center.y - 20))
        wedge.addQuadCurve(to: CGPoint(x: center.x + 36, y: center.y - 20), control: CGPoint(x: center.x, y: center.y - 26))
        wedge.closeSubpath()
        
        // Red Marinara Base
        context.fill(wedge, with: .color(Color(red: 0.82, green: 0.15, blue: 0.10)))
        
        // Molten Mozzarella
        var cheese = Path()
        cheese.move(to: CGPoint(x: center.x, y: center.y + 22))
        cheese.addLine(to: CGPoint(x: center.x - 33, y: center.y - 16))
        cheese.addQuadCurve(to: CGPoint(x: center.x + 33, y: center.y - 16), control: CGPoint(x: center.x, y: center.y - 22))
        cheese.closeSubpath()
        context.fill(cheese, with: .color(Color(red: 1.0, green: 0.85, blue: 0.32)))
        
        // Golden Brown Crust Bumper
        var crust = Path()
        crust.move(to: CGPoint(x: center.x - 38, y: center.y - 20))
        crust.addQuadCurve(to: CGPoint(x: center.x + 38, y: center.y - 20), control: CGPoint(x: center.x, y: center.y - 28))
        context.stroke(crust, with: .linearGradient(Gradient(colors: [Color(red: 0.85, green: 0.58, blue: 0.28), Color(red: 0.70, green: 0.44, blue: 0.20)]), startPoint: CGPoint(x: center.x - 38, y: center.y - 20), endPoint: CGPoint(x: center.x + 38, y: center.y - 20)), style: StrokeStyle(lineWidth: 9, lineCap: .round))
        
        // 4 Pepperoni Discs
        let peps: [CGPoint] = [
            CGPoint(x: center.x - 12, y: center.y - 8),
            CGPoint(x: center.x + 14, y: center.y - 6),
            CGPoint(x: center.x - 2, y: center.y + 6),
            CGPoint(x: center.x + 2, y: center.y - 14)
        ]
        for p in peps {
            context.fill(Path(ellipseIn: CGRect(x: p.x - 8, y: p.y - 7, width: 16, height: 14)), with: .color(Color(red: 0.75, green: 0.18, blue: 0.12)))
            context.fill(Path(ellipseIn: CGRect(x: p.x - 3, y: p.y - 3, width: 4, height: 3)), with: .color(Color.white.opacity(0.40)))
        }
        
        // Green Herb Flecks
        let herbs: [CGPoint] = [CGPoint(x: center.x - 20, y: center.y - 10), CGPoint(x: center.x + 6, y: center.y + 12), CGPoint(x: center.x - 8, y: center.y + 14)]
        for h in herbs {
            context.fill(Path(ellipseIn: CGRect(x: h.x - 1.5, y: h.y - 1.5, width: 3, height: 3)), with: .color(Color(red: 0.20, green: 0.65, blue: 0.22)))
        }
    }
    
    // 6. CRISPY GOLDEN FRIES
    private func drawFries(context: GraphicsContext, size: CGSize, center: CGPoint) {
        // Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - 36, y: center.y + 18, width: 72, height: 16)), with: .color(Color.black.opacity(0.35)))
        
        // Red Fast Food Carton Sleeve
        var carton = Path()
        carton.move(to: CGPoint(x: center.x - 26, y: center.y + 22))
        carton.addLine(to: CGPoint(x: center.x + 26, y: center.y + 22))
        carton.addLine(to: CGPoint(x: center.x + 32, y: center.y - 2))
        carton.addQuadCurve(to: CGPoint(x: center.x - 32, y: center.y - 2), control: CGPoint(x: center.x, y: center.y + 6))
        carton.closeSubpath()
        context.fill(carton, with: .color(Color(red: 0.90, green: 0.16, blue: 0.16)))
        
        // White Arc on Carton
        var arc = Path()
        arc.addArc(center: CGPoint(x: center.x, y: center.y + 12), radius: 8, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        context.stroke(arc, with: .color(Color.white.opacity(0.9)), lineWidth: 2.2)
        
        // Golden French Fries bursting outward
        let fryData: [(CGFloat, CGFloat, CGFloat)] = [
            (-22, -28, -12), (-14, -36, -6), (-6, -42, -2), (4, -40, 4), (14, -34, 8), (22, -26, 14),
            (-18, -20, -8), (-2, -30, 1), (10, -22, 6)
        ]
        
        for (fx, fy, angle) in fryData {
            var fry = Path()
            let rad = angle * .pi / 180.0
            let start = CGPoint(x: center.x + fx, y: center.y + 2)
            let end = CGPoint(x: center.x + fx + sin(rad) * 26, y: center.y + fy)
            fry.move(to: start)
            fry.addLine(to: end)
            
            context.stroke(
                fry,
                with: .linearGradient(Gradient(colors: [Color(red: 1.0, green: 0.88, blue: 0.35), Color(red: 0.90, green: 0.72, blue: 0.20)]), startPoint: start, endPoint: end),
                style: StrokeStyle(lineWidth: 5.5, lineCap: .square)
            )
            // Toasted brown tip
            context.fill(Path(ellipseIn: CGRect(x: end.x - 2.5, y: end.y - 2.5, width: 5, height: 4)), with: .color(Color(red: 0.75, green: 0.50, blue: 0.18)))
        }
        
        // Ketchup Dollop
        let kCenter = CGPoint(x: center.x + 38, y: center.y + 14)
        context.fill(Path(ellipseIn: CGRect(x: kCenter.x - 10, y: kCenter.y - 6, width: 20, height: 12)), with: .color(Color(red: 0.78, green: 0.08, blue: 0.08)))
        context.fill(Path(ellipseIn: CGRect(x: kCenter.x - 4, y: kCenter.y - 4, width: 6, height: 4)), with: .color(Color.white.opacity(0.85)))
    }
    
    // 7. SIZZLING HOTDOG
    private func drawHotdog(context: GraphicsContext, size: CGSize, center: CGPoint) {
        // Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - 46, y: center.y + 12, width: 92, height: 18)), with: .color(Color.black.opacity(0.35)))
        
        // Soft Bun
        let bunRect = CGRect(x: center.x - 44, y: center.y - 6, width: 88, height: 26)
        context.fill(Path(roundedRect: bunRect, cornerRadius: 13), with: .color(Color(red: 0.88, green: 0.66, blue: 0.40)))
        
        // Grilled Sausage
        let sausageRect = CGRect(x: center.x - 46, y: center.y - 12, width: 92, height: 20)
        let sPath = Path(roundedRect: sausageRect, cornerRadius: 10)
        let sGrad = Gradient(colors: [Color(red: 0.76, green: 0.26, blue: 0.18), Color(red: 0.56, green: 0.16, blue: 0.10)])
        context.fill(sPath, with: .linearGradient(sGrad, startPoint: CGPoint(x: center.x, y: center.y - 12), endPoint: CGPoint(x: center.x, y: center.y + 8)))
        
        // Diagonal Char Grill Marks
        for g in -3...3 {
            let gx = center.x + CGFloat(g) * 11
            var grill = Path()
            grill.move(to: CGPoint(x: gx - 4, y: center.y - 10))
            grill.addLine(to: CGPoint(x: gx + 4, y: center.y + 6))
            context.stroke(grill, with: .color(Color(red: 0.25, green: 0.08, blue: 0.05).opacity(0.65)), lineWidth: 2.2)
        }
        
        // Yellow Stadium Mustard Zigzag
        var mustard = Path()
        mustard.move(to: CGPoint(x: center.x - 38, y: center.y - 2))
        var mx = center.x - 38
        var toggle = false
        while mx <= center.x + 36 {
            let my = toggle ? center.y - 7 : center.y + 3
            mustard.addQuadCurve(to: CGPoint(x: mx + 10, y: my), control: CGPoint(x: mx + 5, y: toggle ? center.y + 5 : center.y - 9))
            mx += 10
            toggle.toggle()
        }
        context.stroke(mustard, with: .color(Color(red: 1.0, green: 0.82, blue: 0.10)), style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
    }
    
    // 8. SPAGHETTI BOLOGNESE
    private func drawSpaghetti(context: GraphicsContext, size: CGSize, center: CGPoint) {
        let pRadius: CGFloat = 46.0
        
        // Plate Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - pRadius + 4, y: center.y - pRadius * 0.6 + 8, width: pRadius * 2, height: pRadius * 1.3)), with: .color(Color.black.opacity(0.35)))
        
        // Ceramic White Plate
        let plateRect = CGRect(x: center.x - pRadius, y: center.y - pRadius * 0.6, width: pRadius * 2, height: pRadius * 1.3)
        context.fill(Path(ellipseIn: plateRect), with: .color(Color(red: 0.96, green: 0.96, blue: 0.98)))
        context.stroke(Path(ellipseIn: plateRect), with: .color(Color(red: 0.82, green: 0.84, blue: 0.88)), lineWidth: 3.0)
        
        // Inner Bowl Basin
        let innerRect = CGRect(x: center.x - pRadius + 8, y: center.y - pRadius * 0.6 + 5, width: (pRadius - 8) * 2, height: (pRadius * 1.3) - 10)
        context.fill(Path(ellipseIn: innerRect), with: .color(Color(red: 0.92, green: 0.92, blue: 0.94)))
        
        // Twirled Golden Spaghetti Strands
        let strandCurves: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-26, -6, 24, 4), (-20, 8, 22, -10), (-16, -14, 18, 8), (-24, 0, 20, 10),
            (-12, 12, 16, -12), (-8, -12, 14, 14), (0, -16, 0, 16)
        ]
        for (x1, y1, x2, y2) in strandCurves {
            var noodle = Path()
            noodle.move(to: CGPoint(x: center.x + x1, y: center.y + y1))
            noodle.addCurve(to: CGPoint(x: center.x + x2, y: center.y + y2), control1: CGPoint(x: center.x + x1 * 0.5, y: center.y + y2 * 1.2), control2: CGPoint(x: center.x + x2 * 0.5, y: center.y + y1 * 1.2))
            context.stroke(noodle, with: .color(Color(red: 1.0, green: 0.84, blue: 0.42)), style: StrokeStyle(lineWidth: 3.2, lineCap: .round))
        }
        
        // Rich Red Bolognese Meat Sauce Mound
        let sauceRect = CGRect(x: center.x - 24, y: center.y - 12, width: 48, height: 26)
        context.fill(Path(ellipseIn: sauceRect), with: .color(Color(red: 0.78, green: 0.16, blue: 0.12)))
        
        // Meatball in Center
        let mbCenter = CGPoint(x: center.x, y: center.y - 4)
        context.fill(Path(ellipseIn: CGRect(x: mbCenter.x - 10, y: mbCenter.y - 9, width: 20, height: 18)), with: .color(Color(red: 0.42, green: 0.22, blue: 0.12)))
        context.stroke(Path(ellipseIn: CGRect(x: mbCenter.x - 10, y: mbCenter.y - 9, width: 20, height: 18)), with: .color(Color(red: 0.32, green: 0.15, blue: 0.08)), lineWidth: 1.2)
        
        // Shaved White Parmesan Flakes
        let parm = [CGPoint(x: center.x - 14, y: center.y - 8), CGPoint(x: center.x + 12, y: center.y - 6), CGPoint(x: center.x - 4, y: center.y + 6), CGPoint(x: center.x + 8, y: center.y + 4)]
        for p in parm {
            context.fill(Path(ellipseIn: CGRect(x: p.x - 2, y: p.y - 1.5, width: 4, height: 3)), with: .color(Color.white.opacity(0.95)))
        }
        
        // Fresh Basil Leaf on top
        var basil = Path()
        basil.move(to: CGPoint(x: mbCenter.x - 2, y: mbCenter.y - 8))
        basil.addQuadCurve(to: CGPoint(x: mbCenter.x - 10, y: mbCenter.y - 15), control: CGPoint(x: mbCenter.x - 10, y: mbCenter.y - 8))
        basil.addQuadCurve(to: CGPoint(x: mbCenter.x - 2, y: mbCenter.y - 8), control: CGPoint(x: mbCenter.x - 2, y: mbCenter.y - 15))
        context.fill(basil, with: .color(Color(red: 0.20, green: 0.68, blue: 0.25)))
    }
    
    // 9. CREAMY GARLIC FETTUCCINE
    private func drawFettuccine(context: GraphicsContext, size: CGSize, center: CGPoint) {
        let pRadius: CGFloat = 46.0
        
        // Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - pRadius + 4, y: center.y - pRadius * 0.6 + 8, width: pRadius * 2, height: pRadius * 1.3)), with: .color(Color.black.opacity(0.35)))
        
        // Ceramic Bowl
        let plateRect = CGRect(x: center.x - pRadius, y: center.y - pRadius * 0.6, width: pRadius * 2, height: pRadius * 1.3)
        context.fill(Path(ellipseIn: plateRect), with: .color(Color(red: 0.94, green: 0.94, blue: 0.96)))
        context.stroke(Path(ellipseIn: plateRect), with: .color(Color(red: 0.78, green: 0.80, blue: 0.85)), lineWidth: 3.0)
        
        // Rich Alfredo Cream Sauce Pool
        let alfredoRect = CGRect(x: center.x - pRadius + 10, y: center.y - pRadius * 0.6 + 6, width: (pRadius - 10) * 2, height: (pRadius * 1.3) - 12)
        context.fill(Path(ellipseIn: alfredoRect), with: .color(Color(red: 0.98, green: 0.95, blue: 0.88)))
        
        // Wide Ribbon Fettuccine Strands
        let ribbons: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-24, -6, 22, 6), (-18, 10, 20, -10), (-20, -12, 16, 12), (-14, 4, 18, -4),
            (-10, -8, 14, 8), (0, -12, 0, 10)
        ]
        for (x1, y1, x2, y2) in ribbons {
            var rib = Path()
            rib.move(to: CGPoint(x: center.x + x1, y: center.y + y1))
            rib.addCurve(to: CGPoint(x: center.x + x2, y: center.y + y2), control1: CGPoint(x: center.x + x1 * 0.6, y: center.y + y2 * 1.3), control2: CGPoint(x: center.x + x2 * 0.6, y: center.y + y1 * 1.3))
            context.stroke(rib, with: .color(Color(red: 1.0, green: 0.92, blue: 0.75)), style: StrokeStyle(lineWidth: 6.0, lineCap: .round))
            context.stroke(rib, with: .color(Color(red: 0.92, green: 0.82, blue: 0.60)), style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
        }
        
        // Cracked Black Pepper & Parsley
        let pepper = [CGPoint(x: center.x - 14, y: center.y - 6), CGPoint(x: center.x + 10, y: center.y - 8), CGPoint(x: center.x - 2, y: center.y + 4), CGPoint(x: center.x + 16, y: center.y + 2), CGPoint(x: center.x - 8, y: center.y + 8)]
        for p in pepper {
            context.fill(Path(ellipseIn: CGRect(x: p.x - 1, y: p.y - 1, width: 2, height: 2)), with: .color(Color(red: 0.15, green: 0.15, blue: 0.15)))
        }
        let parsley = [CGPoint(x: center.x - 6, y: center.y - 10), CGPoint(x: center.x + 6, y: center.y - 2), CGPoint(x: center.x, y: center.y + 6)]
        for pr in parsley {
            context.fill(Path(ellipseIn: CGRect(x: pr.x - 1.5, y: pr.y - 1.5, width: 3, height: 3)), with: .color(Color(red: 0.22, green: 0.70, blue: 0.28)))
        }
    }
    
    // 10. PINK GLAZED DONUT
    private func drawDonut(context: GraphicsContext, size: CGSize, center: CGPoint) {
        let outerR: CGFloat = 36.0
        let holeR: CGFloat = 12.0
        
        // Shadow
        context.fill(Path(ellipseIn: CGRect(x: center.x - outerR + 4, y: center.y - outerR + 8, width: outerR * 2, height: outerR * 2)), with: .color(Color.black.opacity(0.35)))
        
        // Golden Fried Dough Torus Ring
        let donutRect = CGRect(x: center.x - outerR, y: center.y - outerR, width: outerR * 2, height: outerR * 2)
        let doughGrad = Gradient(colors: [Color(red: 0.90, green: 0.68, blue: 0.38), Color(red: 0.75, green: 0.48, blue: 0.22)])
        context.fill(Path(ellipseIn: donutRect), with: .radialGradient(doughGrad, center: center, startRadius: holeR, endRadius: outerR))
        
        // Wavy Strawberry Pink Icing
        let icingR = outerR - 2.5
        var icing = Path()
        icing.addArc(center: center, radius: icingR, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.fill(icing, with: .color(Color(red: 1.0, green: 0.45, blue: 0.68)))
        
        // Donut Center Hole (Cutout)
        context.fill(Path(ellipseIn: CGRect(x: center.x - holeR, y: center.y - holeR, width: holeR * 2, height: holeR * 2)), with: .color(Color(red: 0.50, green: 0.30, blue: 0.15).opacity(0.40)))
        context.stroke(Path(ellipseIn: CGRect(x: center.x - holeR, y: center.y - holeR, width: holeR * 2, height: holeR * 2)), with: .color(Color(red: 0.75, green: 0.48, blue: 0.22)), lineWidth: 2.0)
        
        // Rainbow Sugar Sprinkles
        let sprinkles: [(CGFloat, CGFloat, CGFloat, Color)] = [
            (-20, -10, 20, Color.yellow),
            (-12, -22, -35, Color.white),
            (10, -22, 45, Color.cyan),
            (22, -8, -15, Color(red: 0.35, green: 1.0, blue: 0.45)),
            (-22, 10, 40, Color.white),
            (-8, 22, -20, Color.yellow),
            (12, 20, 30, Color.cyan),
            (22, 8, -50, Color.yellow)
        ]
        for (sx, sy, ang, col) in sprinkles {
            var spr = Path()
            spr.addRoundedRect(in: CGRect(x: center.x + sx - 3, y: center.y + sy - 1.2, width: 6, height: 2.4), cornerSize: CGSize(width: 1, height: 1))
            context.fill(spr, with: .color(col))
        }
    }
}
