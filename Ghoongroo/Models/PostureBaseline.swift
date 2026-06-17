import Foundation
import CoreGraphics

// MARK: - Posture Baseline (Statistical Calibration Model)

/// Instead of a pre-trained CoreML model, we build a statistical reference model
/// from the first few seconds of practice. This captures the dancer's "ideal" joint
/// angles, then scores subsequent frames by z-score deviation from that baseline.

struct PostureBaseline {
    
    private let calibrationWindow: TimeInterval
    private var calibrationAngles: [[String: Double]] = []
    private var baselineStartTime: TimeInterval?
    
    // Calibrated statistics
    private(set) var meanAngles: [String: Double] = [:]
    private(set) var stdDevAngles: [String: Double] = [:]
    private(set) var isCalibrated = false
    
    init(calibrationWindow: TimeInterval = 3.0) {
        self.calibrationWindow = calibrationWindow
    }
    
    // MARK: - Feed Frames
    
    mutating func addFrame(_ frame: KathakFrameData) {
        if baselineStartTime == nil {
            baselineStartTime = frame.timestamp
        }
        
        guard !isCalibrated else { return }
        
        let elapsed = frame.timestamp - (baselineStartTime ?? frame.timestamp)
        
        if elapsed < calibrationWindow {
            // Accumulate angles during calibration
            let angles = extractAngles(from: frame)
            if !angles.isEmpty {
                calibrationAngles.append(angles)
            }
        } else {
            // Calibration complete — compute statistics
            computeBaseline()
        }
    }
    
    // MARK: - Compute Baseline Statistics
    
    private mutating func computeBaseline() {
        guard calibrationAngles.count > 3 else {
            // Not enough data — use neutral defaults
            meanAngles = ["spine": 0, "leftElbow": 160, "rightElbow": 160, "leftKnee": 170, "rightKnee": 170, "shoulderTilt": 0]
            stdDevAngles = ["spine": 5, "leftElbow": 15, "rightElbow": 15, "leftKnee": 15, "rightKnee": 15, "shoulderTilt": 3]
            isCalibrated = true
            return
        }
        
        // Collect all keys present
        let allKeys = Set(calibrationAngles.flatMap { $0.keys })
        
        for key in allKeys {
            let values = calibrationAngles.compactMap { $0[key] }
            guard values.count > 1 else { continue }
            
            let mean = values.reduce(0, +) / Double(values.count)
            let variance = values.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(values.count - 1)
            let stdDev = max(sqrt(variance), 1.0) // Floor at 1 degree to avoid division by zero
            
            meanAngles[key] = mean
            stdDevAngles[key] = stdDev
        }
        
        isCalibrated = true
    }
    
    // MARK: - Score Deviation
    
    /// Returns a 0–100 score based on how close the given angles are to the baseline.
    func scoreDeviation(angles: [String: Double], maxDev: Double) -> Double {
        guard isCalibrated else { return 50.0 }
        
        var totalScore: Double = 0
        var count: Int = 0
        
        for (key, value) in angles {
            guard let mean = meanAngles[key], let std = stdDevAngles[key] else { continue }
            
            // Z-score: how many standard deviations away
            let zScore = abs(value - mean) / std
            
            // Convert z-score to 0–1 score (z=0 → 1.0, z >= maxDev/std → 0.0)
            let maxZ = maxDev / std
            let frameScore = max(0, 1.0 - zScore / maxZ)
            
            totalScore += frameScore
            count += 1
        }
        
        guard count > 0 else { return 50.0 }
        return (totalScore / Double(count)) * 100.0
    }
    
    // MARK: - Angle Extraction (same as GraceScoreEngine)
    
    private func extractAngles(from frame: KathakFrameData) -> [String: Double] {
        var angles: [String: Double] = [:]
        
        if let neck = frame.neck, let root = frame.root {
            let dx = Double(neck.x - root.x)
            let dy = Double(neck.y - root.y)
            angles["spine"] = atan2(dx, dy) * 180.0 / .pi
        }
        
        if let ls = frame.leftShoulder, let le = frame.leftElbow, let lw = frame.leftWrist {
            angles["leftElbow"] = angleBetween(a: ls, b: le, c: lw)
        }
        
        if let rs = frame.rightShoulder, let re = frame.rightElbow, let rw = frame.rightWrist {
            angles["rightElbow"] = angleBetween(a: rs, b: re, c: rw)
        }
        
        if let lh = frame.leftHip, let lk = frame.leftKnee, let la = frame.leftAnkle {
            angles["leftKnee"] = angleBetween(a: lh, b: lk, c: la)
        }
        
        if let rh = frame.rightHip, let rk = frame.rightKnee, let ra = frame.rightAnkle {
            angles["rightKnee"] = angleBetween(a: rh, b: rk, c: ra)
        }
        
        if let ls = frame.leftShoulder, let rs = frame.rightShoulder {
            angles["shoulderTilt"] = atan2(Double(ls.y - rs.y), Double(ls.x - rs.x)) * 180.0 / .pi
        }
        
        return angles
    }
    
    private func angleBetween(a: CGPoint, b: CGPoint, c: CGPoint) -> Double {
        let v1 = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let v2 = CGPoint(x: c.x - b.x, y: c.y - b.y)
        
        let dot = Double(v1.x * v2.x + v1.y * v2.y)
        let mag1 = sqrt(Double(v1.x * v1.x + v1.y * v1.y))
        let mag2 = sqrt(Double(v2.x * v2.x + v2.y * v2.y))
        guard mag1 > 0 && mag2 > 0 else { return 180.0 }
        
        let cosAngle = max(-1.0, min(1.0, dot / (mag1 * mag2)))
        return acos(cosAngle) * 180.0 / .pi
    }
}
