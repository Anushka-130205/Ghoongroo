import Foundation
import CoreGraphics
import SwiftUI
import Combine

@MainActor
final class PracticeSessionController: ObservableObject {

    @Published var isPracticing = false
    @Published var countdown: Int?
    @Published var showResult = false
    @Published var scoreResult: ScoreResult?

    var sessionStartTime: TimeInterval?
    var dancePhrases: [DancePhrase] = []

    func startSession() {
        countdown = 3
        dancePhrases.removeAll()
        sessionStartTime = nil
    }

    func beginPractice() {
        isPracticing = true
        sessionStartTime = CACurrentMediaTime()
    }

    func recordPhrase(_ phrase: DancePhrase) {
        dancePhrases.append(phrase)
    }

    func finish(
        poseDetector: PoseDetector,
        beatManager: BeatManager,
        taal: Taal,
        videoURL: URL?
    ) {
        let bpm = beatManager.bpm
        let timestamps = beatManager.beatTimestamps
        let frames = poseDetector.frameHistory
        let practiceStartTime = sessionStartTime

        // This Task inherits MainActor context
        Task {
            // Run scoring off main thread to prevent hang during transition
            let score = await Task.detached {
                let engine = GraceScoreEngine(
                    beatTimestamps: timestamps,
                    beatInterval: 60.0 / bpm
                )
                
                // Downsample frames to process 1/5th to guarantee instant math computation
                // 10-15 FPS is more than enough for accurate human movement analysis.
                for i in stride(from: 0, to: frames.count, by: 5) {
                    engine.processFrame(frames[i])
                }
                
                return engine.computeFinalScore(videoURL: videoURL)
            }.value
            
            // Back on MainActor, safely update state
            self.scoreResult = score
            self.showResult = true
            self.isPracticing = false

            // Save session data to persistent storage
            let duration: Double
            if let start = practiceStartTime {
                duration = CACurrentMediaTime() - start
            } else {
                // Estimate from beat count and BPM
                duration = Double(taal.totalBeats) * (60.0 / bpm)
            }

            let statsManager = DashboardStatsManager()
            statsManager.recordPractice(
                score: score.graceScore,
                durationSeconds: duration,
                taalId: taal.id,
                taalName: taal.name,
                scoreResult: score
            )
        }
    }

    func reset() {
        isPracticing = false
        countdown = nil
        showResult = false
        scoreResult = nil
        dancePhrases.removeAll()
        sessionStartTime = nil
    }
}
