import Foundation
import AVFoundation
import CoreHaptics
import UIKit

/// 100% Procedural Sound & Haptics Engine.
/// Generates continuous spatial 3D insect buzzing, wet splat impacts, glass shatters,
/// squeaky sponges, and the signature dying insect haptic vibration inside the closed phone.
/// Zero external audio files (no MP3s, no WAVs).
public final class ProceduralSoundEngine: ObservableObject {
    public static let shared = ProceduralSoundEngine()
    
    // MARK: - Audio Engine Properties
    private let audioEngine = AVAudioEngine()
    private var buzzSourceNode: AVAudioSourceNode?
    private let sfxPlayerNode = AVAudioPlayerNode()
    private let audioFormat: AVAudioFormat
    
    // Buzz Synthesis Parameters (thread-safe atomics / locks for real-time render thread)
    private var isBuzzing: Bool = false
    private var targetFrequency: Float = 155.0 // Hz
    private var currentFrequency: Float = 155.0
    private var stereoPan: Float = 0.0 // -1.0 (Left) to +1.0 (Right)
    private var buzzVolume: Float = 0.0 // 0.0 to 1.0
    private var phase: Float = 0.0
    private var lfoPhase: Float = 0.0
    private var flutterLFOPhase: Float = 0.0
    private let sampleRate: Double = 44100.0
    
    // Insect harmonic characteristics
    private var harmonicSawtoothWeight: Float = 0.55
    private var harmonicSquareWeight: Float = 0.35
    private var noiseModulationWeight: Float = 0.10
    
    // MARK: - CoreHaptics Engine
    private var hapticEngine: CHHapticEngine?
    private var supportsCoreHaptics: Bool = false
    
    // Fallback standard feedback generators
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    // Lock for audio synthesis parameters
    private let audioLock = os_unfair_lock_t.allocate(capacity: 1)
    
    private init() {
        audioLock.initialize(to: os_unfair_lock())
        
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        self.audioFormat = format
        
        setupAudioEngine()
        setupHaptics()
    }
    
    deinit {
        audioLock.deallocate()
    }
    
    // MARK: - Audio Setup
    private func setupAudioEngine() {
        // Activate audio session asynchronously on background queue to prevent main-thread UI unresponsiveness
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try session.setActive(true)
            } catch {
                print("ProceduralSoundEngine: Audio session setup notice: \(error.localizedDescription)")
            }
            
