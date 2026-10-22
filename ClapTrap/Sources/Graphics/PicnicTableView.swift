import SwiftUI

/// Top-down procedural playfield table environments for catching flies.
/// 100% procedural code graphics with 11 distinct theme environments,
/// dynamic 3D hinge crease fold shadows, and atmospheric ambient lighting.
public struct PicnicTableView: View {
    public var hingeAngle: Double = 180.0
    public var theme: TableTheme = ClapTrapGameEngine.shared.currentTheme
    
    public init(hingeAngle: Double = 180.0, theme: TableTheme? = nil) {
        self.hingeAngle = hingeAngle
        self.theme = theme ?? ClapTrapGameEngine.shared.currentTheme
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let midX = size.width / 2.0
            
            ZStack {
                // 1. Procedural Theme Surface (Canvas)
                Canvas { context, canvasSize in
                    switch theme {
                    case .classicPicnic:
                        drawClassicPicnic(context: context, size: canvasSize)
                    case .midnightGlow:
                        drawMidnightGlow(context: context, size: canvasSize)
                    case .cyberpunkNeon:
                        drawCyberpunkNeon(context: context, size: canvasSize)
                    case .espressoCafe:
                        drawEspressoCafe(context: context, size: canvasSize)
                    case .kitchenTiles:
                        drawKitchenTiles(context: context, size: canvasSize)
                    case .gardenLawn:
                        drawGardenLawn(context: context, size: canvasSize)
                    case .arcadeCabinet:
                        drawArcadeCabinet(context: context, size: canvasSize)
                    case .craftWorkbench:
                        drawCraftWorkbench(context: context, size: canvasSize)
                    case .zenTatami:
                        drawZenTatami(context: context, size: canvasSize)
                    case .sweetCandy:
                        drawSweetCandy(context: context, size: canvasSize)
                    case .spaceStarbase:
                        drawSpaceStarbase(context: context, size: canvasSize)
                    }
                }
                
                // 2. Theme-Specific Left Accent Decorator (e.g. Picnic Runner, Desk Mat, Napkin)
                if theme == .classicPicnic {
                    CheckeredPicnicRunnerView()
                        .frame(width: 80)
                        .position(x: 40, y: size.height / 2)
                } else if theme == .sweetCandy {
                    CandyDinerRunnerView()
                        .frame(width: 80)
                        .position(x: 40, y: size.height / 2)
                }
                
                // 3. Ambient Vignette Lighting Overlay
                themeVignette(theme: theme, size: size)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
    }
    
    // MARK: - 1. CLASSIC SUNNY PICNIC
    private func drawClassicPicnic(context: GraphicsContext, size: CGSize) {
        let plankCount = 6
        let plankHeight = size.height / CGFloat(plankCount)
        let plankBaseColors: [Color] = [
            Color(red: 0.58, green: 0.35, blue: 0.18),
            Color(red: 0.52, green: 0.30, blue: 0.14),
            Color(red: 0.62, green: 0.38, blue: 0.20),
            Color(red: 0.48, green: 0.27, blue: 0.12),
            Color(red: 0.56, green: 0.33, blue: 0.16),
            Color(red: 0.50, green: 0.28, blue: 0.13)
        ]
        
        for i in 0..<plankCount {
            let y = CGFloat(i) * plankHeight
            let plankRect = CGRect(x: 0, y: y, width: size.width, height: plankHeight)
            let baseColor = plankBaseColors[i % plankBaseColors.count]
            let gradient = Gradient(colors: [baseColor, baseColor.opacity(0.85), baseColor])
            context.fill(Path(plankRect), with: .linearGradient(gradient, startPoint: CGPoint(x: 0, y: y), endPoint: CGPoint(x: 0, y: y + plankHeight)))
            
            // Wood Grain Lines
            for g in 0..<8 {
                let lineY = y + (CGFloat(g) + 0.5) * (plankHeight / 8.0)
                var grainPath = Path()
                grainPath.move(to: CGPoint(x: 0, y: lineY))
                let waveFreq = 0.015 + Double(g % 3) * 0.008
                let waveAmp: CGFloat = 2.0 + CGFloat(g % 4) * 1.5
                let phaseOffset = Double(i * 13 + g * 37)
                var x: CGFloat = 0
                while x <= size.width {
                    let curY = lineY + sin(Double(x) * waveFreq + phaseOffset) * waveAmp
                    grainPath.addLine(to: CGPoint(x: x, y: curY))
                    x += 18
                }
                context.stroke(grainPath, with: .color(Color(red: 0.30, green: 0.15, blue: 0.06).opacity(0.12)), lineWidth: 1.2)
            }
            
            // Plank Groove Separator
            if i > 0 {
                let groovePath = Path(CGRect(x: 0, y: y - 1.5, width: size.width, height: 3.0))
                context.fill(groovePath, with: .color(Color(red: 0.20, green: 0.10, blue: 0.04).opacity(0.75)))
            }
        }
    }
    
    // MARK: - 2. MIDNIGHT GLOW DESK (DARK NIGHT WITH LIGHTNING FLIES)
    private func drawMidnightGlow(context: GraphicsContext, size: CGSize) {
        // Deep nocturnal ebony desk
        let deskRect = CGRect(origin: .zero, size: size)
        let nightGradient = Gradient(colors: [
            Color(red: 0.05, green: 0.06, blue: 0.10),
            Color(red: 0.08, green: 0.09, blue: 0.15),
            Color(red: 0.04, green: 0.05, blue: 0.08)
        ])
        context.fill(Path(deskRect), with: .linearGradient(nightGradient, startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
        
        // Faint deep indigo wood planks
        let plankCount = 6
        let plankHeight = size.height / CGFloat(plankCount)
        for i in 0..<plankCount {
            let y = CGFloat(i) * plankHeight
            if i > 0 {
                let groove = Path(CGRect(x: 0, y: y - 1, width: size.width, height: 2.0))
                context.fill(groove, with: .color(Color.black.opacity(0.9)))
            }
            // Subtle indigo grain wave
            for g in 0..<4 {
                let lineY = y + CGFloat(g + 1) * (plankHeight / 5.0)
                var grain = Path()
                grain.move(to: CGPoint(x: 0, y: lineY))
                var x: CGFloat = 0
                while x <= size.width {
                    grain.addLine(to: CGPoint(x: x, y: lineY + sin(Double(x) * 0.012 + Double(i * 7)) * 2.5))
                    x += 20
                }
                context.stroke(grain, with: .color(Color(red: 0.2, green: 0.35, blue: 0.6).opacity(0.08)), lineWidth: 1.0)
            }
        }
        
        // Dark leather laptop desk mat with cyan perimeter glow in the center
        let padMargin: CGFloat = 24.0
        let padRect = CGRect(x: padMargin, y: size.height * 0.18, width: size.width - padMargin * 2, height: size.height * 0.64)
        var padPath = Path()
        padPath.addRoundedRect(in: padRect, cornerSize: CGSize(width: 18, height: 18))
        context.fill(padPath, with: .color(Color(red: 0.06, green: 0.07, blue: 0.11).opacity(0.92)))
        context.stroke(padPath, with: .color(Color(red: 0.2, green: 0.85, blue: 0.65).opacity(0.35)), lineWidth: 1.2)
        
        // Floating bioluminescent firefly embers (glowing dots)
        let seeds: [(CGFloat, CGFloat, CGFloat, Color)] = [
            (0.15, 0.25, 3.5, Color.green),
            (0.82, 0.30, 4.0, Color.cyan),
            (0.25, 0.75, 3.0, Color.yellow),
            (0.78, 0.70, 3.8, Color.green),
            (0.48, 0.82, 4.2, Color.cyan),
            (0.35, 0.38, 2.8, Color.yellow)
        ]
        for (rx, ry, r, col) in seeds {
            let pt = CGPoint(x: size.width * rx, y: size.height * ry)
            var ember = Path()
            ember.addEllipse(in: CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2))
            context.fill(ember, with: .color(col.opacity(0.75)))
        }
    }
    
    // MARK: - 3. CYBERPUNK NEON DINER
    private func drawCyberpunkNeon(context: GraphicsContext, size: CGSize) {
        // Brushed dark titanium base
        let baseRect = CGRect(origin: .zero, size: size)
        let steelGradient = Gradient(colors: [
            Color(red: 0.08, green: 0.09, blue: 0.14),
            Color(red: 0.12, green: 0.14, blue: 0.20),
            Color(red: 0.07, green: 0.08, blue: 0.12)
        ])
        context.fill(Path(baseRect), with: .linearGradient(steelGradient, startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)))
        
        // Diagonal brushed titanium texture
        var d: CGFloat = 0
        while d < size.width + size.height {
            var scratch = Path()
            scratch.move(to: CGPoint(x: d, y: 0))
            scratch.addLine(to: CGPoint(x: d - size.height, y: size.height))
            context.stroke(scratch, with: .color(Color.white.opacity(0.025)), lineWidth: 1.0)
            d += 14.0
        }
        
        // Neon grid lines (Cyber blue & electric magenta)
        let gridCols = 8
        let colW = size.width / CGFloat(gridCols)
        for c in 0...gridCols {
            let x = CGFloat(c) * colW
            var line = Path()
            line.move(to: CGPoint(x: x, y: 0))
            line.addLine(to: CGPoint(x: x, y: size.height))
            let color = (c % 2 == 0) ? Color(red: 0.0, green: 0.95, blue: 0.90) : Color(red: 1.0, green: 0.15, blue: 0.65)
            context.stroke(line, with: .color(color.opacity(0.18)), lineWidth: 1.0)
        }
        
        let gridRows = 6
        let rowH = size.height / CGFloat(gridRows)
        for r in 0...gridRows {
            let y = CGFloat(r) * rowH
            var line = Path()
            line.move(to: CGPoint(x: 0, y: y))
            line.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(line, with: .color(Color(red: 0.0, green: 0.95, blue: 0.90).opacity(0.14)), lineWidth: 1.0)
        }
        
        // Top & bottom glowing neon perimeter border
        var topLaser = Path()
        topLaser.move(to: CGPoint(x: 0, y: 3))
        topLaser.addLine(to: CGPoint(x: size.width, y: 3))
        context.stroke(topLaser, with: .color(Color(red: 1.0, green: 0.15, blue: 0.65).opacity(0.65)), lineWidth: 2.5)
        
        var bottomLaser = Path()
        bottomLaser.move(to: CGPoint(x: 0, y: size.height - 3))
        bottomLaser.addLine(to: CGPoint(x: size.width, y: size.height - 3))
        context.stroke(bottomLaser, with: .color(Color(red: 0.0, green: 0.95, blue: 0.90).opacity(0.65)), lineWidth: 2.5)
    }
    
    // MARK: - 4. ESPRESSO CAFE TABLE
    private func drawEspressoCafe(context: GraphicsContext, size: CGSize) {
        // Deep roasted walnut planks
        let plankCount = 6
        let plankHeight = size.height / CGFloat(plankCount)
        let walnutColors: [Color] = [
            Color(red: 0.32, green: 0.18, blue: 0.10),
            Color(red: 0.28, green: 0.15, blue: 0.08),
            Color(red: 0.35, green: 0.20, blue: 0.12),
            Color(red: 0.25, green: 0.14, blue: 0.07),
            Color(red: 0.30, green: 0.17, blue: 0.09),
            Color(red: 0.27, green: 0.15, blue: 0.08)
        ]
        
        for i in 0..<plankCount {
            let y = CGFloat(i) * plankHeight
            let rect = CGRect(x: 0, y: y, width: size.width, height: plankHeight)
            context.fill(Path(rect), with: .color(walnutColors[i % walnutColors.count]))
            
            if i > 0 {
                let groove = Path(CGRect(x: 0, y: y - 1, width: size.width, height: 2.0))
                context.fill(groove, with: .color(Color(red: 0.14, green: 0.07, blue: 0.03)))
            }
        }
        
        // Procedural Coffee Cup Ring Stains
        let stains: [(CGFloat, CGFloat, CGFloat)] = [
            (size.width * 0.28, size.height * 0.35, 34.0),
            (size.width * 0.72, size.height * 0.65, 30.0)
        ]
        for (cx, cy, r) in stains {
            var ring = Path()
            ring.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            context.stroke(ring, with: .color(Color(red: 0.18, green: 0.09, blue: 0.04).opacity(0.28)), lineWidth: 3.5)
            
            var innerDrip = Path()
            innerDrip.addEllipse(in: CGRect(x: cx - r * 0.88, y: cy - r * 0.88, width: r * 1.76, height: r * 1.76))
            context.stroke(innerDrip, with: .color(Color(red: 0.22, green: 0.11, blue: 0.05).opacity(0.14)), lineWidth: 1.5)
        }
    }
    
    // MARK: - 5. KITCHEN SUBWAY TILES
    private func drawKitchenTiles(context: GraphicsContext, size: CGSize) {
        let tileW: CGFloat = 64.0
        let tileH: CGFloat = 36.0
        let cols = Int(ceil(size.width / tileW)) + 1
        let rows = Int(ceil(size.height / tileH)) + 1
        
        // Grout background
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.22, green: 0.26, blue: 0.28)))
        
        for r in 0..<rows {
            let rowOffset: CGFloat = (r % 2 == 1) ? (tileW * 0.5) : 0.0
            for c in 0..<cols {
                let tx = CGFloat(c) * (tileW + 2.0) - rowOffset
                let ty = CGFloat(r) * (tileH + 2.0)
                let tileRect = CGRect(x: tx, y: ty, width: tileW, height: tileH)
                
                // Beveled glossy subway tile
                let isMint = (c + r) % 3 == 0
                let tileColor = isMint ? Color(red: 0.86, green: 0.94, blue: 0.90) : Color(red: 0.96, green: 0.97, blue: 0.98)
                var tilePath = Path()
                tilePath.addRoundedRect(in: tileRect, cornerSize: CGSize(width: 2, height: 2))
                context.fill(tilePath, with: .color(tileColor))
                
                // Subtle top highlight reflection
                var highlight = Path()
                highlight.move(to: CGPoint(x: tx + 2, y: ty + 3))
                highlight.addLine(to: CGPoint(x: tx + tileW - 2, y: ty + 3))
                context.stroke(highlight, with: .color(Color.white.opacity(0.75)), lineWidth: 1.2)
            }
        }
    }
    
    // MARK: - 6. GARDEN MEADOW LAWN
    private func drawGardenLawn(context: GraphicsContext, size: CGSize) {
        // Lush green turf gradient
        let turfGradient = Gradient(colors: [
            Color(red: 0.22, green: 0.58, blue: 0.20),
            Color(red: 0.18, green: 0.48, blue: 0.16),
            Color(red: 0.25, green: 0.62, blue: 0.22)
        ])
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(turfGradient, startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)))
        
        // Procedural Grass Blades
        var gx: CGFloat = 12.0
        while gx < size.width {
            var gy: CGFloat = 12.0
            while gy < size.height {
                var blade = Path()
                blade.move(to: CGPoint(x: gx, y: gy))
                let bend = sin(Double(gx + gy) * 0.05) * 8.0
                blade.addQuadCurve(to: CGPoint(x: gx + CGFloat(bend), y: gy - 14.0), control: CGPoint(x: gx + CGFloat(bend * 0.5), y: gy - 7.0))
                let bladeColor = ((Int(gx) + Int(gy)) % 2 == 0)
                    ? Color(red: 0.35, green: 0.75, blue: 0.28).opacity(0.40)
                    : Color(red: 0.15, green: 0.42, blue: 0.12).opacity(0.35)
                context.stroke(blade, with: .color(bladeColor), lineWidth: 1.5)
                gy += 32.0
            }
            gx += 24.0
        }
        
        // Scattered Wild White & Yellow Meadow Daisies
        let flowers: [(CGFloat, CGFloat)] = [
            (size.width * 0.18, size.height * 0.25),
            (size.width * 0.82, size.height * 0.32),
            (size.width * 0.30, size.height * 0.78),
            (size.width * 0.74, size.height * 0.72),
            (size.width * 0.48, size.height * 0.42)
        ]
        for (fx, fy) in flowers {
            // 5 Petals
            for p in 0..<5 {
                let angle = Double(p) * (.pi * 2.0 / 5.0)
                let px = fx + CGFloat(cos(angle)) * 6.0
                let py = fy + CGFloat(sin(angle)) * 6.0
                var petal = Path()
                petal.addEllipse(in: CGRect(x: px - 3.5, y: py - 3.5, width: 7.0, height: 7.0))
                context.fill(petal, with: .color(Color.white.opacity(0.92)))
            }
            // Flower Center
            var centerDot = Path()
            centerDot.addEllipse(in: CGRect(x: fx - 3.0, y: fy - 3.0, width: 6.0, height: 6.0))
            context.fill(centerDot, with: .color(Color.yellow))
        }
    }
    
    // MARK: - 7. RETRO SYNTHWAVE ARCADE
    private func drawArcadeCabinet(context: GraphicsContext, size: CGSize) {
        // Deep starfield
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.05, green: 0.03, blue: 0.10)))
        
        // Twinkling stars
        for i in 0..<40 {
            let sx = CGFloat((i * 97) % Int(size.width))
            let sy = CGFloat((i * 131) % Int(size.height))
            var star = Path()
            star.addEllipse(in: CGRect(x: sx, y: sy, width: 2.0, height: 2.0))
            context.fill(star, with: .color(Color.white.opacity(0.65)))
        }
        
        // 80s Perspective grid lines converging towards horizon
        let horizonY = size.height * 0.35
        let linesCount = 14
        let bottomStep = size.width / CGFloat(linesCount)
        for i in 0...linesCount {
            let bx = CGFloat(i) * bottomStep
            var ray = Path()
            ray.move(to: CGPoint(x: size.width / 2.0, y: horizonY))
            ray.addLine(to: CGPoint(x: bx, y: size.height))
            context.stroke(ray, with: .color(Color(red: 0.85, green: 0.2, blue: 0.9).opacity(0.35)), lineWidth: 1.2)
        }
        
        // Horizontal grid rings
        var hy = horizonY + 12.0
        var step: CGFloat = 8.0
        while hy < size.height {
            var hLine = Path()
            hLine.move(to: CGPoint(x: 0, y: hy))
            hLine.addLine(to: CGPoint(x: size.width, y: hy))
            context.stroke(hLine, with: .color(Color(red: 0.0, green: 0.95, blue: 0.95).opacity(0.30)), lineWidth: 1.0)
            hy += step
            step += 6.0
        }
    }
    
    // MARK: - 8. ARTISAN BLUEPRINT WORKBENCH
    private func drawCraftWorkbench(context: GraphicsContext, size: CGSize) {
        // Self-healing hunter green cutting mat
        let matRect = CGRect(origin: .zero, size: size)
        context.fill(Path(matRect), with: .color(Color(red: 0.12, green: 0.32, blue: 0.22)))
        
        // Precision 20mm grid lines
        let step: CGFloat = 24.0
        var x: CGFloat = 0
        while x <= size.width {
            var vLine = Path()
            vLine.move(to: CGPoint(x: x, y: 0))
            vLine.addLine(to: CGPoint(x: x, y: size.height))
            let isMajor = Int(x) % Int(step * 5.0) == 0
            let alpha: Double = isMajor ? 0.35 : 0.15
            let width: CGFloat = isMajor ? 1.2 : 0.7
            context.stroke(vLine, with: .color(Color.white.opacity(alpha)), lineWidth: width)
            x += step
        }
        
        var y: CGFloat = 0
        while y <= size.height {
            var hLine = Path()
            hLine.move(to: CGPoint(x: 0, y: y))
            hLine.addLine(to: CGPoint(x: size.width, y: y))
            let isMajor = Int(y) % Int(step * 5.0) == 0
            let alpha: Double = isMajor ? 0.35 : 0.15
            let width: CGFloat = isMajor ? 1.2 : 0.7
            context.stroke(hLine, with: .color(Color.white.opacity(alpha)), lineWidth: width)
            y += step
        }
        
        // 45-degree angle cutting guides
        var angle45 = Path()
        angle45.move(to: CGPoint(x: 0, y: size.height * 0.75))
        angle45.addLine(to: CGPoint(x: size.width * 0.75, y: 0))
        context.stroke(angle45, with: .color(Color.yellow.opacity(0.30)), lineWidth: 1.2)
    }
    
    // MARK: - 9. ZEN BAMBOO TATAMI
    private func drawZenTatami(context: GraphicsContext, size: CGSize) {
        // Natural woven bamboo reed texture
        let tatamiBase = Color(red: 0.82, green: 0.72, blue: 0.48)
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(tatamiBase))
        
        // Fine parallel woven reed fibers
        var y: CGFloat = 0
        while y <= size.height {
            var reed = Path()
            reed.move(to: CGPoint(x: 0, y: y))
            reed.addLine(to: CGPoint(x: size.width, y: y))
            let shade = (Int(y) % 8 == 0)
                ? Color(red: 0.62, green: 0.52, blue: 0.32).opacity(0.35)
                : Color(red: 0.92, green: 0.84, blue: 0.62).opacity(0.30)
            context.stroke(reed, with: .color(shade), lineWidth: 1.2)
            y += 4.0
        }
        
        // Dark lacquered teak border bands on top and bottom
        let borderH: CGFloat = 16.0
        let darkTeak = Color(red: 0.22, green: 0.14, blue: 0.08)
        context.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: borderH)), with: .color(darkTeak))
        context.fill(Path(CGRect(x: 0, y: size.height - borderH, width: size.width, height: borderH)), with: .color(darkTeak))
    }
    
    // MARK: - 10. BUBBLEGUM CANDY DINER
    private func drawSweetCandy(context: GraphicsContext, size: CGSize) {
        // Pastel pink and mint striped vinyl
        let stripeW: CGFloat = 40.0
        let cols = Int(ceil(size.width / stripeW)) + 1
        let pink = Color(red: 0.96, green: 0.62, blue: 0.74)
        let mint = Color(red: 0.65, green: 0.90, blue: 0.82)
        
        for c in 0..<cols {
            let rx = CGFloat(c) * stripeW
            let rect = CGRect(x: rx, y: 0, width: stripeW, height: size.height)
            context.fill(Path(rect), with: .color(c % 2 == 0 ? pink : mint))
        }
        
        // Scattered Rainbow Sprinkles
        let sprinkles: [(CGFloat, CGFloat, Double, Color)] = [
            (0.15, 0.22, 0.4, Color.yellow),
            (0.32, 0.45, -0.6, Color.white),
            (0.68, 0.30, 0.8, Color.purple),
            (0.85, 0.70, -0.3, Color.orange),
            (0.42, 0.80, 0.2, Color.blue),
            (0.72, 0.85, 0.7, Color.yellow)
        ]
        for (rx, ry, rot, col) in sprinkles {
            let px = size.width * rx
            let py = size.height * ry
            var sprinkle = Path()
            sprinkle.addRoundedRect(in: CGRect(x: px - 6, y: py - 2, width: 12, height: 4), cornerSize: CGSize(width: 2, height: 2))
            var ctx = context
            ctx.translateBy(x: px, y: py)
            ctx.rotate(by: .radians(rot))
            ctx.translateBy(x: -px, y: -py)
            ctx.fill(sprinkle, with: .color(col.opacity(0.85)))
        }
    }
    
    // MARK: - 11. SPACE STARBASE BULKHEAD
    private func drawSpaceStarbase(context: GraphicsContext, size: CGSize) {
        // Titanium alloy bulkhead plates
        let alloyBase = Color(red: 0.12, green: 0.15, blue: 0.22)
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(alloyBase))
        
        // Metal panel seam lines
        let plateCols = 3
        let colW = size.width / CGFloat(plateCols)
        for c in 1..<plateCols {
            let px = CGFloat(c) * colW
            var seam = Path()
            seam.move(to: CGPoint(x: px, y: 0))
            seam.addLine(to: CGPoint(x: px, y: size.height))
            context.stroke(seam, with: .color(Color.black.opacity(0.85)), lineWidth: 2.0)
            
            // Rivet bolts along seam
            var ry: CGFloat = 20.0
            while ry < size.height {
                var rivet = Path()
                rivet.addEllipse(in: CGRect(x: px - 2.5, y: ry - 2.5, width: 5.0, height: 5.0))
                context.fill(rivet, with: .color(Color(red: 0.35, green: 0.45, blue: 0.60)))
                ry += 40.0
            }
        }
    }
    
    // MARK: - Dynamic Atmospheric Vignette Lighting
    private func themeVignette(theme: TableTheme, size: CGSize) -> some View {
        let colors: [Color]
        switch theme {
        case .classicPicnic, .gardenLawn, .espressoCafe:
            colors = [
                Color(red: 1.0, green: 0.95, blue: 0.70).opacity(0.16),
                Color(red: 0.90, green: 0.75, blue: 0.45).opacity(0.08),
                Color.black.opacity(0.35)
            ]
        case .midnightGlow:
            colors = [
                Color(red: 0.2, green: 0.85, blue: 0.65).opacity(0.08),
                Color(red: 0.1, green: 0.15, blue: 0.30).opacity(0.25),
                Color.black.opacity(0.70)
            ]
        case .cyberpunkNeon, .arcadeCabinet:
            colors = [
                Color(red: 0.0, green: 0.95, blue: 0.95).opacity(0.12),
                Color(red: 1.0, green: 0.15, blue: 0.65).opacity(0.10),
                Color.black.opacity(0.60)
            ]
        default:
            colors = [
                Color.white.opacity(0.10),
                Color.clear,
                Color.black.opacity(0.35)
            ]
        }
        
        return RadialGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startRadius: size.width * 0.2,
            endRadius: size.width * 0.95
        )
        .blendMode(.multiply)
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

/// Procedural Pastel Diner Runner for Candy Shop
struct CandyDinerRunnerView: View {
    var body: some View {
        Canvas { context, size in
            let shadowRect = CGRect(x: 3, y: 0, width: size.width, height: size.height)
            context.fill(Path(shadowRect), with: .color(Color.black.opacity(0.2)))
            
            let runnerRect = CGRect(origin: .zero, size: size)
            context.fill(Path(runnerRect), with: .color(Color.white.opacity(0.92)))
            
            // Cute scalloped edge
            var scallop = Path()
            var y: CGFloat = 0
            while y < size.height {
                scallop.addQuadCurve(to: CGPoint(x: size.width, y: y + 16), control: CGPoint(x: size.width + 8, y: y + 8))
                y += 16
            }
            context.fill(scallop, with: .color(Color.white.opacity(0.92)))
        }
    }
}
