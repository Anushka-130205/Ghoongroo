import SwiftUI

struct MicroFeedbackOverlay: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(KathakTheme.captionFont)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(KathakTheme.charcoal.opacity(0.8)))
            .padding(.bottom, 8)
            .transition(.opacity.combined(with: .scale))
    }
}

struct CountdownOverlay: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(KathakTheme.deepMaroon.opacity(0.8))
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(KathakTheme.warmGold, lineWidth: 3)
                )
                .shadow(color: KathakTheme.saffron.opacity(0.3), radius: 20)

            Text("\(count)")
                .font(KathakTheme.largeTitleFont)
                .foregroundStyle(KathakTheme.brightGold)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

struct CurrentBolDisplay: View {
    @ObservedObject var beatManager: BeatManager
    
    var body: some View {
        let bol = beatManager.currentBol
        let accent = beatManager.currentAccent

        return HStack(spacing: 8) {
            if let accent {
                Text(accent == .sam ? "X" : accent == .taali ? "+" : "O")
                    .font(KathakTheme.captionFont)
                    .foregroundStyle(accent == .sam ? KathakTheme.brightGold : .white.opacity(0.5))
                    .frame(width: 18)
            }

            Text(bol)
                .font(accent == .sam ? KathakTheme.titleFont : KathakTheme.title2Font)
                .foregroundStyle(
                    accent == .sam ? KathakTheme.brightGold :
                    accent == .taali ? KathakTheme.warmGold :
                    .white.opacity(0.9)
                )
                .animation(.spring(response: 0.15), value: beatManager.currentBeat)
                .shadow(color: accent == .sam ? KathakTheme.saffron.opacity(0.3) : .clear, radius: 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.clear)
                .overlay(
                    Capsule()
                        .stroke(
                            accent == .sam ? KathakTheme.warmGold.opacity(0.5) : .white.opacity(0.15),
                            lineWidth: 1
                        )
                )
        )
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, 6)
        .transition(.scale.combined(with: .opacity))
    }
}

struct PracticeOverlaysLayer: View {
    
    @ObservedObject var poseDetector: PoseDetector
    let isPracticing: Bool
    let selectedTaal: Taal

    var body: some View {
        GeometryReader { geometry in
            if isPracticing, let frame = poseDetector.frameHistory.last {
                let eval = GraceScoreEngine.evaluatePoseAgainstReference(frame: frame)
                
                // 0) Target Ghost Overlay
                TargetGhostOverlayView(size: geometry.size)
                
                // 1) Draw Skeleton Lines
                SkeletonPathView(frame: frame, size: geometry.size)
                    .stroke(KathakTheme.saffron.opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                
                // 2) Draw Skeleton Joints (Dots)
                SkeletonJointsView(frame: frame, size: geometry.size)
                
                // 3) Spine Feedback (rendered near Root)
                if let root = frame.root {
                    let pos = CGPoint(x: root.x * geometry.size.width, y: (1.0 - root.y) * geometry.size.height + 40)
                    feedbackBadge(error: eval.spineError, threshold: 20, name: "Spine", position: pos)
                }
                
                // 4) Arm Feedback (rendered near Left Wrist for simplicity)
                if let lWrist = frame.leftWrist {
                    let pos = CGPoint(x: lWrist.x * geometry.size.width - 40, y: (1.0 - lWrist.y) * geometry.size.height + 40)
                    feedbackBadge(error: eval.armError, threshold: 30, name: "Arms", position: pos)
                }
                
                // 5) Hips Feedback
                if let lHip = frame.leftHip {
                    let pos = CGPoint(x: lHip.x * geometry.size.width + 20, y: (1.0 - lHip.y) * geometry.size.height + 40)
                    feedbackBadge(error: eval.hipError, threshold: 25, name: "Hips", position: pos)
                }
            }
        }
    }
    
    @ViewBuilder
    private func feedbackBadge(error: Double, threshold: Double, name: String, position: CGPoint) -> some View {
        let isGood = error <= threshold
        Text(isGood ? "\(name) Good" : "\(name) Misaligned")
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isGood ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .position(position)
            .animation(.easeInOut(duration: 0.2), value: isGood)
    }
}

// MARK: - Posture Skeleton Renderers

fileprivate struct SkeletonPathView: Shape {
    let frame: KathakFrameData
    let size: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
            let points = [
                // Torso
                (frame.leftShoulder, frame.rightShoulder),
                (frame.leftShoulder, frame.leftHip),
                (frame.rightShoulder, frame.rightHip),
                (frame.leftHip, frame.rightHip),
                
                // Left Arm
                (frame.leftShoulder, frame.leftElbow),
                (frame.leftElbow, frame.leftWrist),
                
                // Right Arm
                (frame.rightShoulder, frame.rightElbow),
                (frame.rightElbow, frame.rightWrist),
                
                // Left Leg
                (frame.leftHip, frame.leftKnee),
                (frame.leftKnee, frame.leftAnkle),
                
                // Right Leg
                (frame.rightHip, frame.rightKnee),
                (frame.rightKnee, frame.rightAnkle),
                
                // Neck
                (frame.neck, frame.root)
            ]
            
            for (p1, p2) in points {
                if let p1 = p1, let p2 = p2 {
                    let cgP1 = CGPoint(x: p1.x * size.width, y: (1.0 - p1.y) * size.height)
                    let cgP2 = CGPoint(x: p2.x * size.width, y: (1.0 - p2.y) * size.height)
                    path.move(to: cgP1)
                    path.addLine(to: cgP2)
                }
            }
        
        return path
    }
}

