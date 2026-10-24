import SwiftUI

/// Appearance style modes for the Smash it! Glassmorphic App Icon
public enum GlassIconAppearance: String, CaseIterable, Identifiable {
    case automatic = "Adaptive"
    case light = "Crystal (Light)"
    case dark = "Obsidian (Dark)"
    case tinted = "Monochrome (Tinted)"
    
    public var id: String { rawValue }
}

/// A high-fidelity, interactive Glassmorphic App Icon view for Smash it!
/// Implements frosted acrylic / smoked obsidian physical glass substrates,
/// multi-layer specular reflections, dynamic iOS 18 light/dark/tinted adaptation,
/// ambient rim illumination, and responsive 3D tilt physics.
public struct SmashItGlassIconView: View {
    public let size: CGFloat
    public let appearanceOverride: GlassIconAppearance?
    public let showGlow: Bool
    public let interactive: Bool
    public let onTap: (() -> Void)?
    
    @Environment(\.colorScheme) private var systemColorScheme
    
    // Dynamic interaction & physics states
    @State private var isPressed: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var sheenPhase: CGFloat = -1.2
    @State private var ambientBreathing: Bool = false
    
    public init(
        size: CGFloat = 84,
        appearanceOverride: GlassIconAppearance? = nil,
        showGlow: Bool = true,
        interactive: Bool = true,
        onTap: (() -> Void)? = nil
    ) {
        self.size = size
        self.appearanceOverride = appearanceOverride
        self.showGlow = showGlow
        self.interactive = interactive
        self.onTap = onTap
    }
    
    // Effective active appearance
    private var isDarkMode: Bool {
        switch appearanceOverride {
        case .dark:
            return true
        case .light:
            return false
        case .tinted:
            return true
        case .automatic, .none:
            return systemColorScheme == .dark
        }
    }
    
    private var isTinted: Bool {
        appearanceOverride == .tinted
    }
    
    private var cornerRadius: CGFloat {
        // Standard Apple iOS App Icon squircle curvature ratio: ~22.5% of dimension
        size * 0.225
    }
    
    public var body: some View {
        ZStack {
            // 1. AMBIENT BACKLIGHT BLOOM
            if showGlow {
                ambientGlowLayer
            }
            
            // 2. MAIN GLASSMORPHIC ICON SQUIRCLE
            ZStack {
                // A. Base Glass Substrate
                glassSubstrateBackground
                
                // B. Core App Icon Artwork
                iconArtworkLayer
                
                // C. Diagonal Specular Glass Reflection
                glassReflectionSheenLayer
                
                // D. Beveled Glass Rim & Inner Light Refraction
                glassRimBevelLayer
                
                // E. Animated Sweeping Specular Flash
                sweepingSheenFlashLayer
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: isDarkMode ? Color.black.opacity(0.65) : Color.black.opacity(0.22),
                radius: size * 0.12,
                x: 0,
                y: size * 0.08
            )
            // 3D Parallax & Gesture Response
            .rotation3DEffect(
                .degrees(interactive ? Double(dragOffset.height * 0.15) : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(interactive ? Double(-dragOffset.width * 0.15) : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(isPressed ? 0.94 : (interactive && dragOffset != .zero ? 1.04 : 1.0))
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: dragOffset)
        }
        .contentShape(Rectangle())
        .gesture(
            interactive ?
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    withAnimation(.easeOut(duration: 0.1)) {
                        let translation = value.translation
                        dragOffset = CGSize(
                            width: min(max(translation.width, -30), 30),
                            height: min(max(translation.height, -30), 30)
                        )
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                        dragOffset = .zero
                        isPressed = false
                    }
                    onTap?()
                    triggerIconSheen()
                }
            : nil
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                ambientBreathing = true
            }
        }
    }
    
    // MARK: - Layer Components
    
