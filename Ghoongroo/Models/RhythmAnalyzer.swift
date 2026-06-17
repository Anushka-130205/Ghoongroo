import Foundation
import CoreGraphics

// MARK: - Rhythm Analyzer

/// Correlates detected foot-strike events with the beat grid to compute
/// rhythm synchronization score. Uses velocity spike detection on ankle joints.

struct RhythmAnalyzer {
    
    private let beatTimestamps: [TimeInterval]
    private let beatInterval: TimeInterval
    private let toleranceSeconds: Double
    
    // Detected foot-strike timestamps
    private var footStrikeTimestamps: [TimeInterval] = []
    
    // Previous frame for velocity computation
    private var previousFrame: KathakFrameData?
    
    init(beatTimestamps: [TimeInterval], beatInterval: TimeInterval, toleranceSeconds: Double = 0.25) {
        self.beatTimestamps = beatTimestamps
        self.beatInterval = beatInterval
        self.toleranceSeconds = toleranceSeconds
    }
    
    // MARK: - Process Frame
    
    mutating func processFrame(_ frame: KathakFrameData) {
        defer { previousFrame = frame }
        
        guard let prev = previousFrame else { return }
        
        // Detect foot strike: sudden downward velocity spike in either ankle
        let leftStrike = detectStrike(prevAnkle: prev.leftAnkle, currAnkle: frame.leftAnkle)
        let rightStrike = detectStrike(prevAnkle: prev.rightAnkle, currAnkle: frame.rightAnkle)
        
        if leftStrike || rightStrike {
            footStrikeTimestamps.append(frame.timestamp)
        }
    }
    
    // MARK: - Detect Foot Strike
    
    private func detectStrike(prevAnkle: CGPoint?, currAnkle: CGPoint?) -> Bool {
        guard let prev = prevAnkle, let curr = currAnkle else { return false }
        
        // Downward velocity (Y decreases in screen coords = foot going down)
        let velocityY = Double(curr.y - prev.y)
        
        // A strike is a sudden downward movement exceeding a dynamic threshold
        // Using absolute velocity > 0.02 normalized units per frame
        return abs(velocityY) > 0.02
    }
    
    // MARK: - Compute Rhythm Score
    
    func computeRhythmScore() -> Double {
        guard !beatTimestamps.isEmpty else { return 50.0 }
        guard footStrikeTimestamps.count > 2 else { return 30.0 }
        
        var totalError: Double = 0
        var matchedBeats: Int = 0
        
        for beatTime in beatTimestamps {
            // Find the closest foot strike to this beat
            var closestDistance = Double.infinity
            
            for strikeTime in footStrikeTimestamps {
                let distance = abs(strikeTime - beatTime)
                if distance < closestDistance {
                    closestDistance = distance
                }
            }
            
            // Only count if within tolerance window
            if closestDistance <= toleranceSeconds {
                // Normalize error: 0 = perfect, 1 = at tolerance boundary
                let normalizedError = closestDistance / toleranceSeconds
                totalError += normalizedError
                matchedBeats += 1
            }
        }
        
        guard matchedBeats > 0 else { return 20.0 }
        
        let avgError = totalError / Double(matchedBeats)
        let matchRatio = Double(matchedBeats) / Double(beatTimestamps.count)
        
        // Score = (1 - avgError) * 60% + matchRatio * 40%
        let score = ((1.0 - avgError) * 0.6 + min(matchRatio, 1.0) * 0.4) * 100.0
        return max(20.0, min(100.0, score))
    }
}
