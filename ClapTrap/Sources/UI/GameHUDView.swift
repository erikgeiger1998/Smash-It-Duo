import SwiftUI

/// Redesigned Arcade HUD: Centered floating glassmorphic cockpit console.
/// Prominently positioned with comfortable top safe-area clearance,
/// featuring bold glowing neon score, combo streak multiplier, wave target radar,
/// heart lives, integrated sponge wipe button, and an urgent reaction countdown bar.
public struct GameHUDView: View {
    @ObservedObject var gameEngine = ClapTrapGameEngine.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 8) {
            // Centered Cyber-Arcade Cockpit Console
            HStack(spacing: 14) {
                // 1. LEFT POD: Score, High Score & Streak Combo
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SCORE")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.65))
                            .tracking(1)
                        
                        Text("\(gameEngine.score)")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .yellow.opacity(0.7), radius: 6)
                        
                        if gameEngine.highScore > 0 {
                            Text("BEST: \(gameEngine.highScore)")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .foregroundColor(.orange.opacity(0.9))
                        }
                    }
                    
                    // Streak Combo Multiplier
                    if gameEngine.streak > 1 {
                        let mult = min(5, 1 + (gameEngine.streak / 3))
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text("\(mult)X")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.35))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange, lineWidth: 1.2)
                                )
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 4)
                    }
                }
                
                // Vertical Glass Divider
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1.2, height: 38)
                
                // 2. CENTER POD: Wave & Target Intel Radar
                VStack(spacing: 3) {
                    HStack(spacing: 4) {
                        Text("WAVE")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(gameEngine.currentWave)")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan.opacity(0.9), radius: 6)
                    }
                    
                    if let insect = gameEngine.activeInsect {
                        Button(action: {
                            gameEngine.openMenu(tab: 2)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "scope")
                                    .font(.system(size: 9))
                                    .foregroundColor(.cyan)
                                
                                Text(insect.type.displayName.uppercased())
                                    .font(.system(size: 8, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.14))
                            )
                        }
                    }
                }
                
                // Vertical Glass Divider
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1.2, height: 38)
                
                // 3. RIGHT POD: Lives, Squeegee Sponge, and Settings Menu Button
                HStack(spacing: 10) {
                    // Hearts Lives
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { idx in
                            Image(systemName: idx < gameEngine.lives ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(idx < gameEngine.lives ? .red : .gray.opacity(0.4))
                                .shadow(color: idx < gameEngine.lives ? .red.opacity(0.8) : .clear, radius: 4)
                        }
                    }
                    
                    // Squeegee Clean Screen Button
                    Button(action: {
                        gameEngine.wipeScreenWithSponge()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.yellow)
                            
                            if gameEngine.persistentSplatters.count > 0 {
                                Text("\(gameEngine.persistentSplatters.count)")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(gameEngine.persistentSplatters.count > 0 ? Color.yellow.opacity(0.25) : Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            gameEngine.persistentSplatters.count > 0 ? Color.yellow : Color.white.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    
                    // Pause / Resume Button
                    Button(action: {
                        gameEngine.togglePause()
                    }) {
                        Image(systemName: gameEngine.isGamePaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(gameEngine.isGamePaused ? .yellow : .white.opacity(0.85))
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(gameEngine.isGamePaused ? Color.yellow.opacity(0.25) : Color.white.opacity(0.12))
                            )
                    }
                    
                    // Menu & Settings Gear Button
                    Button(action: {
                        gameEngine.openMenu(tab: 0)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                            )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.65), .cyan.opacity(0.4), .white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: .black.opacity(0.6), radius: 12, y: 6)
            .frame(maxWidth: 540)
            .padding(.top, 40) // Prominently clear dynamic islands, camera notches, and top edges
            
            // Gentle Fold Reaction Countdown Meter (Drops down under console when insect lands!)
            if gameEngine.gameState == .landed {
                VStack(spacing: 5) {
                    HStack(spacing: 8) {
                        Text("FOLD GENTLY TO SWAT")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(gameEngine.reactionProgress < 0.3 ? .orange : .green)
                        
                        Text(String(format: "%.1fs", (gameEngine.activeInsect?.landTimeRemaining ?? 0)))
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(gameEngine.reactionProgress < 0.3 ? .red : .yellow)
                    }
                    
                    // Safety subtext reminder
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("SAFETY NOTICE: Fold phone gently.")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    // Animated Neon Laser Countdown Bar (Color transitions from Green -> Yellow -> Red!)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.7))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .yellow, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(0, geo.size.width * CGFloat(gameEngine.reactionProgress)), height: 8)
                                .shadow(
                                    color: gameEngine.reactionProgress < 0.3 ? .red.opacity(0.9) : (gameEngine.reactionProgress < 0.6 ? .yellow.opacity(0.85) : .green.opacity(0.85)),
                                    radius: 6
                                )
                        }
                    }
                    .frame(height: 8)
                    .frame(maxWidth: 320)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.88))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(gameEngine.reactionProgress < 0.3 ? Color.red : Color.green.opacity(0.85), lineWidth: 1.5)
                        )
                )
                .shadow(color: .black.opacity(0.55), radius: 10)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Patience Bonus Success Banner (Shown when wasp flies away peacefully)
            if gameEngine.patienceSuccessBanner {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("+500 PTS • PATIENCE BONUS!")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.90))
                        .overlay(Capsule().stroke(Color.yellow, lineWidth: 1.5))
                )
                .shadow(color: .yellow.opacity(0.4), radius: 8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
