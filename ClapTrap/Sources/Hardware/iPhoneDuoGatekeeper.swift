import SwiftUI
import Combine
import Darwin

/// Hardware and App Store Distribution Gatekeeper for iPhone Duo Exclusivity.
/// Ensures that Smash it! is exclusively downloadable and playable on the foldable iPhone Duo (iPhone19,4).
public final class iPhoneDuoGatekeeper: ObservableObject {
    public static let shared = iPhoneDuoGatekeeper()
    
    /// Target hardware identifier for iPhone Duo
    public static let targetModelIdentifier = "iPhone19,4"
    public static let targetMarketingName = "iPhone Duo"
    
    /// Published status for UI binding
    @Published public var isAuthorized: Bool = true
    @Published public var developerBypassEnabled: Bool = false
    
    /// Hardware inspection details
    public let detectedModelIdentifier: String
    public let detectedDeviceName: String
    public let isFoldableDualScreenHardware: Bool
    
    private init() {
        let (modelId, devName) = Self.inspectHardware()
        self.detectedModelIdentifier = modelId
        self.detectedDeviceName = devName
        
        let matchesModel = Self.isModeliPhoneDuo(modelIdentifier: modelId, deviceName: devName)
        self.isFoldableDualScreenHardware = matchesModel
        
        #if DEBUG
        // In debug builds, allow developer testing while still validating hardware
        self.isAuthorized = matchesModel || developerBypassEnabled
        #else
        // In production App Store builds, strictly enforce iPhone Duo
        self.isAuthorized = matchesModel
        #endif
    }
    
    /// Re-evaluates authorization (e.g. when developer toggles bypass in debug mode)
    public func reevaluateAuthorization() {
        let matchesModel = Self.isModeliPhoneDuo(modelIdentifier: detectedModelIdentifier, deviceName: detectedDeviceName)
        self.isAuthorized = matchesModel || developerBypassEnabled
    }
    
    /// Validates whether a device identifier or marketing name represents an iPhone Duo
    public static func isModeliPhoneDuo(modelIdentifier: String, deviceName: String) -> Bool {
        // 1. Direct model identifier check ("iPhone19,4" or "iPhone-Duo")
        if modelIdentifier == targetModelIdentifier || modelIdentifier.contains("iPhone-Duo") {
            return true
        }
        
        // 2. Device marketing name check ("iPhone Duo")
        if deviceName.contains(targetMarketingName) {
            return true
        }
        
        return false
    }
    
    /// Inspects the underlying machine identifier via Darwin sysctl (hw.machine)
    private static func inspectHardware() -> (modelIdentifier: String, deviceName: String) {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        let simModel = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
        let effectiveModel = simModel ?? identifier
        
        let simName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]
        let effectiveName = simName ?? UIDevice.current.name
        
        return (effectiveModel, effectiveName)
    }
}

// MARK: - iPhone Duo Exclusive Hardware Required Overlay
public struct iPhoneDuoExclusiveRequiredView: View {
    @ObservedObject var gatekeeper = iPhoneDuoGatekeeper.shared
    @State private var pulse: Bool = false
    @State private var foldAngle: Double = 25.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Dark Futuristic Arcade Backdrop
            Color(red: 0.05, green: 0.06, blue: 0.09)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            // Subtle Radial Ambient Glow
            RadialGradient(
                colors: [Color.cyan.opacity(0.18), Color.clear],
                center: .center,
                startRadius: 40,
                endRadius: 400
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // Animated Foldable iPhone Duo Graphic
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(Color.cyan.opacity(pulse ? 0.25 : 0.10))
                        .frame(width: 150, height: 150)
                        .scaleEffect(pulse ? 1.08 : 0.95)
                    
                    // Stylized Dual Screen Phone Fold graphic
                    HStack(spacing: 4) {
                        // Left Screen Half
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.cyan.opacity(0.8), .blue.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 74)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                            )
                            .rotation3DEffect(.degrees(foldAngle), axis: (x: 0, y: 1, z: 0), anchor: .trailing)
                        
                        // Center Hinge Glow
                        Capsule()
                            .fill(Color.yellow)
                            .frame(width: 4, height: 72)
                            .shadow(color: .yellow, radius: 6)
                        
                        // Right Screen Half
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.blue.opacity(0.9), .cyan.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 74)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                            )
                            .rotation3DEffect(.degrees(-foldAngle), axis: (x: 0, y: 1, z: 0), anchor: .leading)
                    }
                    
                    // Lock Badge
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.yellow)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.8)))
                        .offset(x: 32, y: 28)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulse = true
                        foldAngle = 50.0
                    }
                }
                
                // Header Titles
                VStack(spacing: 6) {
                    Text("SMASH IT!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                        )
                    
                    Text("EXCLUSIVE TO iPHONE DUO")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)
                        .tracking(2)
                }
                
                // Description Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DUAL-SCREEN HARDWARE REQUIRED")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text("This game is exclusively designed for the iPhone Duo foldable mechanics. It requires the physical dual-screen book-fold architecture and cannot run on standard single-screen phones.")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(2)
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    // Hardware Requirements Checklist
                    VStack(alignment: .leading, spacing: 6) {
                        featureRow(name: "Dual Foldable Retina Displays", available: gatekeeper.isFoldableDualScreenHardware)
                        featureRow(name: "Dynamic 180° Book-Fold Hinge Sensor", available: gatekeeper.isFoldableDualScreenHardware)
                        featureRow(name: "Face-to-Face Screen Clap Swatting", available: gatekeeper.isFoldableDualScreenHardware)
                        featureRow(name: "External Cover Screen Continuity", available: gatekeeper.isFoldableDualScreenHardware)
                    }
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    // App Store Distribution Notice
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.cyan)
                            Text("Motion Sensors: [CoreMotion, Proximity, Haptics]")
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.gen3")
                                .font(.system(size: 14))
                                .foregroundColor(.cyan)
                            Text("Target Architecture: iPhone Duo Foldable")
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.cyan.opacity(0.4), lineWidth: 1.5)
                        )
                )
                .padding(.horizontal, 24)
                
                #if DEBUG
                // Developer Bypass Toggle (Available in Debug Builds for Testing)
                VStack(spacing: 8) {
                    Button(action: {
                        gatekeeper.developerBypassEnabled.toggle()
                        gatekeeper.reevaluateAuthorization()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                            Text("DEVELOPER PREVIEW: SIMULATE iPHONE DUO")
                        }
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.yellow)
                        .cornerRadius(10)
                    }
                    
                    Text("Detected Device: \(gatekeeper.detectedModelIdentifier) (\(gatekeeper.detectedDeviceName))")
                        .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 4)
                #endif
                
                Spacer()
            }
        }
    }
    
    private func featureRow(name: String, available: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(available ? .green : .red)
            Text(name)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(available ? 0.9 : 0.6))
        }
    }
}
