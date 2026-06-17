import Foundation
import CoreGraphics

// MARK: - Insight Engine
// Responsible for translating raw chronological pose and beat data into dancer-friendly insights.
// Uses GraceScoreEngine metrics instead of hardcoded rules.

final class InsightEngine {
    
    // MARK: - Analyze Phrase
    
    /// Analyzes a completed Taal cycle (phrase) to generate summarized insights.
    @MainActor
    static func analyzePhrase(
        cycleNumber: Int,
        startTime: TimeInterval,
        endTime: TimeInterval,
        poseDetector: PoseDetector,
        beatManager: BeatManager,
        taal: Taal
    ) -> DancePhrase {
        
        var insights: [PracticeInsight] = []
        
        // Filter history arrays to this specific time window
        let phraseFrames = poseDetector.frameHistory.filter { $0.timestamp >= startTime && $0.timestamp <= endTime }
        let phraseBeats = beatManager.beatTimestamps.filter { $0 >= startTime && $0 <= endTime }
        
        // Use GraceScoreEngine for this phrase's frames
        let engine = GraceScoreEngine(
            beatTimestamps: phraseBeats,
            beatInterval: beatManager.beatInterval
        )
        for frame in phraseFrames {
            engine.processFrame(frame)
        }
        let phraseScore = engine.computeFinalScore()
        
        // 1. Posture Stability
        if phraseScore.postureAccuracy < 70 {
            insights.append(PracticeInsight(
                timeRange: startTime...endTime,
                type: .postureInstability,
                message: "Shoulder sway increased during this cycle. Engage your core.",
                phraseIndex: cycleNumber
            ))
        } else if phraseScore.postureAccuracy > 80 {
            insights.append(PracticeInsight(
                timeRange: startTime...endTime,
                type: .steadyShoulders,
                message: "Excellent posture stability — steady frame and balanced shoulders.",
                phraseIndex: cycleNumber
            ))
        }
        
        // 2. Arm Alignment
        if phraseScore.jointAlignment > 80 {
            insights.append(PracticeInsight(
                timeRange: startTime...endTime,
                type: .gracefulArms,
                message: "Graceful arm symmetry in this cycle. Beautiful Hasta positioning.",
                phraseIndex: cycleNumber
            ))
        }
        
        // 3. Timing Drift & Perfect Sam
        if phraseBeats.count > 1 && phraseFrames.count > 5 {
            let samBeatTime = phraseBeats.first
            if let samBeatTime = samBeatTime {
                if let (closestAnkleTime, location) = findClosestMovement(history: phraseFrames, to: samBeatTime) {
                    let offset = abs(closestAnkleTime - samBeatTime)
                    if offset < 0.1 {
                        insights.append(PracticeInsight(
                            timeRange: startTime...(startTime + 1.0),
                            type: .perfectSam,
                            message: "Perfect alignment on Sam! 🎯",
                            phraseIndex: cycleNumber,
                            location: location
                        ))
                    } else if offset > 0.3 {
                        insights.append(PracticeInsight(
                            timeRange: startTime...(startTime + 1.0),
                            type: .timingDrift,
                            message: "Missed Sam: Foot strike drifted off the beat.",
                            phraseIndex: cycleNumber,
                            location: location
                        ))
                    }
                }
            }
        }
        
        // 4. Rushing Arms
        if checkRushingArms(frames: phraseFrames, beats: phraseBeats, taal: taal) {
            insights.append(PracticeInsight(
                timeRange: startTime...endTime,
                type: .rushingArms,
                message: "Rushing: Arm extension precedes foot strike. Anchor your rhythm in your feet.",
                phraseIndex: cycleNumber
            ))
        }
        
        return DancePhrase(
            cycleNumber: cycleNumber,
            startTime: startTime,
            endTime: endTime,
            stabilityScore: phraseScore.postureAccuracy,
            insights: insights
        )
    }
    
    // MARK: - Heuristic Helpers
    
    private static func findClosestMovement(
        history: [KathakFrameData],
        to targetTime: TimeInterval
    ) -> (TimeInterval, CGPoint)? {
        let movementThreshold: CGFloat = 0.015
        var movements: [(TimeInterval, CGPoint)] = []
        
        for i in 1..<history.count {
            let prev = history[i - 1]
            let curr = history[i]
            
            guard let la1 = prev.leftAnkle, let la2 = curr.leftAnkle,
                  let ra1 = prev.rightAnkle, let ra2 = curr.rightAnkle else { continue }
            
            let leftDelta  = abs(la2.y - la1.y)
            let rightDelta = abs(ra2.y - ra1.y)
            
            if leftDelta > movementThreshold || rightDelta > movementThreshold {
                let loc = leftDelta > rightDelta ? la2 : ra2
                movements.append((curr.timestamp, loc))
            }
        }
        
        return movements.min(by: { abs($0.0 - targetTime) < abs($1.0 - targetTime) })
    }
    
    private static func checkRushingArms(
        frames: [KathakFrameData],
        beats: [TimeInterval],
        taal: Taal
    ) -> Bool {
        guard frames.count > 5, !beats.isEmpty else { return false }
        
        let wristThreshold: CGFloat = 0.04
        var rushingCount = 0
        
        for (index, beatTime) in beats.enumerated() {
            let beatNum = (index % taal.totalBeats) + 1
            guard taal.accent(for: beatNum) == .taali || taal.accent(for: beatNum) == .sam else { continue }
            
            let checkWindowStart = beatTime - 0.4
            let checkWindowEnd = beatTime + 0.1
            
            let recentFrames = frames.filter { $0.timestamp >= checkWindowStart && $0.timestamp <= checkWindowEnd }
            
            guard recentFrames.count > 1 else { continue }
            
            var maxWristDelta: CGFloat = 0
            var wristPeakTime: TimeInterval?
            
            for i in 1..<recentFrames.count {
                guard let lw1 = recentFrames[i-1].leftWrist, let lw2 = recentFrames[i].leftWrist,
                      let rw1 = recentFrames[i-1].rightWrist, let rw2 = recentFrames[i].rightWrist else { continue }
                
                let delta = abs(lw2.y - lw1.y) + abs(rw2.y - rw1.y)
                if delta > maxWristDelta {
                    maxWristDelta = delta
                    wristPeakTime = recentFrames[i].timestamp
                }
            }
            
            if maxWristDelta > wristThreshold, let wpTime = wristPeakTime {
                if let (ankleTime, _) = findClosestMovement(history: frames, to: beatTime) {
                    if ankleTime - wpTime > 0.15 {
                        rushingCount += 1
                    }
                }
            }
        }
        
        return rushingCount >= 2
    }
}
