import SwiftUI

/// Procedural Sprite for all insect species:
/// Housefly, Mosquito, Mutant Horsefly, and The Wasp.
/// Features 6 jointed spiky legs, segmented thorax, compound eyes,
/// 60Hz oscillating translucent wings (folds on landing),
/// animated leg-rubbing, and dynamic 3D altitude flight shadow.
public struct InsectSpriteView: View {
    public let insect: ActiveInsect
    public var globalScale: CGFloat = 1.0
    
    public init(insect: ActiveInsect, globalScale: CGFloat = 1.0) {
        self.insect = insect
        self.globalScale = globalScale
    }
    
    public var body: some View {
        let isLanded = insect.state == .landed
        let altitude = insect.altitude // 1.0 (high) to 0.0 (landed)
        let speciesScale = insect.type.baseScale * globalScale
        
        ZStack {
            // 1. FLIGHT SHADOW (3D Depth Illusion & Landing Cue)
            // When high: offset by 40pt, larger (1.35x), lighter (opacity 0.22), blurred.
            // When landed: snaps directly underneath body (offset 0), smaller (1.0x), dark & crisp (opacity 0.70)!
            let shadowOffsetX: CGFloat = CGFloat(altitude) * 22.0
            let shadowOffsetY: CGFloat = CGFloat(altitude) * 38.0
            let shadowScale: CGFloat = 1.0 + CGFloat(altitude) * 0.35
            let shadowOpacity: Double = 0.68 - Double(altitude) * 0.45
            let shadowBlur: CGFloat = CGFloat(altitude) * 6.5
            
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                var shadowPath = Path()
                let w: CGFloat = 28 * speciesScale * shadowScale
                let h: CGFloat = 42 * speciesScale * shadowScale
                shadowPath.addEllipse(in: CGRect(x: center.x - w/2, y: center.y - h/2, width: w, height: h))
                context.fill(shadowPath, with: .color(Color.black.opacity(shadowOpacity)))
            }
            .frame(width: 80 * speciesScale, height: 90 * speciesScale)
            .blur(radius: shadowBlur)
            .offset(x: shadowOffsetX, y: shadowOffsetY)
            .rotationEffect(.radians(insect.headingAngle))
            
            // 2. PROCEDURAL INSECT BODY & WINGS
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                switch insect.type {
                case .housefly:
                    drawHousefly(context: context, center: center, insect: insect, isLanded: isLanded)
                case .mosquito:
                    drawMosquito(context: context, center: center, insect: insect, isLanded: isLanded)
                case .mutantHorsefly:
                    drawMutantHorsefly(context: context, center: center, insect: insect, isLanded: isLanded)
                case .wasp:
                    drawWasp(context: context, center: center, insect: insect, isLanded: isLanded)
                }
            }
            .frame(width: 80 * speciesScale, height: 90 * speciesScale)
            .rotationEffect(.radians(insect.headingAngle))
            
