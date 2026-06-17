import AVFoundation
import Combine
import AudioToolbox
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Taal Sound Engine
// Synthesizes realistic tabla-like percussive tones using AVAudioEngine
// Models authentic Kathak sounds: Dha (deep), Na (sharp), Tin (bright), Ta (crisp)

final class TaalSoundEngine: ObservableObject, @unchecked Sendable {

    private var audioEngine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?

    // Multi-voice synthesis state (accessed from audio render thread)
    private var voices: [SynthVoice] = []
    private let maxVoices = 4
    private let sampleRate: Double = 44100

    @Published var isEngineRunning = false

    // MARK: - Synth Voice (single percussion hit)

    private final class SynthVoice {
        init() {}
        var active: Bool = false

        // Primary tone (tabla membrane)
        var freq1: Float = 0
        var phase1: Float = 0

        // Secondary overtone
        var freq2: Float = 0
        var phase2: Float = 0

        // Tertiary shimmer tone
        var freq3: Float = 0
        var phase3: Float = 0

        // Amplitudes and mix
        var amp1: Float = 0
        var amp2: Float = 0
        var amp3: Float = 0

        // Envelope
        var samplesRemaining: Int = 0
        var totalSamples: Int = 1
        var attackSamples: Int = 0
        var decayRate: Float = 1.0

        // Noise component (for attack transient)
        var noiseAmp: Float = 0
        var noiseDecay: Float = 0.99
    }

    // MARK: - Sound Presets (Authentic Tabla Timbres)

    private struct TablaPreset {
        let freq1: Float       // Fundamental
        let freq2: Float       // First overtone
        let freq3: Float       // Shimmer/resonance
        let amp1: Float        // Fundamental volume
        let amp2: Float        // Overtone volume
        let amp3: Float        // Shimmer volume
        let noiseAmp: Float    // Attack transient noise
        let noiseDecay: Float  // How fast noise fades
        let durationMs: Int    // Total duration
        let decayRate: Float   // Overall decay
        let attackMs: Int      // Attack time
    }

    // Dha — deep, resonant "duggi" (bass drum) sound for Sam beat
    private let dhaPreset = TablaPreset(
        freq1: 90, freq2: 135, freq3: 180,
        amp1: 0.50, amp2: 0.25, amp3: 0.12,
        noiseAmp: 0.35, noiseDecay: 0.985,
        durationMs: 280, decayRate: 0.99985, attackMs: 3
    )

    // Na — sharp, bright "dayan" (right drum) slap for Taali
    private let naPreset = TablaPreset(
        freq1: 320, freq2: 480, freq3: 640,
        amp1: 0.40, amp2: 0.20, amp3: 0.10,
        noiseAmp: 0.25, noiseDecay: 0.992,
        durationMs: 150, decayRate: 0.9996, attackMs: 2
    )

    // Tin — clean, bell-like ring for Khaali beats
    private let tinPreset = TablaPreset(
        freq1: 440, freq2: 660, freq3: 880,
        amp1: 0.30, amp2: 0.15, amp3: 0.08,
        noiseAmp: 0.10, noiseDecay: 0.995,
        durationMs: 180, decayRate: 0.9997, attackMs: 2
    )

    // Ta — light finger tap for regular beats
    private let taPreset = TablaPreset(
        freq1: 500, freq2: 750, freq3: 1000,
        amp1: 0.18, amp2: 0.08, amp3: 0.04,
        noiseAmp: 0.08, noiseDecay: 0.996,
        durationMs: 80, decayRate: 0.9993, attackMs: 1
    )

    // MARK: - Lifecycle

    func start() {
        guard audioEngine == nil else { return }

        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            // Use .ambient to coexist with camera (does NOT require microphone permission)
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[TaalSoundEngine] Audio session error: \(error)")
        }
        #endif

        // Initialize voice pool with distinct class instances
        voices = (0..<maxVoices).map { _ in SynthVoice() }

