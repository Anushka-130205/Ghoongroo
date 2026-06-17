import SwiftUI
import Combine
import Vision

// MARK: - Detected Joint

struct DetectedJoint: Identifiable {
    let id = UUID()
    let name: String
    let position: CGPoint      // Normalized 0…1 (Vision coordinates)
    let confidence: Float
}

// MARK: - Pose Detector
// Uses Vision framework VNDetectHumanBodyPoseRequest to detect body joints

@MainActor
final class PoseDetector: ObservableObject {

    @Published var detectedJoints: [DetectedJoint] = []
    @Published var isPersonDetected = false

    // Tracked joint names for Kathak analysis
    private let trackedJoints: [VNHumanBodyPoseObservation.JointName] = [
        .nose, .leftEye, .rightEye,
        .neck, .root,
        .leftShoulder, .rightShoulder,
        .leftElbow, .rightElbow,
        .leftWrist, .rightWrist,
        .leftHip, .rightHip,
        .leftKnee, .rightKnee,
        .leftAnkle, .rightAnkle
    ]

    private let confidenceThreshold: Float = 0.3
    
    // Reusable Vision request (avoids per-frame allocation)
    private nonisolated(unsafe) let poseRequest = VNDetectHumanBodyPoseRequest()
    
    // Frame throttling: only run ML every Nth frame
    private nonisolated(unsafe) var mlFrameCount: Int = 0
    private let mlFrameSkip: Int = 4

    // Session timing reference
    var sessionStartTime: TimeInterval?

    // History for scoring
    var frameHistory: [KathakFrameData] = []

    // MARK: - Process Frame

    nonisolated func processFrame(_ sampleBuffer: CMSampleBuffer, orientation: CGImagePropertyOrientation = .up) {
        // Throttle: only run ML inference on every Nth frame
        mlFrameCount += 1
        guard mlFrameCount % mlFrameSkip == 0 else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])

        do {
            try handler.perform([poseRequest])

            guard let observation = poseRequest.results?.first else {
                Task { @MainActor [weak self] in
                    self?.detectedJoints = []
                    self?.isPersonDetected = false
                }
                return
            }

            let joints = extractJoints(from: observation)

            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.detectedJoints = joints
                self.isPersonDetected = !joints.isEmpty
                
                // Record history for scoring
                self.recordHistory(from: joints)
            }

        } catch {
            // Silently skip this frame
        }
    }

    // MARK: - Extract Joints

    nonisolated private func extractJoints(from observation: VNHumanBodyPoseObservation) -> [DetectedJoint] {
        var joints: [DetectedJoint] = []

        for jointName in trackedJoints {
            guard let point = try? observation.recognizedPoint(jointName),
                  point.confidence > confidenceThreshold else { continue }

            // Vision coordinates: origin bottom-left, Y up
            // Convert to top-left origin for SwiftUI
            let position = CGPoint(x: point.location.x, y: 1 - point.location.y)

            joints.append(DetectedJoint(
                name: jointName.rawValue.rawValue,
                position: position,
                confidence: point.confidence
            ))
        }

        return joints
    }

    // MARK: - Session Management
    
    func startSession(at time: TimeInterval?) {
        sessionStartTime = time
        resetHistory()
    }

    // MARK: - Record History for Scoring

    private func recordHistory(from joints: [DetectedJoint]) {
        let relativeTime: TimeInterval
        if let sessionStart = sessionStartTime {
            relativeTime = CACurrentMediaTime() - sessionStart
        } else {
            relativeTime = 0
        }

        let frameData = KathakFrameData(timestamp: relativeTime, joints: joints)
        frameHistory.append(frameData)
        
        // Keep last 300 entries (approx 10-15 seconds at 30fps) to prevent unbounded memory growth during long sessions
        if frameHistory.count > 300 {
            frameHistory.removeFirst()
        }
    }

    // MARK: - Reset

    func resetHistory() {
        frameHistory.removeAll()
    }

    // MARK: - Helper: Get Joint Position by Name

    func jointPosition(named name: String) -> CGPoint? {
        detectedJoints.first { $0.name.contains(name) }?.position
    }
}
