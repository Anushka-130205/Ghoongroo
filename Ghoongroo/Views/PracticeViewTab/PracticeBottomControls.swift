import SwiftUI

struct PracticeBottomControls: View {
    @ObservedObject var beatManager: BeatManager
    @ObservedObject var session: PracticeSessionController
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var poseDetector: PoseDetector
    
    @Binding var bolVoiceEnabled: Bool
    var selectedTaal: Taal
    var startAction: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            if session.isPracticing {
                // Recording Indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        // Simple pulse effect
                        .opacity(session.isPracticing ? 1 : 0.3)
                        .animation(.easeInOut(duration: 0.8).repeatForever(), value: session.isPracticing)
                    
                    Text("Recording...")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                // Info Capsule
                VStack(spacing: 2) {
                    Text("Cycle \(beatManager.currentCycle + 1)")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(KathakTheme.brightGold)

                    Text("\(Int(beatManager.bpm)) BPM")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Practicing Cycle \(beatManager.currentCycle + 1) at \(Int(beatManager.bpm)) BPM")
                
                // Voice Toggle
                Button {
                    bolVoiceEnabled.toggle()
                    BolSpeechManager.shared.isEnabled = bolVoiceEnabled
                } label: {
                    Image(
                        systemName: bolVoiceEnabled
                            ? "speaker.wave.2.fill" : "speaker.slash.fill"
                    )
                    .font(KathakTheme.bodyFont)
                    .foregroundStyle(
                        bolVoiceEnabled
                            ? KathakTheme.brightGold : .white.opacity(0.6)
                    )
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(bolVoiceEnabled ? "Syllable Voice is On" : "Syllable Voice is Off")
            } else {
                // Start Practice Button
                Button(action: startAction) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(KathakTheme.subheadlineFont)
                        Text("Start Practice")
                            .font(KathakTheme.headlineFont)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .foregroundStyle(KathakTheme.deepMaroon)
                    .background(KathakTheme.goldShimmer, in: Capsule())
                    .shadow(color: KathakTheme.saffron.opacity(0.35), radius: 12, y: 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Start Live Practice Session")
            }
        }
        .padding(.bottom, 32)
        .padding(.horizontal, 16)
    }
}
