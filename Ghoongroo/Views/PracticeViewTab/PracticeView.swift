import SwiftUI

// MARK: - Practice View
// Main practice screen: orchestrator for camera, ML, audio, and UI

struct PracticeView: View {

    @StateObject var cameraManager = CameraManager()
    @StateObject var poseDetector = PoseDetector()
    @StateObject var beatManager = BeatManager()
    @StateObject var session = PracticeSessionController()

    @State var selectedTaal: Taal
    @State var showGuide = true
    @State var bolVoiceEnabled: Bool
    @State var navigateToResult = false

    var initialBpm: Double
    var onPopToRoot: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    init(selectedTaal: Taal = Taal.teental, initialBpm: Double = 80, initialBolVoice: Bool = true, onPopToRoot: (() -> Void)? = nil) {
        _selectedTaal = State(initialValue: selectedTaal)
        _bolVoiceEnabled = State(initialValue: initialBolVoice)
        self.initialBpm = initialBpm
        self.onPopToRoot = onPopToRoot
    }

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            if navigateToResult, let score = session.scoreResult {
                ResultView(score: score, taalName: selectedTaal.name) {
                    // Practice again (pop back to TaalVisualizerScreen - the start practicing screen)
                    cleanupRecording(url: score.videoURL)
                    session.reset()
                    resetSessionLocal()
                    withAnimation { navigateToResult = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                } onHome: {
                    // Explore More Taals (pop all the way back to PracticeEntryView - rhythm selection list)
                    cleanupRecording(url: score.videoURL)
                    session.reset()
                    resetSessionLocal()
                    withAnimation { navigateToResult = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let pop = onPopToRoot { pop() } else { dismiss() }
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            } else {
                practiceContent
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            beatManager.setupAudio()
            beatManager.bpm = initialBpm
            setupCallbacks()
            setupCamera() // Start camera preview only, wait for Start button
        }
        .onChange(of: beatManager.isComplete) { old, isComplete in
            if isComplete && session.isPracticing {
                finishPractice()
            }
        }
        .onChange(of: session.showResult) { old, new in
            if new {
                cameraManager.stop()
                withAnimation(.easeInOut(duration: 0.8)) {
                    navigateToResult = true
                }
            }
        }
        .onDisappear {
            cameraManager.stop()
            beatManager.stopPlaybackIfNeeded() // We'll add this safely
        }
        .navigationTitle(selectedTaal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        #if os(iOS)
        .toolbar {
            if !navigateToResult {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(poseDetector.isPersonDetected ? .green : .red)
                            .frame(width: 8, height: 8)
                        Text(poseDetector.isPersonDetected ? "Tracking" : "No pose")
                            .font(KathakTheme.captionFont)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
            }
        }
        #endif
    }

    // MARK: - Practice Content

    private var practiceContent: some View {
        ZStack {
            // Camera AND Overlays unified coordinate space to prevent aspect ratio desync
            ZStack {
                PracticeCameraLayer(frame: cameraManager.currentFrame)

                // ML Skeleton Overlays
                PracticeOverlaysLayer(
                    poseDetector: poseDetector,
                    isPracticing: session.isPracticing,
                    selectedTaal: selectedTaal
                )
            }
            .aspectRatio(720.0 / 1280.0, contentMode: UIDevice.current.userInterfaceIdiom == .pad ? .fit : .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
            .background(Color.black)
            .ignoresSafeArea()

            // UI overlays strictly above the camera
            VStack(spacing: 0) {
                // Top spacing for native toolbar
                Spacer().frame(height: 8)

                // Micro-feedback overlay
                Spacer()
                
                if session.isPracticing && !poseDetector.isPersonDetected {
                    MicroFeedbackOverlay(text: "Move into frame")
                }
                
                // Countdown overlay
                if let count = session.countdown {
                    CountdownOverlay(count: count)
                }

                // Current bol display during practice
                if session.isPracticing && beatManager.currentBeat > 0 {
                    CurrentBolDisplay(beatManager: beatManager)
                }

                Spacer()

                // Beat bar moved to bottom
                if session.isPracticing || beatManager.isPlaying {
                    BeatBar(beatManager: beatManager)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Bottom controls
                PracticeBottomControls(
                    beatManager: beatManager,
                    session: session,
                    cameraManager: cameraManager,
                    poseDetector: poseDetector,
                    bolVoiceEnabled: $bolVoiceEnabled,
                    selectedTaal: selectedTaal,
                    startAction: {
                        if !session.isPracticing {
                            startPracticeSequence()
                        }
                    }
                )
            }
        }
    }
}