            if !self.audioEngine.isRunning {
                do {
                    try self.audioEngine.start()
                } catch {
                    print("ProceduralSoundEngine: Failed to start AVAudioEngine: \(error.localizedDescription)")
                }
            }
        }
        
        // 1. Setup Buzz Source Node for real-time mathematical wave synthesis
        buzzSourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            guard ablPointer.count >= 2,
                  let leftBuffer = ablPointer[0].mData?.assumingMemoryBound(to: Float.self),
                  let rightBuffer = ablPointer[1].mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }
            
            os_unfair_lock_lock(self.audioLock)
            let buzzing = self.isBuzzing
            let freq = self.targetFrequency
            let pan = self.stereoPan
            let vol = self.buzzVolume
            let sawWeight = self.harmonicSawtoothWeight
            let sqWeight = self.harmonicSquareWeight
            let nzWeight = self.noiseModulationWeight
            os_unfair_lock_unlock(self.audioLock)
            
            if !buzzing || vol <= 0.001 {
                for frame in 0..<Int(frameCount) {
                    leftBuffer[frame] = 0.0
                    rightBuffer[frame] = 0.0
                }
                return noErr
            }
            
            // Calculate stereo panning coefficients (constant power panning)
            let panAngle = (pan + 1.0) * 0.25 * Float.pi // 0 to pi/2
            let leftGain = cos(panAngle) * vol
            let rightGain = sin(panAngle) * vol
            
            let twoPi = Float.pi * 2.0
            let dt = 1.0 / Float(self.sampleRate)
            
            for frame in 0..<Int(frameCount) {
                // Smooth frequency slew
                self.currentFrequency += (freq - self.currentFrequency) * 0.005
                
                // Low-frequency vibrato LFO (6 Hz frequency modulation)
                self.lfoPhase += twoPi * 6.0 * dt
                if self.lfoPhase > twoPi { self.lfoPhase -= twoPi }
                let vibrato = sin(self.lfoPhase) * 6.0 // +/- 6 Hz wobble
                
                // Wing-flutter amplitude LFO (18 Hz flutter modulation)
                self.flutterLFOPhase += twoPi * 18.0 * dt
                if self.flutterLFOPhase > twoPi { self.flutterLFOPhase -= twoPi }
                let flutter = 0.85 + 0.15 * sin(self.flutterLFOPhase)
                
                let instantFreq = max(30.0, self.currentFrequency + vibrato)
                self.phase += twoPi * instantFreq * dt
                if self.phase > twoPi { self.phase -= twoPi }
                
                // Fundamental normalized phase: 0.0 to 1.0
                let normPhase = self.phase / twoPi
                
                // 1. Sawtooth wave (rich odd and even harmonics)
                let sawWave: Float = 2.0 * (normPhase - 0.5)
                
                // 2. Band-limited square wave with 2nd harmonic for insect buzz buzz
                let sqWave: Float = normPhase < 0.5 ? 1.0 : -1.0
                let secondHarmonic: Float = sin(self.phase * 2.0) * 0.4
                
                // 3. Chitinous wing noise / air friction
                let whiteNoise: Float = Float.random(in: -1.0...1.0) * nzWeight
                
                let sawComponent: Float = sawWave * sawWeight
                let sqComponent: Float = (sqWave + secondHarmonic) * sqWeight
                let combinedOsc: Float = sawComponent + sqComponent + whiteNoise
                let rawBuzz: Float = combinedOsc * flutter
                
                // Apply soft saturation to simulate bug thorax resonance
                let saturated = tanh(rawBuzz * 1.5) * 0.65
                
                leftBuffer[frame] = saturated * leftGain
                rightBuffer[frame] = saturated * rightGain
            }
            
            return noErr
        }
        
        guard let buzzNode = buzzSourceNode else { return }
        audioEngine.attach(buzzNode)
        audioEngine.attach(sfxPlayerNode)
        
        audioEngine.connect(buzzNode, to: audioEngine.mainMixerNode, format: audioFormat)
        audioEngine.connect(sfxPlayerNode, to: audioEngine.mainMixerNode, format: audioFormat)
    }
    
    private func setupHaptics() {
        supportsCoreHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsCoreHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart CoreHaptics engine: \(error)")
                }
            }
        } catch {
            print("ProceduralSoundEngine: CoreHaptics init notice: \(error.localizedDescription)")
            supportsCoreHaptics = false
        }
    }
    
    // MARK: - Real-Time Spatial Buzzing Control
    
    /// Update spatial buzz parameters based on insect position and species
    /// - Parameters:
    ///   - normalizedX: -1.0 (far left screen) to +1.0 (far right screen)
    ///   - altitude: 0.0 (landed on screen) to 1.0 (flying high in the air)
    ///   - insectType: determines base fundamental frequency and timbre
    public func updateInsectSpatialBuzz(normalizedX: Float, altitude: Float, insectType: InsectType, active: Bool) {
        os_unfair_lock_lock(audioLock)
        self.isBuzzing = active
        self.stereoPan = max(-1.0, min(1.0, normalizedX))
        
        // Closer to screen = louder, more intimate buzz
        let baseVol: Float = 0.45
        let altitudeVolFactor: Float = 0.35 + 0.65 * (1.0 - altitude * 0.4)
        self.buzzVolume = active ? (baseVol * altitudeVolFactor) : 0.0
        
        switch insectType {
        case .housefly:
            self.targetFrequency = 158.0 + (1.0 - altitude) * 15.0
            self.harmonicSawtoothWeight = 0.55
            self.harmonicSquareWeight = 0.35
            self.noiseModulationWeight = 0.10
        case .mosquito:
            self.targetFrequency = 460.0 + (1.0 - altitude) * 35.0 // High pitch annoying whine
            self.harmonicSawtoothWeight = 0.30
            self.harmonicSquareWeight = 0.65
            self.noiseModulationWeight = 0.05
        case .mutantHorsefly:
            self.targetFrequency = 92.0 + (1.0 - altitude) * 10.0 // Heavy menacing low thrum
            self.harmonicSawtoothWeight = 0.65
            self.harmonicSquareWeight = 0.25
            self.noiseModulationWeight = 0.20
        case .wasp:
            self.targetFrequency = 230.0 + (1.0 - altitude) * 20.0 // Aggressive sharp warning buzz
            self.harmonicSawtoothWeight = 0.70
            self.harmonicSquareWeight = 0.20
            self.noiseModulationWeight = 0.15
        }
        os_unfair_lock_unlock(audioLock)
    }
    
    public func stopBuzz() {
        os_unfair_lock_lock(audioLock)
        self.isBuzzing = false
        self.buzzVolume = 0.0
        os_unfair_lock_unlock(audioLock)
    }
    
    // MARK: - Procedural SFX Synthesis & Playback
    
    /// Play a procedurally synthesized wet bug splat sound (THWACK + SQUELCH)
    public func playSplatSound(slamVelocity: Double) {
        let sampleRate = self.sampleRate
        let duration: Double = 0.32
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }
        
        let velocityBoost = Float(min(2.0, max(0.8, slamVelocity / 800.0)))
        
        var lpFilterState: Float = 0.0
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            
            // 1. Initial heavy fleshy impact thud (exponential decaying sine 120Hz -> 45Hz)
            let thudFreq = 120.0 * exp(-t * 18.0) + 40.0
            let thudEnv = exp(-t * 22.0)
            let thud = Float(sin(2.0 * .pi * thudFreq * t) * thudEnv) * 0.85
            
            // 2. Wet squelch noise burst with resonant filter sweep
            let whiteNoise = Float.random(in: -1.0...1.0)
            let cutoff = Float(exp(-t * 15.0) * 0.4 + 0.05)
            lpFilterState += cutoff * (whiteNoise - lpFilterState)
            let squelchEnv = Float(sin(t * .pi / duration) * exp(-t * 9.0))
            let squelch = lpFilterState * squelchEnv * 1.3
            
            // 3. Visceral pop/crack
            let popEnv = Float(exp(-t * 60.0))
            let pop = Float(sin(2.0 * .pi * 280.0 * t)) * popEnv * 0.5
            
            let mixed = (thud + squelch + pop) * 0.7 * velocityBoost
            let clamped = max(-1.0, min(1.0, mixed))
            
            left[i] = clamped
            right[i] = clamped
        }
        
        playBuffer(buffer)
        
        // Haptic impact
        heavyImpact.prepare()
        heavyImpact.impactOccurred(intensity: CGFloat(min(1.0, velocityBoost)))
    }
    
    /// Play the procedural "Too Hard!" Glass Shatter Easter Egg sound
    public func playGlassShatterSound() {
        let sampleRate = self.sampleRate
        let duration: Double = 0.85
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }
        
        // Inharmonic glass fracture frequencies
        let resonantModes: [Double] = [1240.0, 1860.0, 2450.0, 3720.0, 4890.0, 6200.0]
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            
            // Sharp initial crunch noise
            let noise = Float.random(in: -1.0...1.0) * Float(exp(-t * 28.0)) * 0.75
            
            // Ringing glass shards
            var glassChimes: Double = 0.0
            for (idx, mode) in resonantModes.enumerated() {
                let decay = 6.0 + Double(idx) * 2.5
                glassChimes += sin(2.0 * .pi * mode * t) * exp(-t * decay) * (1.0 / Double(idx + 1))
            }
            
            let mixed = noise + Float(glassChimes * 0.28)
            let clamped = max(-1.0, min(1.0, mixed))
            
            left[i] = clamped
            right[i] = clamped
        }
        
        playBuffer(buffer)
        
        notificationFeedback.notificationOccurred(.error)
    }
    
    /// Procedural squeaky sponge wipe sound
    public func playSpongeWipeSound() {
        let sampleRate = self.sampleRate
        let duration: Double = 0.22
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Up and down chirp FM sweep
            let chirpFreq = 1600.0 + 800.0 * sin(t * .pi / duration * 2.0)
            let env = Float(sin(t * .pi / duration))
            let squeak = Float(sin(2.0 * .pi * chirpFreq * t)) * env * 0.45
            
            // Soft friction texture
            let friction = Float.random(in: -0.15...0.15) * env
            
            let mixed = squeak + friction
            left[i] = mixed
            right[i] = mixed
        }
        
        playBuffer(buffer)
        lightImpact.impactOccurred(intensity: 0.6)
    }
    
    /// Procedural Unfold Hinge Snap / Whoosh Sound
    public func playUnfoldHingeSound() {
        let sampleRate = self.sampleRate
        let duration: Double = 0.28
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let click = Float.random(in: -1.0...1.0) * Float(exp(-t * 80.0)) * 0.6
            let whooshFreq = 300.0 + 900.0 * (t / duration)
            let whooshEnv = Float(sin(t * .pi / duration))
            let whoosh = Float(sin(2.0 * .pi * whooshFreq * t)) * whooshEnv * 0.35
            
            let mixed = click + whoosh
            left[i] = mixed
            right[i] = mixed
        }
        
        playBuffer(buffer)
        mediumImpact.impactOccurred(intensity: 0.7)
    }
    
    /// Procedural Wasp Sting penalty sound
    public func playStingSound() {
        let sampleRate = self.sampleRate
        let duration: Double = 0.45
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Dissonant dual tone sawtooth zap
            let f1 = 440.0 * (1.0 - t * 0.8)
            let f2 = 466.16 * (1.0 - t * 0.8) // Minor second clash!
            let p1 = Float((t * f1).truncatingRemainder(dividingBy: 1.0) * 2.0 - 1.0)
            let p2 = Float((t * f2).truncatingRemainder(dividingBy: 1.0) * 2.0 - 1.0)
            let env = Float(exp(-t * 6.0))
            
            let mixed = (p1 + p2) * 0.4 * env
            left[i] = mixed
            right[i] = mixed
        }
        
        playBuffer(buffer)
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Procedural Victory / Godlike Reflex Fanfare
    public func playGodlikeFanfare() {
        let sampleRate = self.sampleRate
        let duration: Double = 0.55
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }
        
        // Fast ascending triad arpeggio: C6, E6, G6, C7
        let notes: [Double] = [1046.50, 1318.51, 1567.98, 2093.00]
        let noteDuration = duration / Double(notes.count)
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let noteIdx = min(notes.count - 1, Int(t / noteDuration))
            let noteFreq = notes[noteIdx]
            let noteT = t - Double(noteIdx) * noteDuration
            let env = Float(exp(-noteT * 12.0))
            
            let tone = Float(sin(2.0 * .pi * noteFreq * t) + 0.3 * sin(4.0 * .pi * noteFreq * t)) * env * 0.35
            left[i] = tone
            right[i] = tone
        }
        
        playBuffer(buffer)
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Procedural Whiff / Fly Mocking laugh
    public func playWhiffSound() {
        let sampleRate = self.sampleRate
        let duration: Double = 0.30
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Sliding slide whistle descent
            let freq = 600.0 - 350.0 * (t / duration)
            let env = Float(sin(t * .pi / duration))
            let tone = Float(sin(2.0 * .pi * freq * t)) * env * 0.35
            
            left[i] = tone
            right[i] = tone
        }
        
        playBuffer(buffer)
    }
    
    private func playBuffer(_ buffer: AVAudioPCMBuffer) {
        if !audioEngine.isRunning {
            try? audioEngine.start()
        }
        sfxPlayerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !sfxPlayerNode.isPlaying {
            sfxPlayerNode.play()
        }
    }
    
    // MARK: - THE DYING VIBRATION (The Genius Touch)
    
    /// When the fly is squished and the phone is STILL CLOSED in the user's hand,
    /// triggers a frantic, decaying CoreHaptics pattern (bzzzz-bzz-bz-b...) for 1.5 seconds.
    public func triggerDyingFlyVibration() {
        guard supportsCoreHaptics, let engine = hapticEngine else {
            // Fallback for devices/simulators without advanced CoreHaptics
            triggerFallbackDyingVibration()
            return
        }
        
        do {
            // Build a sequence of dying twitch pulses with decreasing intensity and duration
            var events: [CHHapticEvent] = []
            
            // Pulse 1: Frantic death flutter (0.0s to 0.35s)
            let p1Intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let p1Sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [p1Intensity, p1Sharpness], relativeTime: 0.0, duration: 0.35))
            
            // Pulse 2: Second spasm (0.42s to 0.67s)
            let p2Intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75)
            let p2Sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [p2Intensity, p2Sharpness], relativeTime: 0.42, duration: 0.25))
            
            // Pulse 3: Weakening shudder (0.75s to 0.93s)
            let p3Intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let p3Sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [p3Intensity, p3Sharpness], relativeTime: 0.75, duration: 0.18))
            
            // Pulse 4: Final dying leg twitches (transients)
            let t1 = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ], relativeTime: 1.05)
            
            let t2 = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.20),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ], relativeTime: 1.25)
            
            let t3 = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.10),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            ], relativeTime: 1.45)
            
            events.append(contentsOf: [t1, t2, t3])
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play dying fly haptic pattern: \(error)")
            triggerFallbackDyingVibration()
        }
    }
    
    private func triggerFallbackDyingVibration() {
        // Sequential falling pulses on standard generator
        mediumImpact.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.mediumImpact.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { [weak self] in
            self?.lightImpact.impactOccurred(intensity: 0.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) { [weak self] in
            self?.lightImpact.impactOccurred(intensity: 0.3)
        }
    }
    
    public func triggerInsectLandingHaptic() {
        lightImpact.prepare()
        lightImpact.impactOccurred(intensity: 0.4)
    }
    
    public func triggerLegRubHaptic() {
        lightImpact.impactOccurred(intensity: 0.2)
    }
}