fileprivate struct SkeletonJointsView: View {
    let frame: KathakFrameData
    let size: CGSize
    
    var body: some View {
        let allJoints: [CGPoint?] = [
            frame.neck, frame.root,
            frame.leftShoulder, frame.rightShoulder,
            frame.leftElbow, frame.rightElbow,
            frame.leftWrist, frame.rightWrist,
            frame.leftHip, frame.rightHip,
            frame.leftKnee, frame.rightKnee,
            frame.leftAnkle, frame.rightAnkle
        ]
        
        ZStack {
            ForEach(0..<allJoints.count, id: \.self) { index in
                if let joint = allJoints[index] {
                    let pos = CGPoint(x: joint.x * size.width, y: (1.0 - joint.y) * size.height)
                    Circle()
                        .fill(KathakTheme.brightGold)
                        .frame(width: 10, height: 10)
                        .position(pos)
                        .shadow(color: KathakTheme.warmGold.opacity(0.8), radius: 4)
                }
            }
        }
    }
}

// MARK: - Ghost Target Overlay
/// Draws the mathematical ideal template (from GraceScoreEngine) to visually guide the user's posture.
fileprivate struct TargetGhostOverlayView: Shape {
    let size: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define root (Pelvis approx middle bottom third)
        let root = CGPoint(x: size.width * 0.5, y: size.height * 0.65)
        
        // Spine (Straight up)
        let neck = CGPoint(x: root.x, y: root.y - (size.height * 0.35))
        
        // Shoulders (Horizontal spread)
        let shoulderW = size.width * 0.18
        let lShoulder = CGPoint(x: neck.x - shoulderW, y: neck.y)
        let rShoulder = CGPoint(x: neck.x + shoulderW, y: neck.y)
        
        // Arms (Slightly curved downwards from shoulders)
        let armLen = size.height * 0.15
        let lElbow = CGPoint(x: lShoulder.x - (armLen * 0.8), y: lShoulder.y + (armLen * 0.4))
        let rElbow = CGPoint(x: rShoulder.x + (armLen * 0.8), y: rShoulder.y + (armLen * 0.4))
        let lWrist = CGPoint(x: lElbow.x - (armLen * 0.6), y: lElbow.y + (armLen * 0.5))
        let rWrist = CGPoint(x: rElbow.x + (armLen * 0.6), y: rElbow.y + (armLen * 0.5))
        
        // Hips
        let hipW = size.width * 0.12
        let lHip = CGPoint(x: root.x - hipW, y: root.y)
        let rHip = CGPoint(x: root.x + hipW, y: root.y)
        
        // Knees (Aramandi Bend - Outwards 45 deg)
        let legLen = size.height * 0.18
        let lKnee = CGPoint(x: lHip.x - (legLen * 0.6), y: lHip.y + (legLen * 0.8))
        let rKnee = CGPoint(x: rHip.x + (legLen * 0.6), y: rHip.y + (legLen * 0.8))
        
        // Ankles (Back to center, heels touching)
        let lAnkle = CGPoint(x: root.x - 10, y: lKnee.y + (legLen * 0.7))
        let rAnkle = CGPoint(x: root.x + 10, y: rKnee.y + (legLen * 0.7))
        
        // Draw Spine
        path.move(to: root)
        path.addLine(to: neck)
        
        // Draw Shoulders
        path.move(to: lShoulder)
        path.addLine(to: rShoulder)
        
        // Left Arm
        path.move(to: lShoulder)
        path.addLine(to: lElbow)
        path.addLine(to: lWrist)
        
        // Right Arm
        path.move(to: rShoulder)
        path.addLine(to: rElbow)
        path.addLine(to: rWrist)
        
        // Hips
        path.move(to: lHip)
        path.addLine(to: rHip)
        
        // Left Leg
        path.move(to: lHip)
        path.addLine(to: lKnee)
        path.addLine(to: lAnkle)
        
        // Right Leg
        path.move(to: rHip)
        path.addLine(to: rKnee)
        path.addLine(to: rAnkle)
        
        return path
    }
    
    var body: some View {
        path(in: CGRect(origin: .zero, size: size))
            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
            .shadow(color: .white.opacity(0.4), radius: 6)
    }
}