        let engine = AVAudioEngine()
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            print("[TaalSoundEngine] Could not create audio format")
            return
        }

        let sr = Float(sampleRate)
        let source = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, bufferList -> OSStatus in
            guard let self = self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(bufferList)
            let buffer = ablPointer[0]
            let frames = Int(frameCount)

            guard let data = buffer.mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }

            for i in 0..<frames {
                var mixedSample: Float = 0

                for v in 0..<self.voices.count {
                    guard self.voices[v].active else { continue }

                    let voice = self.voices[v]

                    // Attack envelope (fast ramp up)
                    let attackEnv: Float
                    let elapsed = voice.totalSamples - voice.samplesRemaining
                    if elapsed < voice.attackSamples {
                        attackEnv = Float(elapsed) / Float(max(voice.attackSamples, 1))
                    } else {
                        attackEnv = 1.0
                    }

                    // Generate multi-harmonic tone
                    let s1 = sin(voice.phase1) * voice.amp1
                    let s2 = sin(voice.phase2) * voice.amp2
                    let s3 = sin(voice.phase3) * voice.amp3

                    // Noise burst for attack transient
                    let noise = voice.noiseAmp * Float.random(in: -1...1)

                    let sample = (s1 + s2 + s3 + noise) * attackEnv
                    mixedSample += sample

                    // Advance phases
                    self.voices[v].phase1 += 2.0 * .pi * voice.freq1 / sr
                    self.voices[v].phase2 += 2.0 * .pi * voice.freq2 / sr
                    self.voices[v].phase3 += 2.0 * .pi * voice.freq3 / sr

                    // Wrap phases
                    if self.voices[v].phase1 > 2.0 * .pi { self.voices[v].phase1 -= 2.0 * .pi }
                    if self.voices[v].phase2 > 2.0 * .pi { self.voices[v].phase2 -= 2.0 * .pi }
                    if self.voices[v].phase3 > 2.0 * .pi { self.voices[v].phase3 -= 2.0 * .pi }

                    // Decay
                    self.voices[v].amp1 *= voice.decayRate
                    self.voices[v].amp2 *= voice.decayRate
                    self.voices[v].amp3 *= voice.decayRate
                    self.voices[v].noiseAmp *= voice.noiseDecay

                    // Pitch bend down slightly for realism (tabla membrane relaxation)
                    let progress = 1.0 - (Float(voice.samplesRemaining) / Float(max(voice.totalSamples, 1)))
                    if progress > 0.3 {
                        self.voices[v].freq1 *= 0.99998
                    }

                    self.voices[v].samplesRemaining -= 1
                    if self.voices[v].samplesRemaining <= 0 {
                        self.voices[v].active = false
                    }
                }

                // Soft clip to prevent distortion
                mixedSample = tanh(mixedSample * 1.5) * 0.7
                data[i] = mixedSample
            }

            return noErr
        }

        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            audioEngine = engine
            sourceNode = source
            Task { @MainActor [weak self] in self?.isEngineRunning = true }
        } catch {
            print("[TaalSoundEngine] Engine start failed: \(error)")
        }
    }

    func stop() {
        audioEngine?.stop()
        audioEngine = nil
        sourceNode = nil
        isEngineRunning = false
    }

    // MARK: - Play Beat Sound

    /// Play a realistic tabla tone based on the beat's accent type
    func playBeat(accent: Taal.BeatAccent?) {
        let preset: TablaPreset
        switch accent {
        case .sam:    preset = dhaPreset
        case .taali:  preset = naPreset
        case .khaali: preset = tinPreset
        case .none:   preset = taPreset
        }

        // Find an available voice slot (steal oldest if all busy)
        var slotIndex = 0
        for i in 0..<voices.count {
            if !voices[i].active {
                slotIndex = i
                break
            }
            if voices[i].samplesRemaining < voices[slotIndex].samplesRemaining {
                slotIndex = i
            }
        }

        let totalSamples = Int(sampleRate * Double(preset.durationMs) / 1000.0)
        let attackSamples = Int(sampleRate * Double(preset.attackMs) / 1000.0)

        let voice = voices[slotIndex]
        voice.active = true
        voice.freq1 = preset.freq1; voice.phase1 = 0
        voice.freq2 = preset.freq2; voice.phase2 = 0
        voice.freq3 = preset.freq3; voice.phase3 = 0
        voice.amp1 = preset.amp1; voice.amp2 = preset.amp2; voice.amp3 = preset.amp3
        voice.samplesRemaining = totalSamples
        voice.totalSamples = totalSamples
        voice.attackSamples = attackSamples
        voice.decayRate = preset.decayRate
        voice.noiseAmp = preset.noiseAmp
        voice.noiseDecay = preset.noiseDecay
    }

    // MARK: - Haptics

    #if os(iOS)
    @MainActor func triggerHaptic(accent: Taal.BeatAccent?) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        switch accent {
        case .sam:    style = .heavy
        case .taali:  style = .medium
        case .khaali: style = .light
        case .none:   return
        }
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.prepare()
        gen.impactOccurred()
    }
    #endif

    deinit {
        audioEngine?.stop()
    }
}