    /// Ambient glow radiating behind the glass icon
    private var ambientGlowLayer: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: isTinted
                        ? [Color.white.opacity(0.35), Color.clear]
                        : (isDarkMode
                            ? [Color(red: 1.0, green: 0.15, blue: 0.35).opacity(ambientBreathing ? 0.55 : 0.35),
                               Color(red: 1.0, green: 0.05, blue: 0.2).opacity(0.18),
                               Color.clear]
                            : [Color(red: 0.85, green: 0.92, blue: 1.0).opacity(ambientBreathing ? 0.7 : 0.45),
                               Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.2),
                               Color.clear])
                    ,
                    center: .center,
                    startRadius: size * 0.1,
                    endRadius: size * 0.85
                )
            )
            .frame(width: size * 1.6, height: size * 1.6)
            .blur(radius: size * 0.2)
    }
    
    /// Glass substrate background with frosted blur and directional gradient
    private var glassSubstrateBackground: some View {
        ZStack {
            if isTinted {
                Color.black
                LinearGradient(
                    colors: [Color(white: 0.3), Color(white: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else if isDarkMode {
                // Smoked Obsidian Glass
                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.11, blue: 0.16),
                        Color(red: 0.04, green: 0.05, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Deep Crimson Neon Backlight Core
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.12, blue: 0.28).opacity(0.42),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.48, y: 0.54),
                    startRadius: 0,
                    endRadius: size * 0.48
                )
            } else {
                // Frosted Crystal Acrylic
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.93, green: 0.96, blue: 0.99),
                        Color(red: 0.86, green: 0.91, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Diffuse central backlight
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.85),
                        Color.white.opacity(0.0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.45
                )
            }
        }
    }
    
    /// The core icon artwork loaded from asset catalog or clean fallback
    private var iconArtworkLayer: some View {
        Group {
            if isTinted {
                Image("SmashItLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorMultiply(.white)
                    .grayscale(1.0)
                    .contrast(1.2)
            } else if isDarkMode {
                Image("SmashItLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contrast(1.08)
                    .saturation(1.1)
            } else {
                Image("SmashItLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: size, height: size)
    }
    
    /// Curving specular reflection sheen across top half of glass
    private var glassReflectionSheenLayer: some View {
        GeometryReader { _ in
            Path { path in
                let w = size
                let h = size
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h * 0.38))
                path.addCurve(
                    to: CGPoint(x: 0, y: h * 0.62),
                    control1: CGPoint(x: w * 0.55, y: h * 0.54),
                    control2: CGPoint(x: w * 0.25, y: h * 0.62)
                )
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(isDarkMode ? 0.22 : 0.45),
                        Color.white.opacity(isDarkMode ? 0.05 : 0.12),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    /// Double-beveled precision glass rim with light bounce
    private var glassRimBevelLayer: some View {
        ZStack {
            // Outer bright specular edge
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: isDarkMode ? [
                            Color.white.opacity(0.55),
                            Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.3),
                            Color(red: 1.0, green: 0.2, blue: 0.35).opacity(0.35),
                            Color.black.opacity(0.7)
                        ] : [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.65),
                            Color(red: 0.6, green: 0.75, blue: 0.9).opacity(0.35),
                            Color(red: 0.4, green: 0.5, blue: 0.7).opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(1.5, size * 0.02)
                )
            
            // Inner refractive glass groove
            RoundedRectangle(cornerRadius: max(2, cornerRadius - 2), style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isDarkMode ? 0.3 : 0.5),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    ),
                    lineWidth: max(1.0, size * 0.012)
                )
                .padding(max(1.5, size * 0.02))
        }
    }
    
    /// Dynamic sweeping sheen glint that traverses across the icon
    private var sweepingSheenFlashLayer: some View {
        GeometryReader { geo in
            let w = geo.size.width
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(isDarkMode ? 0.25 : 0.45),
                            Color.white.opacity(isDarkMode ? 0.45 : 0.75),
                            Color.white.opacity(isDarkMode ? 0.25 : 0.45),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: w * 0.35)
                .rotationEffect(.degrees(28))
                .offset(x: sheenPhase * w)
        }
    }
    
    private func triggerIconSheen() {
        sheenPhase = -1.2
        withAnimation(.easeInOut(duration: 0.75)) {
            sheenPhase = 2.2
        }
    }
}

// MARK: - Dedicated Glass Icon Interactive Inspector Card
/// An interactive showcase preview widget allowing players to inspect all 3 appearance modes
public struct SmashItGlassIconShowcaseView: View {
    @State private var selectedAppearance: GlassIconAppearance = .automatic
    @State private var bounceKey: Int = 0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "square.fill.text.grid.1x2")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14, weight: .bold))
                
                Text("APP ICON & GLASSMORPHISM")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                
                Spacer()
                
                Text("IPHONE DUO")
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.yellow.opacity(0.18))
                    .foregroundColor(.yellow)
                    .cornerRadius(4)
            }
            
            // Central Glass Icon Display
            HStack(spacing: 24) {
                Spacer()
                
                SmashItGlassIconView(
                    size: 110,
                    appearanceOverride: selectedAppearance,
                    showGlow: true,
                    interactive: true
                )
                .id(bounceKey)
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            // Interactive Mode Picker
            HStack(spacing: 6) {
                ForEach(GlassIconAppearance.allCases) { mode in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedAppearance = mode
                            bounceKey += 1
                        }
                    }) {
                        Text(mode.rawValue.components(separatedBy: " ").first ?? mode.rawValue)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                selectedAppearance == mode
                                    ? Color.yellow
                                    : Color.white.opacity(0.08)
                            )
                            .foregroundColor(
                                selectedAppearance == mode ? .black : .white.opacity(0.7)
                            )
                            .cornerRadius(6)
                    }
                }
            }
            
            Text("Tap or drag the icon for 3D glass refraction and specular shine.")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.12, green: 0.14, blue: 0.20))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}
