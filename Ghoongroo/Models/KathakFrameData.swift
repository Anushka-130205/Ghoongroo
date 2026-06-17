import Foundation
import CoreGraphics
import Vision

// MARK: - Dedicated Kathak Frame Structure
/// Represents a single analyzed frame containing the unified positions of all 19 Vision tracking joints.
/// Coordinates are stored with a top-left origin (SwiftUI/UIKit standard).

struct KathakFrameData {
    let timestamp: TimeInterval
    
    // Core structure
    let neck: CGPoint?
    let root: CGPoint? // Pelvis
    
    // Arms
    let leftShoulder: CGPoint?
    let rightShoulder: CGPoint?
    let leftElbow: CGPoint?
    let rightElbow: CGPoint?
    let leftWrist: CGPoint?
    let rightWrist: CGPoint?
    
    // Legs
    let leftHip: CGPoint?
    let rightHip: CGPoint?
    let leftKnee: CGPoint?
    let rightKnee: CGPoint?
    let leftAnkle: CGPoint?
    let rightAnkle: CGPoint?
    
    // Extractor helper
    init(timestamp: TimeInterval, joints: [DetectedJoint]) {
        self.timestamp = timestamp
        
        self.neck = joints.first { $0.name.contains("neck") }?.position
        self.root = joints.first { $0.name.contains("root") }?.position
        
        self.leftShoulder = joints.first { $0.name.contains("left_shoulder") }?.position
        self.rightShoulder = joints.first { $0.name.contains("right_shoulder") }?.position
        self.leftElbow = joints.first { $0.name.contains("left_elbow") }?.position
        self.rightElbow = joints.first { $0.name.contains("right_elbow") }?.position
        self.leftWrist = joints.first { $0.name.contains("left_wrist") }?.position
        self.rightWrist = joints.first { $0.name.contains("right_wrist") }?.position
        
        self.leftHip = joints.first { $0.name.contains("left_hip") }?.position
        self.rightHip = joints.first { $0.name.contains("right_hip") }?.position
        self.leftKnee = joints.first { $0.name.contains("left_knee") }?.position
        self.rightKnee = joints.first { $0.name.contains("right_knee") }?.position
        self.leftAnkle = joints.first { $0.name.contains("left_ankle") }?.position
        self.rightAnkle = joints.first { $0.name.contains("right_ankle") }?.position
    }
}
