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
    
    public init(initialTab: Int? = nil, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        let tab = initialTab ?? ClapTrapGameEngine.shared.menuInitialTab
        _selectedTab = State(initialValue: tab)
    }
    
    public var body: some View {
        ZStack {
            // Solid Dark Backdrop
            Color(red: 0.08, green: 0.09, blue: 0.12)
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
                    menuTabButton(title: "TUTORIAL", icon: "book.fill", index: 1)
                    menuTabButton(title: "LEGENDA", icon: "scope", index: 2)
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
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: 580)
        }
        .onAppear {
            selectedTab = gameEngine.menuInitialTab
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
    
    // MARK: - Tab 3: Legenda / Target Intel
    private enum LegendaRuleType {
        case swat
        case doubleClap
        case doNotSwat
    }
    
    private var targetIntelTabContent: some View {
        VStack(spacing: 14) {
            // Header Info Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "scope")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("ROVAR LEGENDA ÉS SZABÁLYOK")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    Text("PEST GUIDE")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.yellow.opacity(0.18)))
                }
                
                Text("Nézd meg alaposan mindegyik rovar fotóját! Egyeseket le kell csapni a pontokért, a Boss 2 hajtást igényel, a darazsat viszont szigorúan TILOS bántani!")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(2)
                
                // Quick Rule Indicator Strip
                HStack(spacing: 6) {
                    legendSummaryPill(title: "LECSAPNI!", icon: "checkmark.circle.fill", color: Color(red: 0.25, green: 0.88, blue: 0.45))
                    legendSummaryPill(title: "2x CSAPÁS", icon: "bolt.shield.fill", color: Color(red: 0.80, green: 0.40, blue: 1.0))
                    legendSummaryPill(title: "TILOS CSAPNI!", icon: "exclamationmark.octagon.fill", color: Color(red: 1.0, green: 0.25, blue: 0.25))
                }
                .padding(.top, 2)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.10, green: 0.12, blue: 0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                    )
            )
            
            // 1. HÁZI LÉGY (HOUSEFLY)
            insectLegendaCard(
                type: .housefly,
                huName: "HÁZI LÉGY",
                enName: "Common Housefly",
                ruleType: .swat,
                actionTitle: "LE SZABAD CSAPNI!",
                actionSubtitle: "SWAT TARGET",
                color: Color(red: 0.25, green: 0.88, blue: 0.45),
                keyTrait: "Hullámonként gyorsuló célpont",
                timeRange: "3.6s -> 0.95s",
                points: "100 PTS",
                huDesc: "A leggyakoribb célpont. Amikor leszáll a görögdinnyére és elkezdi dörzsölni az elülső lábait, finoman csukd össze a telefont! Az 1. szinten 3.6 másodperced van, ami a magasabb hullámokon fokozatosan 0.95 másodpercre gyorsul.",
                enDesc: "Standard target. When it lands on the bait and rubs its legs, fold phone gently to trap it! Landing window starts at 3.6s and accelerates down to 0.95s on higher waves."
            )
            
            // 2. SZÚNYOG (MOSQUITO)
            insectLegendaCard(
                type: .mosquito,
                huName: "SZÚNYOG",
                enName: "Stealth Mosquito",
                ruleType: .swat,
                actionTitle: "LE SZABAD CSAPNI!",
                actionSubtitle: "SWAT TARGET",
                color: Color(red: 0.20, green: 0.85, blue: 1.0),
                keyTrait: "Természeténél fogva még gyorsabb!",
                timeRange: "2.6s -> 0.85s",
                points: "250 PTS",
                huDesc: "Természeténél fogva még gyorsabb! Apró termetű, ideges röptű és magas 460Hz-es hangon zümmög. Mindössze 2.6 - 0.85 másodpercet tölt a dinnyén – villámgyors reflexek szükségesek a lecsapásához!",
                enDesc: "Naturally faster! Tiny, erratic with high-frequency 460Hz whine. Stays landed only 2.6s down to 0.85s — requires instant reflex folding before it flees!"
            )
            
            // 3. MUTÁNS BÖGÖLY (BOSS)
            insectLegendaCard(
                type: .mutantHorsefly,
                huName: "MUTÁNS BÖGÖLY (BOSS)",
                enName: "Mutant Horsefly",
                ruleType: .doubleClap,
                actionTitle: "DUPLA CSAPÁS!",
                actionSubtitle: "2x HAJTÁS KELL A LETERÍTÉSÉHEZ",
                color: Color(red: 0.80, green: 0.40, blue: 1.0),
                keyTrait: "Páncélozott Főellenség (Boss)",
                timeRange: "3.4s -> 1.10s (x2)",
                points: "750 PTS (BOSS)",
                huDesc: "Páncélozott óriás boss: az 1. összecsukást kibírja és túléli (HP 2 -> 1)! Amint összecsuktad, azonnal nyisd ki a telefont és csapd le másodszor is mielőtt elrepül!",
                enDesc: "Armored titan boss: survives the 1st fold (HP 2 -> 1)! As soon as you fold, instantly reopen flat and clap a second time to squash it!"
            )
            
            // 4. DARÁZS (CSAPDA)
            insectLegendaCard(
                type: .wasp,
                huName: "DARÁZS (CSAPDA)",
                enName: "Yellowjacket Wasp",
                ruleType: .doNotSwat,
                actionTitle: "NEM SZABAD LECSAPNI!",
                actionSubtitle: "ITT A TÜRELMET KELL TARTANI!",
                color: Color(red: 1.0, green: 0.25, blue: 0.25),
                keyTrait: "Halálos Csapda (Trap Hazard)",
                timeRange: "3.5s -> 2.20s",
                points: "+500 PTS (TÜRELEM)",
                huDesc: "VESZÉLYES CSAPDA! Szigorúan TILOS lecsapni! Ha összecsukod a telefont, a darázs azonnal megcsíp és VÉGE A JÁTÉKNAK (Game Over). Itt a türelmet kell tartani: várd meg békésen a 3.5 - 2.2 másodperces türelemablak végét, míg magától elszáll, és kapj +500 pont bónuszt!",
                enDesc: "LETHAL TRAP! Strictly DO NOT fold phone! Clapping stings you for an instant Game Over. Hold your patience and let it fly away peacefully to earn +500 PTS!"
            )
        }
    }
    
    private func insectLegendaCard(
        type: InsectType,
        huName: String,
        enName: String,
        ruleType: LegendaRuleType,
        actionTitle: String,
        actionSubtitle: String,
        color: Color,
        keyTrait: String,
        timeRange: String,
        points: String,
        huDesc: String,
        enDesc: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // TOP SECTION: Specimen Photo & Identity + Swat Pill
            HStack(alignment: .top, spacing: 14) {
                // Procedural Photo / Specimen Lens
                VStack(spacing: 5) {
                    InsectPreviewThumbnailView(type: type, size: 82)
                    
                    Text(specimenBadgeText(ruleType))
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundColor(color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.18))
                                .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 0.8))
                        )
                }
                
                // Right Details
                VStack(alignment: .leading, spacing: 5) {
                    // Action Banner Pill
                    HStack(spacing: 5) {
                        Image(systemName: actionIcon(ruleType))
                            .font(.system(size: 11, weight: .black))
                        Text(actionTitle)
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(ruleType == .doNotSwat ? .white : (ruleType == .doubleClap ? .white : .black))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(actionBackgroundColor(ruleType))
                    )
                    
                    // Name Header
                    VStack(alignment: .leading, spacing: 1) {
                        Text(huName)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(enName)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    
                    // Trait Callout
                    Text(keyTrait)
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            
            // METRIC GRID: Time & Score Pills
            HStack(spacing: 8) {
                // Time Range
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(ruleType == .doNotSwat ? "TÜRELEM ABLAK" : "REAKCIÓIDŐ")
                            .font(.system(size: 7, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text(timeRange)
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 0.8))
                )
                
                // Score Value
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("JUTALOM / SCORE")
                            .font(.system(size: 7, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text(points)
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow.opacity(0.25), lineWidth: 0.8))
                )
            }
            
            // DESCRIPTIVE GUIDANCE (Hungarian & English)
            VStack(alignment: .leading, spacing: 4) {
                Text(huDesc)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(2)
                
                Text(enDesc)
                    .font(.system(size: 9.5, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(1.5)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.10, green: 0.12, blue: 0.16).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.85), color.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: color.opacity(0.2), radius: 8)
        )
    }
    
    private func specimenBadgeText(_ ruleType: LegendaRuleType) -> String {
        switch ruleType {
        case .swat: return "SWAT TARGET"
        case .doubleClap: return "BOSS (2x)"
        case .doNotSwat: return "TRAP HAZARD"
        }
    }
    
    private func actionIcon(_ ruleType: LegendaRuleType) -> String {
        switch ruleType {
        case .swat: return "checkmark.seal.fill"
        case .doubleClap: return "bolt.shield.fill"
        case .doNotSwat: return "exclamationmark.octagon.fill"
        }
    }
    
    private func actionBackgroundColor(_ ruleType: LegendaRuleType) -> Color {
        switch ruleType {
        case .swat: return Color(red: 0.25, green: 0.88, blue: 0.45)
        case .doubleClap: return Color(red: 0.65, green: 0.30, blue: 0.95)
        case .doNotSwat: return Color(red: 0.95, green: 0.15, blue: 0.15)
        }
    }
    
    private func legendSummaryPill(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(title)
                .font(.system(size: 9, weight: .black, design: .monospaced))
        }
        .foregroundColor(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 0.8))
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
