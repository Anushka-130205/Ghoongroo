import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif
import AVFoundation

// MARK: - Beat Manager
// Drives a rhythmic cycle for any Taal with programmatic audio and haptics

@MainActor
final class BeatManager: ObservableObject {

    // MARK: Published State

    @Published var currentBeat: Int = 0          // 1–N, 0 = stopped
    @Published var isPlaying = false
    @Published var currentCycle: Int = 0         // Full cycles completed
    @Published var elapsedBeats: Int = 0         // Total beats played
    
    // Callback when a phrase completes
    var onPhraseCompleted: ((_ cycleNumber: Int, _ startTime: TimeInterval, _ endTime: TimeInterval) -> Void)?

    // MARK: Configuration

    @Published var taal: Taal = .teental         // Configurable taal
    var bpm: Double = 80
    var targetCycles: Int = 1
    
    // Session timing reference
    var sessionStartTime: TimeInterval?

    // Beat timestamps for scoring (relative to sessionStartTime)
    var beatTimestamps: [TimeInterval] = []

    // MARK: Private

    private var beatTimer: Timer?
    private let soundEngine = TaalSoundEngine()

    // MARK: - Computed

    var totalBeats: Int { taal.totalBeats }

    var beatInterval: TimeInterval {
        60.0 / bpm
    }

    var isSam: Bool {
        currentBeat == 1
    }

    var currentBol: String {
        guard currentBeat >= 1 && currentBeat <= totalBeats else { return "" }
        return taal.bols[currentBeat - 1]
    }

    var currentAccent: Taal.BeatAccent? {
        taal.accent(for: currentBeat)
    }

    var isComplete: Bool {
        currentCycle >= targetCycles
    }

    var progress: Double {
        guard targetCycles > 0 else { return 0 }
        if targetCycles == Int.max { return 0.0 } // Prevent Int.max * totalBeats integer overflow crash
        let totalTarget = targetCycles * totalBeats
        return min(Double(elapsedBeats) / Double(totalTarget), 1.0)
    }

    // MARK: - Controls

    func start() {
        guard !isPlaying else { return }

        currentBeat = 0
        currentCycle = 0
        elapsedBeats = 0
        beatTimestamps.removeAll()
        isPlaying = true

        beatTimer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceBeat()
            }
        }
    }

    func stop() {
        beatTimer?.invalidate()
        beatTimer = nil
        isPlaying = false
        soundEngine.stop()
        BolSpeechManager.shared.stop()
    }

    func stopPlaybackIfNeeded() {
        stop()
    }

    func reset() {
        stop()
        currentBeat = 0
        currentCycle = 0
        elapsedBeats = 0
        beatTimestamps.removeAll()
        sessionStartTime = nil
    }

    // MARK: - Audio Setup / Play / Stop

    func setupAudio() {
        #if os(iOS)
        do {
            // Use .ambient to coexist with camera (does NOT require microphone permission)
            try AVAudioSession.sharedInstance().setCategory(
                .ambient, mode: .default, options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[BeatManager] Audio session error: \(error)")
        }
        #endif
    }

    func playAudio() {
        soundEngine.start()
    }

    func stopAudio() {
        soundEngine.stop()
    }

    // MARK: - Beat Logic

    private func advanceBeat() {
        let nextBeat = (currentBeat % totalBeats) + 1
        currentBeat = nextBeat
        elapsedBeats += 1
        
        if let sessionStart = sessionStartTime {
            let relativeTime = CACurrentMediaTime() - sessionStart
            beatTimestamps.append(relativeTime)
        } else {
            // If sessionStartTime not set, use 0 or something safe, but ideally it should be set right before start()
            beatTimestamps.append(0)
        }

        // Play sound for this beat via synth engine
        let accent = taal.accent(for: nextBeat)
        soundEngine.playBeat(accent: accent)

        // Speak the bol syllable aloud conditionally
        if BolSpeechManager.shared.isEnabled {
            let bol = taal.bols[nextBeat - 1]
            BolSpeechManager.shared.speakBol(bol)
        }

        // Haptic feedback on structural beats
        #if os(iOS)
        switch accent {
        case .sam:
            triggerHaptic(style: .heavy)
        case .taali:
            triggerHaptic(style: .medium)
        case .khaali:
            triggerHaptic(style: .light)
        case nil:
            break
        }
        #endif

        // Cycle tracking
        if nextBeat == 1 && elapsedBeats > 1 {
            currentCycle = (elapsedBeats - 1) / totalBeats
            
            // Emit phrase completion event
            let phraseBeats = beatTimestamps.suffix(totalBeats)
            if let firstBeat = phraseBeats.first, let lastBeat = phraseBeats.last {
                onPhraseCompleted?(currentCycle, firstBeat, lastBeat)
            }
        }

        // Check completion
        if isComplete {
            stop()
        }
    }

    // MARK: - Haptics

    #if os(iOS)
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    #endif
}
