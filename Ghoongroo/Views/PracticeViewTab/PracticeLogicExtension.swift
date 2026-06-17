import SwiftUI

extension PracticeView {
    
    // MARK: - Logic & Actions

    func setupCamera() {
        cameraManager.frameHandler = { [weak poseDetector] buffer, orientation in
            poseDetector?.processFrame(buffer, orientation: orientation)
        }
        cameraManager.checkAndStart()
    }
    
    func setupCallbacks() {
        beatManager.onPhraseCompleted = { [weak beatManager, weak poseDetector, weak session] cycleNum, startTime, endTime in
            guard let session = session, session.isPracticing else { return }
            guard let bg = beatManager, let pd = poseDetector else { return }
            
            let phrase = InsightEngine.analyzePhrase(
                cycleNumber: cycleNum,
                startTime: startTime,
                endTime: endTime,
                poseDetector: pd,
                beatManager: bg,
                taal: selectedTaal
            )
            session.recordPhrase(phrase)
        }
    }

    func startPracticeSequence() {
        // Safe to start camera now that sheet is dismissed
        setupCamera()
        
        beatManager.taal = selectedTaal
        BolSpeechManager.shared.isEnabled = bolVoiceEnabled
        
        session.startSession()

        Task { @MainActor in
            for i in stride(from: 3, through: 1, by: -1) {
                withAnimation(.spring(response: 0.3)) { session.countdown = i }
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
            }

            withAnimation {
                session.countdown = nil
                session.beginPractice()
            }
            
            // Normalize timestamps
            poseDetector.startSession(at: session.sessionStartTime)
            beatManager.sessionStartTime = session.sessionStartTime
            
            // Practice only for exactly 1 cycle
            beatManager.targetCycles = 1
            beatManager.start()
            beatManager.playAudio()
            cameraManager.startRecording()
        }
    }



    func finishPractice() {
        beatManager.stopAudio()
        
        // 1. Instantly stop heavy ML frame processing to free up CPU immediately
        cameraManager.frameHandler = nil
        
        // 2. Stop recording asynchronously in the background. The UI will stay gracefully frozen on the final pose.
        cameraManager.stopRecording { videoURL in
            DispatchQueue.main.async {
                self.session.finish(
                    poseDetector: self.poseDetector,
                    beatManager: self.beatManager,
                    taal: self.selectedTaal,
                    videoURL: videoURL
                )
            }
        }
    }

    func resetSessionLocal() {
        beatManager.reset()
        poseDetector.resetHistory()
    }
    
    func cleanupRecording(url: URL?) {
        guard let url = url else { return }
        // Attempt to remove to prevent runaway disk usage
        try? FileManager.default.removeItem(at: url)
    }
}
