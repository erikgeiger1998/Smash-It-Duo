import SwiftUI

/// Redesigned Arcade HUD: Centered floating glassmorphic cockpit console.
/// Beautifully formatted, perfectly positioned below bezels/notches,
/// with glowing neon score, wave badge, lives, integrated wipe sponge,
/// and urgent reaction countdown meter.
public struct GameHUDView: View {
    @ObservedObject var gameEngine = ClapTrapGameEngine.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 10) {
            // Centered Floating Glassmorphic Arcade Console
            HStack(spacing: 16) {
                // 1. LEFT POD: Score, High Score & Streak Multiplier
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("SCORE")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(gameEngine.score)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .yellow.opacity(0.6), radius: 4)
                        
                        if gameEngine.highScore > 0 {
                            Text("BEST: \(gameEngine.highScore)")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .foregroundColor(.orange.opacity(0.85))
                        }
                    }
                    
                    // Streak Multiplier Pill
                    if gameEngine.streak > 1 {
                        let mult = min(5, 1 + (gameEngine.streak / 3))
                        VStack(spacing: 1) {
                            Text("🔥")
                                .font(.system(size: 11))
                            Text("\(mult)X")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                        )
                    }
                }
                
                // Vertical Glass Divider
                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 1.2, height: 36)
                
                // 2. CENTER POD: Wave & Target Intel
                VStack(spacing: 3) {
                    HStack(spacing: 4) {
                        Text("WAVE")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(gameEngine.currentWave)")
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan.opacity(0.8), radius: 4)
                    }
                    
                    if let insect = gameEngine.activeInsect {
                        let isWasp = insect.type == .wasp
                        let isBoss = insect.type == .mutantHorsefly
                        
                        HStack(spacing: 3) {
                            Text(isWasp ? "⚠️" : (isBoss ? "👑" : "🪰"))
                                .font(.system(size: 8))
                            Text(insect.type.displayName.uppercased())
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundColor(isWasp ? .yellow : (isBoss ? .red : .white))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isWasp ? Color.red.opacity(0.75) : Color.white.opacity(0.12))
                        )
                    }
                }
                
                // Vertical Glass Divider
                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 1.2, height: 36)
                
                // 3. RIGHT POD: Lives & Integrated Sponge Button
                HStack(spacing: 12) {
                    // Lives Hearts
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { idx in
                            Image(systemName: idx < gameEngine.lives ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(idx < gameEngine.lives ? .red : .gray.opacity(0.5))
                                .shadow(color: idx < gameEngine.lives ? .red.opacity(0.8) : .clear, radius: 3)
                        }
                    }
                    
                    // Compact Sponge Wipe Button
                    Button(action: {
                        gameEngine.wipeScreenWithSponge()
                    }) {
                        HStack(spacing: 4) {
                            Text("🧽")
                                .font(.system(size: 14))
                            
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
                                        .stroke(gameEngine.persistentSplatters.count > 0 ? Color.yellow : Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(colors: [.yellow.opacity(0.6), .cyan.opacity(0.4), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
            .frame(maxWidth: 540)
            .padding(.top, 24) // Safely clear camera cutouts / bezels
            
            // Reaction Countdown Meter (Appears under console when insect lands!)
            if gameEngine.gameState == .landed {
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Text("🚨 CLAP PHONE SHUT NOW! 🚨")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(.red)
                        
                        Text(String(format: "%.2fs", (gameEngine.activeInsect?.landTimeRemaining ?? 0)))
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    
                    // Animated Neon Countdown Bar
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
                                .shadow(color: .red.opacity(0.8), radius: 4)
                        }
                    }
                    .frame(height: 8)
                    .frame(maxWidth: 320)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.8), lineWidth: 1.2)
                        )
                )
                .shadow(color: .red.opacity(0.5), radius: 8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
