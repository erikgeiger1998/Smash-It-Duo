import SwiftUI

@main
struct SmashItApp: App {
    init() {
        // Initialize procedural audio, sensors, iPhone Duo gatekeeper, and game engine
        _ = ProceduralSoundEngine.shared
        _ = FoldSensorManager.shared
        _ = ClapTrapGameEngine.shared
        _ = iPhoneDuoGatekeeper.shared
    }
    
    var body: some Scene {
        WindowGroup {
            FoldableDualScreenContainer()
                .preferredColorScheme(.dark)
                .statusBar(hidden: true)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
        }
    }
}