            // Boss Health Bar for Mutant Horsefly
            if insect.type == .mutantHorsefly && insect.health > 0 {
                VStack(spacing: 2) {
                    Text("BOSS: 2 CLAPS NEEDED")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 2)
                    
                    HStack(spacing: 3) {
                        ForEach(0..<insect.maxHealth, id: \.self) { idx in
                            Rectangle()
                                .fill(idx < insect.health ? Color.red : Color.gray.opacity(0.5))
                                .frame(width: 22, height: 5)
                                .cornerRadius(2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 0.8)
                                )
                        }
                    }
                }
                .offset(y: -55 * speciesScale)
            }
        }
    }
    
    // MARK: - 1. HOUSEFLY RENDERER
    private func drawHousefly(context: GraphicsContext, center: CGPoint, insect: ActiveInsect, isLanded: Bool) {
        let flutter = sin(insect.wingFlutterPhase)
        let legRub = sin(insect.legRubPhase)
        
        // 6 Jointed Spiky Legs
        drawJointedLegs(
            context: context,
            center: center,
            bodyWidth: 14,
            bodyLength: 22,
            isLanded: isLanded,
            legRubOffset: legRub,
            legColor: Color(red: 0.12, green: 0.12, blue: 0.14)
        )
        
        // Segmented Abdomen (dark metallic blue-black with iridescent sheen)
        var abdomenPath = Path()
        let abdomenRect = CGRect(x: center.x - 9, y: center.y - 4, width: 18, height: 26)
        abdomenPath.addEllipse(in: abdomenRect)
        
        let abdomenGradient = Gradient(colors: [
            Color(red: 0.08, green: 0.20, blue: 0.28), // Deep iridescent navy
            Color(red: 0.12, green: 0.35, blue: 0.24), // Sheen green
            Color(red: 0.05, green: 0.08, blue: 0.10)  // Chitin black
        ])
        context.fill(abdomenPath, with: .linearGradient(abdomenGradient, startPoint: CGPoint(x: center.x - 9, y: center.y), endPoint: CGPoint(x: center.x + 9, y: center.y + 20)))
        
        // Abdomen Segment Stripes
        for s in 1...3 {
            let segY = center.y + CGFloat(s * 6)
            var segLine = Path()
            segLine.move(to: CGPoint(x: center.x - 7, y: segY))
            segLine.addQuadCurve(to: CGPoint(x: center.x + 7, y: segY), control: CGPoint(x: center.x, y: segY + 2))
            context.stroke(segLine, with: .color(Color.black.opacity(0.55)), lineWidth: 1.0)
        }
        
        // Thorax
        var thoraxPath = Path()
        let thoraxRect = CGRect(x: center.x - 8, y: center.y - 16, width: 16, height: 16)
        thoraxPath.addEllipse(in: thoraxRect)
        let thoraxGradient = Gradient(colors: [
            Color(red: 0.15, green: 0.25, blue: 0.22),
            Color(red: 0.06, green: 0.10, blue: 0.12)
        ])
        context.fill(thoraxPath, with: .linearGradient(thoraxGradient, startPoint: CGPoint(x: center.x, y: center.y - 16), endPoint: CGPoint(x: center.x, y: center.y)))
        
        // Thorax bristles/stripes
        for b in -1...1 {
            var bristle = Path()
            let bx = center.x + CGFloat(b * 4)
            bristle.move(to: CGPoint(x: bx, y: center.y - 14))
            bristle.addLine(to: CGPoint(x: bx, y: center.y - 2))
            context.stroke(bristle, with: .color(Color.black.opacity(0.4)), lineWidth: 1.2)
        }
        
        // Head
        var headPath = Path()
        headPath.addEllipse(in: CGRect(x: center.x - 7, y: center.y - 24, width: 14, height: 11))
        context.fill(headPath, with: .color(Color(red: 0.08, green: 0.08, blue: 0.09)))
        
        // Bright Compound Red Eyes
        let leftEyeRect = CGRect(x: center.x - 8, y: center.y - 24, width: 7, height: 8)
        let rightEyeRect = CGRect(x: center.x + 1, y: center.y - 24, width: 7, height: 8)
        
        let eyeGradient = Gradient(colors: [
            Color(red: 0.95, green: 0.12, blue: 0.15),
            Color(red: 0.55, green: 0.02, blue: 0.05)
        ])
        context.fill(Path(ellipseIn: leftEyeRect), with: .radialGradient(eyeGradient, center: CGPoint(x: leftEyeRect.midX, y: leftEyeRect.midY), startRadius: 1, endRadius: 5))
        context.fill(Path(ellipseIn: rightEyeRect), with: .radialGradient(eyeGradient, center: CGPoint(x: rightEyeRect.midX, y: rightEyeRect.midY), startRadius: 1, endRadius: 5))
        
        // Eye Specular Glints
        context.fill(Path(ellipseIn: CGRect(x: leftEyeRect.minX + 2, y: leftEyeRect.minY + 2, width: 2, height: 2)), with: .color(Color.white.opacity(0.9)))
        context.fill(Path(ellipseIn: CGRect(x: rightEyeRect.minX + 3, y: rightEyeRect.minY + 2, width: 2, height: 2)), with: .color(Color.white.opacity(0.9)))
        
        // Wings (Translucent Iridescent Teardrops)
        drawWings(
            context: context,
            center: center,
            thoraxAttachY: center.y - 8,
            flutter: flutter,
            isLanded: isLanded,
            wingLength: 30,
            wingWidth: 12
        )
    }
    
    // MARK: - 2. MOSQUITO RENDERER
    private func drawMosquito(context: GraphicsContext, center: CGPoint, insect: ActiveInsect, isLanded: Bool) {
        let flutter = sin(insect.wingFlutterPhase)
        
        // Long spindly legs
        drawJointedLegs(
            context: context,
            center: center,
            bodyWidth: 8,
            bodyLength: 28,
            isLanded: isLanded,
            legRubOffset: 0,
            legColor: Color(red: 0.25, green: 0.22, blue: 0.18),
            legLengthMultiplier: 1.6
        )
        
        // Slender striped abdomen
        var abdomen = Path()
        abdomen.addRoundedRect(in: CGRect(x: center.x - 3.5, y: center.y - 2, width: 7, height: 30), cornerSize: CGSize(width: 3.5, height: 3.5))
        context.fill(abdomen, with: .color(Color(red: 0.28, green: 0.24, blue: 0.18)))
        
        // Mosquito stripes
        for s in 1...5 {
            let sy = center.y + CGFloat(s * 5)
            context.fill(Path(CGRect(x: center.x - 3.5, y: sy, width: 7, height: 1.5)), with: .color(Color(red: 0.75, green: 0.70, blue: 0.60)))
        }
        
        // Small Thorax
        context.fill(Path(ellipseIn: CGRect(x: center.x - 4.5, y: center.y - 12, width: 9, height: 11)), with: .color(Color(red: 0.22, green: 0.18, blue: 0.14)))
        
        // Head & Needle Proboscis
        context.fill(Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 18, width: 6, height: 6)), with: .color(Color(red: 0.15, green: 0.12, blue: 0.10)))
        
        var proboscis = Path()
        proboscis.move(to: CGPoint(x: center.x, y: center.y - 18))
        proboscis.addLine(to: CGPoint(x: center.x, y: center.y - 32))
        context.stroke(proboscis, with: .color(Color(red: 0.10, green: 0.08, blue: 0.06)), lineWidth: 1.2)
        
        // Antennae
        var antL = Path()
        antL.move(to: CGPoint(x: center.x - 2, y: center.y - 17))
        antL.addLine(to: CGPoint(x: center.x - 6, y: center.y - 26))
        context.stroke(antL, with: .color(Color.gray), lineWidth: 0.8)
        
        var antR = Path()
        antR.move(to: CGPoint(x: center.x + 2, y: center.y - 17))
        antR.addLine(to: CGPoint(x: center.x + 6, y: center.y - 26))
        context.stroke(antR, with: .color(Color.gray), lineWidth: 0.8)
        
        // Delicate slender wings
        drawWings(
            context: context,
            center: center,
            thoraxAttachY: center.y - 7,
            flutter: flutter,
            isLanded: isLanded,
            wingLength: 26,
            wingWidth: 7
        )
    }
    
    // MARK: - 3. MUTANT HORSEFLY (BOSS)
    private func drawMutantHorsefly(context: GraphicsContext, center: CGPoint, insect: ActiveInsect, isLanded: Bool) {
        let flutter = sin(insect.wingFlutterPhase)
        let legRub = sin(insect.legRubPhase)
        
        // Barbed heavy legs
        drawJointedLegs(
            context: context,
            center: center,
            bodyWidth: 18,
            bodyLength: 28,
            isLanded: isLanded,
            legRubOffset: legRub,
            legColor: Color(red: 0.18, green: 0.10, blue: 0.05),
            legLengthMultiplier: 1.3
        )
        
        // Armored Abdomen (Iridescent Bronze/Purple Chitin)
        var abdomen = Path()
        abdomen.addEllipse(in: CGRect(x: center.x - 14, y: center.y - 5, width: 28, height: 35))
        let armorGradient = Gradient(colors: [
            Color(red: 0.35, green: 0.15, blue: 0.32), // Purple sheen
            Color(red: 0.45, green: 0.28, blue: 0.12), // Bronze chitin
            Color(red: 0.12, green: 0.08, blue: 0.06)
        ])
        context.fill(abdomen, with: .linearGradient(armorGradient, startPoint: CGPoint(x: center.x - 14, y: center.y), endPoint: CGPoint(x: center.x + 14, y: center.y + 25)))
        
        // Heavy Thorax
        var thorax = Path()
        thorax.addEllipse(in: CGRect(x: center.x - 13, y: center.y - 20, width: 26, height: 20))
        context.fill(thorax, with: .color(Color(red: 0.20, green: 0.16, blue: 0.12)))
        
        // Head & Glowing Faceted Yellow/Green Eyes
        context.fill(Path(ellipseIn: CGRect(x: center.x - 11, y: center.y - 30, width: 22, height: 13)), with: .color(Color.black))
        
        let eyeL = CGRect(x: center.x - 12, y: center.y - 31, width: 10, height: 11)
        let eyeR = CGRect(x: center.x + 2, y: center.y - 31, width: 10, height: 11)
        let bossEyeGrad = Gradient(colors: [Color.yellow, Color.orange, Color.red])
        context.fill(Path(ellipseIn: eyeL), with: .radialGradient(bossEyeGrad, center: CGPoint(x: eyeL.midX, y: eyeL.midY), startRadius: 1, endRadius: 7))
        context.fill(Path(ellipseIn: eyeR), with: .radialGradient(bossEyeGrad, center: CGPoint(x: eyeR.midX, y: eyeR.midY), startRadius: 1, endRadius: 7))
        
        // Giant wings
        drawWings(
            context: context,
            center: center,
            thoraxAttachY: center.y - 10,
            flutter: flutter,
            isLanded: isLanded,
            wingLength: 38,
            wingWidth: 15
        )
    }
    
    // MARK: - 4. THE WASP (TRAP ENEMY - DO NOT CLAP!)
    private func drawWasp(context: GraphicsContext, center: CGPoint, insect: ActiveInsect, isLanded: Bool) {
        let flutter = sin(insect.wingFlutterPhase)
        
        // Wasp jointed legs
        drawJointedLegs(
            context: context,
            center: center,
            bodyWidth: 12,
            bodyLength: 26,
            isLanded: isLanded,
            legRubOffset: 0,
            legColor: Color(red: 0.95, green: 0.80, blue: 0.10) // Yellow banded legs
        )
        
        // Pointed Stinger Abdomen with vivid black and yellow stripes!
        var abdomen = Path()
        abdomen.move(to: CGPoint(x: center.x, y: center.y + 36)) // Sharp stinger tip
        abdomen.addQuadCurve(to: CGPoint(x: center.x - 10, y: center.y + 12), control: CGPoint(x: center.x - 12, y: center.y + 28))
        abdomen.addLine(to: CGPoint(x: center.x - 4, y: center.y + 3)) // Pinched wasp waist
        abdomen.addLine(to: CGPoint(x: center.x + 4, y: center.y + 3))
        abdomen.addLine(to: CGPoint(x: center.x + 10, y: center.y + 12))
        abdomen.addQuadCurve(to: CGPoint(x: center.x, y: center.y + 36), control: CGPoint(x: center.x + 12, y: center.y + 28))
        abdomen.closeSubpath()
        context.fill(abdomen, with: .color(Color(red: 0.98, green: 0.85, blue: 0.05))) // Bright Warning Yellow
        
        // Black warning stripes across abdomen
        let stripeCount = 4
        for s in 0..<stripeCount {
            let sy = center.y + 8.0 + CGFloat(s) * 7.0
            let stripeOffset = CGFloat(s) * 1.5
            let stripeWidth = 18.0 - CGFloat(s) * 3.0
            let stripeX = center.x - 9.0 + stripeOffset
            let stripeRect = CGRect(x: stripeX, y: sy, width: stripeWidth, height: 3.5)
            
            var stripe = Path()
            stripe.addRoundedRect(in: stripeRect, cornerSize: CGSize(width: 1, height: 1))
            context.fill(stripe, with: .color(Color.black))
        }
        
        // Needle Stinger Tip
        var stinger = Path()
        stinger.move(to: CGPoint(x: center.x, y: center.y + 35))
        stinger.addLine(to: CGPoint(x: center.x, y: center.y + 40))
        context.stroke(stinger, with: .color(Color.black), lineWidth: 1.5)
        
        // Thorax (Black with yellow shoulder dots)
        var thorax = Path()
        thorax.addEllipse(in: CGRect(x: center.x - 8, y: center.y - 12, width: 16, height: 14))
        context.fill(thorax, with: .color(Color(red: 0.10, green: 0.10, blue: 0.10)))
        
        // Yellow shoulder markings
        context.fill(Path(ellipseIn: CGRect(x: center.x - 7, y: center.y - 10, width: 3, height: 5)), with: .color(Color.yellow))
        context.fill(Path(ellipseIn: CGRect(x: center.x + 4, y: center.y - 10, width: 3, height: 5)), with: .color(Color.yellow))
        
        // Head with large black eyes and antennae
        context.fill(Path(ellipseIn: CGRect(x: center.x - 7, y: center.y - 20, width: 14, height: 10)), with: .color(Color.black))
        
        // Distinct Wasp Antennae
        var antL = Path()
        antL.move(to: CGPoint(x: center.x - 3, y: center.y - 19))
        antL.addQuadCurve(to: CGPoint(x: center.x - 12, y: center.y - 30), control: CGPoint(x: center.x - 10, y: center.y - 23))
        context.stroke(antL, with: .color(Color.black), lineWidth: 1.5)
        
        var antR = Path()
        antR.move(to: CGPoint(x: center.x + 3, y: center.y - 19))
        antR.addQuadCurve(to: CGPoint(x: center.x + 12, y: center.y - 30), control: CGPoint(x: center.x + 10, y: center.y - 23))
        context.stroke(antR, with: .color(Color.black), lineWidth: 1.5)
        
        // Wings
        drawWings(
            context: context,
            center: center,
            thoraxAttachY: center.y - 6,
            flutter: flutter,
            isLanded: isLanded,
            wingLength: 32,
            wingWidth: 9
        )
    }
    
    // MARK: - SHARED PROCEDURAL JOINTED LEGS & LEG RUBBING
    private func drawJointedLegs(
        context: GraphicsContext,
        center: CGPoint,
        bodyWidth: CGFloat,
        bodyLength: CGFloat,
        isLanded: Bool,
        legRubOffset: Double,
        legColor: Color,
        legLengthMultiplier: CGFloat = 1.0
    ) {
        let halfW = bodyWidth * 0.5
        
        // 3 pairs of legs: Front, Middle, Back
        
        // 1. FRONT LEGS (Animated leg-rubbing when landed!)
        var frontL = Path()
        let frontLOrigin = CGPoint(x: center.x - halfW, y: center.y - 12)
        frontL.move(to: frontLOrigin)
        if isLanded {
            // Front legs rubbing together!
            let rubX = CGFloat(legRubOffset) * 2.5
            let knee = CGPoint(x: center.x - halfW - 8 * legLengthMultiplier, y: center.y - 18)
            let tip = CGPoint(x: center.x - 2 + rubX, y: center.y - 26)
            frontL.addLine(to: knee)
            frontL.addLine(to: tip)
        } else {
            let knee = CGPoint(x: center.x - halfW - 10 * legLengthMultiplier, y: center.y - 20)
            let tip = CGPoint(x: center.x - halfW - 6 * legLengthMultiplier, y: center.y - 28)
            frontL.addLine(to: knee)
            frontL.addLine(to: tip)
        }
        context.stroke(frontL, with: .color(legColor), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
        
        var frontR = Path()
        let frontROrigin = CGPoint(x: center.x + halfW, y: center.y - 12)
        frontR.move(to: frontROrigin)
        if isLanded {
            let rubX = CGFloat(legRubOffset) * 2.5
            let knee = CGPoint(x: center.x + halfW + 8 * legLengthMultiplier, y: center.y - 18)
            let tip = CGPoint(x: center.x + 2 + rubX, y: center.y - 26)
            frontR.addLine(to: knee)
            frontR.addLine(to: tip)
        } else {
            let knee = CGPoint(x: center.x + halfW + 10 * legLengthMultiplier, y: center.y - 20)
            let tip = CGPoint(x: center.x + halfW + 6 * legLengthMultiplier, y: center.y - 28)
            frontR.addLine(to: knee)
            frontR.addLine(to: tip)
        }
        context.stroke(frontR, with: .color(legColor), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
        
        // 2. MIDDLE LEGS
        var midL = Path()
        midL.move(to: CGPoint(x: center.x - halfW, y: center.y - 4))
        midL.addLine(to: CGPoint(x: center.x - halfW - 14 * legLengthMultiplier, y: center.y - 6))
        midL.addLine(to: CGPoint(x: center.x - halfW - 18 * legLengthMultiplier, y: center.y + 4))
        context.stroke(midL, with: .color(legColor), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
        
        var midR = Path()
        midR.move(to: CGPoint(x: center.x + halfW, y: center.y - 4))
        midR.addLine(to: CGPoint(x: center.x + halfW + 14 * legLengthMultiplier, y: center.y - 6))
        midR.addLine(to: CGPoint(x: center.x + halfW + 18 * legLengthMultiplier, y: center.y + 4))
        context.stroke(midR, with: .color(legColor), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
        
        // 3. BACK LEGS
        var backL = Path()
        backL.move(to: CGPoint(x: center.x - halfW + 2, y: center.y + 6))
        backL.addLine(to: CGPoint(x: center.x - halfW - 12 * legLengthMultiplier, y: center.y + 16))
        backL.addLine(to: CGPoint(x: center.x - halfW - 16 * legLengthMultiplier, y: center.y + 30))
        context.stroke(backL, with: .color(legColor), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
        
        var backR = Path()
        backR.move(to: CGPoint(x: center.x + halfW - 2, y: center.y + 6))
        backR.addLine(to: CGPoint(x: center.x + halfW + 12 * legLengthMultiplier, y: center.y + 16))
        backR.addLine(to: CGPoint(x: center.x + halfW + 16 * legLengthMultiplier, y: center.y + 30))
        context.stroke(backR, with: .color(legColor), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
    }
    
    // MARK: - SHARED PROCEDURAL WINGS & OSCILLATION
    private func drawWings(
        context: GraphicsContext,
        center: CGPoint,
        thoraxAttachY: CGFloat,
        flutter: Double,
        isLanded: Bool,
        wingLength: CGFloat,
        wingWidth: CGFloat
    ) {
        // When flying: wings oscillate rapidly back and forth (flutter angle ~ 35 degrees)
        // When landed: wings fold back neatly over the abdomen (angle ~ 10 degrees)
        let baseAngle: Double = isLanded ? 12.0 : 42.0
        let flutterRange: Double = isLanded ? 0.0 : 36.0 * flutter
        
        let leftWingAngle = (-baseAngle + flutterRange) * .pi / 180.0
        let rightWingAngle = (baseAngle - flutterRange) * .pi / 180.0
        
        // Wing Iridescent Shading Gradient
        let wingGradient = Gradient(colors: [
            Color.white.opacity(0.85),
            Color(red: 0.85, green: 0.95, blue: 1.0).opacity(0.65),
            Color(red: 0.95, green: 0.85, blue: 0.98).opacity(0.50),
            Color.white.opacity(0.35)
        ])
        
        // Left Wing
        var leftContext = context
        leftContext.translateBy(x: center.x - 3, y: thoraxAttachY)
        leftContext.rotate(by: .radians(leftWingAngle))
        
        var leftWingPath = Path()
        leftWingPath.move(to: .zero)
        leftWingPath.addQuadCurve(to: CGPoint(x: -wingWidth * 0.5, y: wingLength), control: CGPoint(x: -wingWidth * 1.1, y: wingLength * 0.55))
        leftWingPath.addQuadCurve(to: .zero, control: CGPoint(x: wingWidth * 0.3, y: wingLength * 0.6))
        leftWingPath.closeSubpath()
        
        leftContext.fill(leftWingPath, with: .linearGradient(wingGradient, startPoint: .zero, endPoint: CGPoint(x: -wingWidth, y: wingLength)))
        leftContext.stroke(leftWingPath, with: .color(Color.black.opacity(0.3)), lineWidth: 0.8)
        
        // Delicate wing veins
        var leftVeins = Path()
        leftVeins.move(to: .zero)
        leftVeins.addLine(to: CGPoint(x: -wingWidth * 0.4, y: wingLength * 0.75))
        leftVeins.move(to: CGPoint(x: -wingWidth * 0.2, y: wingLength * 0.35))
        leftVeins.addLine(to: CGPoint(x: -wingWidth * 0.7, y: wingLength * 0.55))
        leftContext.stroke(leftVeins, with: .color(Color.black.opacity(0.2)), lineWidth: 0.6)
        
        // Right Wing
        var rightContext = context
        rightContext.translateBy(x: center.x + 3, y: thoraxAttachY)
        rightContext.rotate(by: .radians(rightWingAngle))
        
        var rightWingPath = Path()
        rightWingPath.move(to: .zero)
        rightWingPath.addQuadCurve(to: CGPoint(x: wingWidth * 0.5, y: wingLength), control: CGPoint(x: wingWidth * 1.1, y: wingLength * 0.55))
        rightWingPath.addQuadCurve(to: .zero, control: CGPoint(x: -wingWidth * 0.3, y: wingLength * 0.6))
        rightWingPath.closeSubpath()
        
        rightContext.fill(rightWingPath, with: .linearGradient(wingGradient, startPoint: .zero, endPoint: CGPoint(x: wingWidth, y: wingLength)))
        rightContext.stroke(rightWingPath, with: .color(Color.black.opacity(0.3)), lineWidth: 0.8)
        
        var rightVeins = Path()
        rightVeins.move(to: .zero)
        rightVeins.addLine(to: CGPoint(x: wingWidth * 0.4, y: wingLength * 0.75))
        rightVeins.move(to: CGPoint(x: wingWidth * 0.2, y: wingLength * 0.35))
        rightVeins.addLine(to: CGPoint(x: wingWidth * 0.7, y: wingLength * 0.55))
        rightContext.stroke(rightVeins, with: .color(Color.black.opacity(0.2)), lineWidth: 0.6)
    }
}
