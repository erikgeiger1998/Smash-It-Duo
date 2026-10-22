import SwiftUI

/// Complete In-Game Menu & Settings Interface:
/// Zero external assets. Zero emojis. 100% clean Apple SF Symbols and procedural arcade graphics.
/// Includes Audio Controls (Music / SFX / Ambient Buzz / Volume sliders),
/// Hardware Settings (Haptics, Sensitivity), How-To-Play Guide,
/// Target Intel Bestiary, and High Score management.
public struct GameMenuView: View {
    @ObservedObject var soundEngine = ProceduralSoundEngine.shared
    @ObservedObject var gameEngine = ClapTrapGameEngine.shared
    @ObservedObject var foldSensor = FoldSensorManager.shared
    
    let onDismiss: () -> Void
    
    @State private var selectedTab: Int = 0 // 0: Settings, 1: How To Play, 2: Target Intel
    @State private var showResetScoreConfirm: Bool = false
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            // Dark Frosted Backdrop
            Color.black.opacity(0.85)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CLAPTRAP")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text("ARCADE MENU & SETTINGS")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(2)
                    }
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white.opacity(0.75))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                // MARK: - Segmented Navigation Bar
                HStack(spacing: 8) {
                    menuTabButton(title: "SETTINGS", icon: "gearshape.fill", index: 0)
                    menuTabButton(title: "HOW TO PLAY", icon: "book.fill", index: 1)
                    menuTabButton(title: "TARGET INTEL", icon: "target", index: 2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // MARK: - Tab Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        if selectedTab == 0 {
                            settingsTabContent
                        } else if selectedTab == 1 {
                            howToPlayTabContent
                        } else {
                            targetIntelTabContent
                        }
                        
                        // Safety Notice Card (Present in all tabs)
                        safetyNoticeCard
                        
                        // Footer
                        VStack(spacing: 3) {
                            Text("CLAPTRAP v1.0 • 100% PROCEDURAL CODE")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                            Text("DESIGNED FOR DUAL-SCREEN & FOLDABLE HARDWARE")
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: 580)
        }
        .alert(isPresented: $showResetScoreConfirm) {
            Alert(
                title: Text("Reset High Score"),
                message: Text("Are you sure you want to reset your all-time high score to 0? This cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    gameEngine.highScore = 0
                    UserDefaults.standard.set(0, forKey: "ClapTrap_HighScore_Key")
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Tab Button Component
    private func menuTabButton(title: String, icon: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
            soundEngine.triggerInsectLandingHaptic()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
            }
            .foregroundColor(selectedTab == index ? .black : .white.opacity(0.75))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedTab == index ? Color.yellow : Color.white.opacity(0.10))
            )
        }
    }
    
    // MARK: - Tab 1: Settings
    private var settingsTabContent: some View {
        VStack(spacing: 14) {
            // 1. Audio Controls Card
            settingsCard(title: "AUDIO CONTROLS", icon: "speaker.wave.3.fill") {
                VStack(spacing: 12) {
                    // Arcade Music Toggle
                    Toggle(isOn: $soundEngine.isMusicEnabled) {
                        HStack(spacing: 8) {
                            Image(systemName: "music.note")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            Text("Arcade Background Music")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .tint(.yellow)
                    
                    // Music Volume Slider
                    if soundEngine.isMusicEnabled {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Slider(
                                value: Binding(
                                    get: { Double(soundEngine.musicVolume) },
                                    set: { soundEngine.musicVolume = Float($0) }
                                ),
                                in: 0.0...1.0
                            )
                            .tint(.yellow)
                            
                            Text("\(Int(soundEngine.musicVolume * 100))%")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 38, alignment: .trailing)
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    // Sound Effects Toggle
                    Toggle(isOn: $soundEngine.isSFXEnabled) {
                        HStack(spacing: 8) {
                            Image(systemName: "waveform")
                                .font(.system(size: 14))
                                .foregroundColor(.cyan)
                            Text("Sound Effects (SFX)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .tint(.cyan)
                    
                    // SFX Volume Slider
                    if soundEngine.isSFXEnabled {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Slider(
                                value: Binding(
                                    get: { Double(soundEngine.sfxVolume) },
                                    set: { soundEngine.sfxVolume = Float($0) }
                                ),
                                in: 0.0...1.0
                            )
                            .tint(.cyan)
                            
                            Text("\(Int(soundEngine.sfxVolume * 100))%")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 38, alignment: .trailing)
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    // Ambient Menu Flyby Buzz Toggle
                    Toggle(isOn: $soundEngine.isAmbientBuzzEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Image(systemName: "wind")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                                Text("Menu Ambient Flybys")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Text("Occasional stereo insect flyby sounds in menus")
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.55))
                        }
                    }
                    .tint(.orange)
                }
            }
            
            // 2. Hardware & Haptic Controls Card
            settingsCard(title: "HARDWARE & SENSORS", icon: "iphone.gen3") {
                VStack(spacing: 12) {
                    // Haptic Feedback Toggle
                    Toggle(isOn: $soundEngine.isHapticsEnabled) {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            Text("Haptic Vibrations")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .tint(.green)
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    // Fold Trigger Sensitivity
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "slider.horizontal.2.square")
                                .font(.system(size: 14))
                                .foregroundColor(.purple)
                            Text("Hinge Angle Threshold")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text(soundEngine.isHighSensitivity ? "High (45°)" : "Normal (35°)")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                        
                        Picker("Sensitivity", selection: $soundEngine.isHighSensitivity) {
                            Text("Normal").tag(false)
                            Text("High Sensitivity").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            
            // 3. Stats & Data Card
            settingsCard(title: "GAME RECORDS", icon: "trophy.fill") {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ALL-TIME HIGH SCORE")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(gameEngine.highScore) PTS")
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showResetScoreConfirm = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("RESET")
                        }
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.6), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Tab 2: How To Play
    private var howToPlayTabContent: some View {
        VStack(spacing: 12) {
            instructionStepRow(
                number: "1",
                icon: "iphone.gen3",
                title: "OPEN PHONE FLAT",
                desc: "Unfold the device to 180° flat. The game starts automatically on the dual-screen picnic table."
            )
            
            instructionStepRow(
                number: "2",
                icon: "waveform.path",
                title: "LISTEN & WATCH",
                desc: "Follow the insect flying across the table with spatial 3D stereo audio buzzing."
            )
            
            instructionStepRow(
                number: "3",
                icon: "target",
                title: "WAIT FOR LANDING",
                desc: "Wait until the fly lands on the watermelon bait and rubs its front legs. A 3+ second window begins."
            )
            
            instructionStepRow(
                number: "4",
                icon: "hands.sparkles.fill",
                title: "FOLD PHONE GENTLY",
                desc: "Smoothly fold the device shut. The instant the screen closes, the fly is trapped! No need to smash."
            )
            
            instructionStepRow(
                number: "5",
                icon: "sparkles",
                title: "CHECK COVER SCREEN",
                desc: "The cover screen instantly reveals the result. Unfold the phone to begin the next wave!"
            )
        }
    }
    
    private func instructionStepRow(number: String, icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                    Text(title)
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Text(desc)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Tab 3: Target Intel
    private var targetIntelTabContent: some View {
        VStack(spacing: 12) {
            insectIntelCard(
                name: "COMMON HOUSEFLY",
                badge: "STANDARD TARGET",
                color: .green,
                time: "3.2 SECONDS",
                points: "100 PTS",
                desc: "Buzzes casually before landing on the juicy bait. Clean, smooth folding easily traps it."
            )
            
            insectIntelCard(
                name: "STEALTH MOSQUITO",
                badge: "AGILE & TINY",
                color: .cyan,
                time: "2.2 SECONDS",
                points: "250 PTS",
                desc: "High-frequency 460Hz flight whine. Smaller target requiring focused reflexes."
            )
            
            insectIntelCard(
                name: "MUTANT HORSEFLY",
                badge: "BOSS TARGET",
                color: .purple,
                time: "3.0 SECONDS",
                points: "750 PTS",
                desc: "Armored giant pest! Survives the 1st fold. Requires a double-fold to squash."
            )
            
            insectIntelCard(
                name: "YELLOWJACKET WASP",
                badge: "HAZARD - DO NOT FOLD",
                color: .red,
                time: "3.8 SECONDS",
                points: "500 PTS (PATIENCE)",
                desc: "DANGER! Do not fold your phone! Let it fly away in peace to earn the 500pt Patience Bonus."
            )
        }
    }
    
    private func insectIntelCard(
        name: String,
        badge: String,
        color: Color,
        time: String,
        points: String,
        desc: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(badge)
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundColor(color)
                    Text(name)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(points)
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                    Text(time)
                        .font(.system(size: 8, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Text(desc)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.5), lineWidth: 1.2)
                )
        )
    }
    
    // MARK: - Reusable Settings Card
    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.yellow)
                Text(title)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(1)
            }
            
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Safety Notice Card (Zero Emojis)
    private var safetyNoticeCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.yellow)
            
            Text("SAFETY NOTICE: Fold phone gently.")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
        )
    }
}
