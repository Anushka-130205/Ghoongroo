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
    let nose: CGPoint?
    let leftEye: CGPoint?
    let rightEye: CGPoint?
    
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
        self.nose = joints.first { $0.name.contains("nose") }?.position
        self.leftEye = joints.first { $0.name.contains("left_eye") }?.position
        self.rightEye = joints.first { $0.name.contains("right_eye") }?.position
        
        self.leftShoulder = joints.first { $0.name.contains("left_shoulder") }?.position
        self.rightShoulder = joints.first { $0.name.contains("right_shoulder") }?.position
        self.leftElbow = joints.first { $0.name.contains("left_forearm") }?.position
        self.rightElbow = joints.first { $0.name.contains("right_forearm") }?.position
        self.leftWrist = joints.first { $0.name.contains("left_hand") }?.position
        self.rightWrist = joints.first { $0.name.contains("right_hand") }?.position
        
        self.leftHip = joints.first { $0.name.contains("left_upLeg") }?.position
        self.rightHip = joints.first { $0.name.contains("right_upLeg") }?.position
        self.leftKnee = joints.first { $0.name.contains("left_leg") }?.position
        self.rightKnee = joints.first { $0.name.contains("right_leg") }?.position
        self.leftAnkle = joints.first { $0.name.contains("left_foot") }?.position
        self.rightAnkle = joints.first { $0.name.contains("right_foot") }?.position
    }
}
