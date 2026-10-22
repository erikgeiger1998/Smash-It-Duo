import SwiftUI

@main
struct ClapTrapApp: App {
    init() {
        // Initialize procedural audio, sensors, and game engine
        _ = ProceduralSoundEngine.shared
        _ = FoldSensorManager.shared
        _ = ClapTrapGameEngine.shared
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
