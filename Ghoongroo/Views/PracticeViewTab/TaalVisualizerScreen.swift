import SwiftUI
import AVFoundation

// MARK: - Taal Visualizer Screen
// Full-page screen between the Info Sheet and live practice.
// User sees the circular beat visualizer, selects BPM, then starts practice.

struct TaalVisualizerScreen: View {

    let taal: Taal
    var onPopToRoot: (() -> Void)?

    @State private var bpm: Double = 80
    @State private var currentBeat = 0
    @State private var isPlaying = false
    @State private var beatTimer: Timer?
    @State private var animateIn = false
    @State private var bolVoiceEnabled = true
    @StateObject private var soundEngine = TaalSoundEngine()

    @State private var navigateToPractice = false
    @State private var showInfoSheet = false

    // Camera Permission State
    @State private var showCameraDeniedAlert = false
    
    @Environment(\.dismiss) private var dismiss

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isCompact: Bool { verticalSizeClass == .compact }

    private var taalAccentColor: Color {
        switch taal.id {
        case "teental": return KathakTheme.warmGold
        case "jhaptal":  return KathakTheme.terracotta
        case "ektaal":   return KathakTheme.saffron
        default:         return KathakTheme.warmGold
        }
    }

    private var taalSubheading: String {
        switch taal.id {
        case "teental": return "Sixteen Beat Visualizer"
        case "jhaptal":  return "Ten Beat Visualizer"
        case "ektaal":   return "Twelve Beat Visualizer"
        default:         return "\(taal.totalBeats) Beat Visualizer"
        }
    }

    var body: some View {
        ZStack {
            // Background
            KathakTheme.backgroundGradient.ignoresSafeArea()
            
            // Subtle depth glow
            RadialGradient(
                colors: [taalAccentColor.opacity(0.15), .clear],
                center: .center,
                startRadius: 50,
                endRadius: 350
            ).ignoresSafeArea()
            
            ParticleField(count: 12).ignoresSafeArea().opacity(0.4)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) { 

                        // Top Header Area
                        VStack(spacing: 6) {
                            Text(taalSubheading)
                                .font(KathakTheme.headlineFont)
                                .foregroundStyle(KathakTheme.softBeige.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Follow the rhythmic cycle before starting live AI practice.")
                                .font(KathakTheme.subheadlineFont)
                                .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, isCompact ? 12 : 24)
                        .padding(.bottom, 32)
                        
                        // Circular beat visualizer
                        beatVisualizer
                            .padding(.bottom, 40) 

                        // Audio Controls Box
                        audioControlsPanel
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                        
                        // Start Practice CTA
                        startPracticeButton
                    }
                    .padding(.bottom, isCompact ? 24 : 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { animateIn = true }
        }
        .onDisappear {
            stopPlayback()
        }
        .navigationDestination(isPresented: $navigateToPractice) {
            PracticeView(selectedTaal: taal, initialBpm: bpm, initialBolVoice: bolVoiceEnabled, onPopToRoot: onPopToRoot)
        }
        .sheet(isPresented: $showInfoSheet) {
            TaalInfoSheet(taal: taal) {
                // Info sheet continue action
            }
        }
        .alert("Camera Access Required", isPresented: $showCameraDeniedAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Ghoongroo needs camera access to analyze your posture and provide AI feedback.")
        }
        .navigationTitle(taal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showInfoSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(KathakTheme.bodyFont)
                        .foregroundStyle(KathakTheme.warmGold)
                }
            }
        }
        #endif
    }

    // MARK: - Circular Beat Visualizer

    private var beatVisualizer: some View {
        let size: CGFloat = isCompact ? 220 : 300
        let radius: CGFloat = size * 0.38

        return VStack(spacing: 12) {
            ZStack {
                // Outer accent ring with glow
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [taalAccentColor.opacity(0.3), taalAccentColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: size + 20, height: size + 20)
                    .shadow(color: taalAccentColor.opacity(0.2), radius: 20)

                // Nodes
                ForEach(0..<taal.totalBeats, id: \.self) { index in
                    let beat = index + 1
                    let angle = Double(index) / Double(taal.totalBeats) * 360.0 - 90.0
                    let radians = angle * .pi / 180
                    let x = cos(radians) * Double(radius)
                    let y = sin(radians) * Double(radius)
                    let accent = taal.accent(for: beat)
                    let isCurrent = beat == currentBeat && isPlaying
                    
                    let nodeSize: CGFloat = isCurrent ? 42 : (accent != nil ? 32 : 24)

                    // Node View
                    ZStack {
                        // Background Circle
                        Circle()
                            .fill(isCurrent ? KathakTheme.brightGold : nodeBackground(accent))
                            .shadow(color: isCurrent ? KathakTheme.warmGold.opacity(0.8) : .clear, radius: isCurrent ? 10 : 0)
                            .overlay(Circle().stroke(isCurrent ? Color.white : nodeStroke(accent), lineWidth: isCurrent ? 2 : 0.5))
                        
                        // Text
                        Text(taal.bols[index])
                            .font(isCurrent ? KathakTheme.headlineFont : KathakTheme.captionFont)
                            .foregroundStyle(isCurrent ? KathakTheme.deepMaroon : nodeTextColor(accent))
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .padding(.horizontal, 2)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(isCurrent ? "Current Beat \(beat). \(taal.bols[index])" : "Beat \(beat). \(taal.bols[index])")
                    .accessibilityAddTraits(isCurrent ? .isSelected : [])
                    .frame(width: nodeSize, height: nodeSize)
                    .scaleEffect(isCurrent ? 1.15 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isCurrent)
                    .offset(x: x, y: y)
                }

                // Center display (Bigger, clearer fonts)
                VStack(spacing: 4) {
                    if isPlaying && currentBeat > 0 && currentBeat <= taal.totalBeats {
                        Text(taal.bols[currentBeat - 1])
                            .font(KathakTheme.largeTitleFont)
                            .foregroundStyle(KathakTheme.brightGold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .animation(.spring, value: currentBeat)
                        
                        Text("Beat \(currentBeat)")
                            .font(KathakTheme.title3Font)
                            .foregroundStyle(KathakTheme.softBeige.opacity(0.7))
                    } else {
                        Image(systemName: taal.icon)
                            .font(KathakTheme.largeTitleFont)
                            .foregroundStyle(taalAccentColor.opacity(0.5))
                            .padding(.bottom, 4)
                        
                        Text(taal.name)
                            .font(KathakTheme.title2Font)
                            .foregroundStyle(KathakTheme.softBeige)
                    }
                }
                .frame(width: size * 0.55, height: size * 0.55)
            }
            .frame(width: size + 20, height: size + 20)
            .frame(maxWidth: .infinity)
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 20)
            .animation(.easeOut(duration: 0.6), value: animateIn)
        }
    }

    // MARK: - Audio Controls Panel (Distinct from Live Practice)

    private var audioControlsPanel: some View {
        VStack(spacing: 24) {
            
            // Header for audio section
            HStack {
                Text("Audio Visualizer")
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                Spacer()
                
                // Voice toggle
                Button {
                    bolVoiceEnabled.toggle()
                    BolSpeechManager.shared.isEnabled = bolVoiceEnabled
                    if !bolVoiceEnabled { BolSpeechManager.shared.stop() }
                    #if canImport(UIKit)
                    KathakTheme.hapticSelection()
                    #endif
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: bolVoiceEnabled ? "waveform" : "speaker.slash.fill")
                        Text(bolVoiceEnabled ? "Bol Voice On" : "Voice Off")
                    }
                    .font(KathakTheme.captionFont)
                    .foregroundStyle(bolVoiceEnabled ? KathakTheme.brightGold : KathakTheme.softBeige.opacity(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                .accessibilityLabel(bolVoiceEnabled ? "Syllable Voice is On" : "Syllable Voice is Off")
                .accessibilityHint("Double tap to toggle reciting the beat syllables aloud.")
            }
            
            // Playback & Speed
            HStack(spacing: 20) {
                
                // Play/Stop Button
                Button {
                    #if canImport(UIKit)
                    KathakTheme.hapticLight()
                    #endif
                    if isPlaying {
                        pausePlayback()
                    } else {
                        startPlayback()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(KathakTheme.title3Font)
                        Text(isPlaying ? "Pause Beats" : "Play Beats")
                            .font(KathakTheme.headlineFont)
                    }
                    .foregroundStyle(isPlaying ? KathakTheme.softBeige : KathakTheme.charcoal)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isPlaying ? Color.white.opacity(0.15) : KathakTheme.warmGold)
                    )
                }
                .accessibilityLabel(isPlaying ? "Pause Beats" : "Play Beats")

                // BPM display
                VStack(spacing: 2) {
                    Text("\(Int(bpm))")
                        .font(KathakTheme.title2Font)
                        .foregroundStyle(KathakTheme.softBeige)
                    Text("BPM")
                        .font(KathakTheme.caption2Font)
                        .foregroundStyle(KathakTheme.warmGold.opacity(0.6))
                }
                .frame(width: 60)
            }
            
            // Speed Slider
            VStack(spacing: 8) {
                Slider(value: $bpm, in: 40...180, step: 5)
                    .tint(KathakTheme.warmGold)
                    .accessibilityLabel("Tempo")
                    .accessibilityValue("\(Int(bpm)) Beats Per Minute")
                    .onChange(of: bpm) { old, new in
                        if isPlaying { restartTimer() }
                    }
                HStack {
                    Text("Vilambit (Slow)")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(KathakTheme.softBeige.opacity(0.4))
                    Spacer()
                    Text("Drut (Fast)")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(KathakTheme.softBeige.opacity(0.4))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }

    // MARK: - Start Practice Button (Massive CTA)

    private var startPracticeButton: some View {
        Button {
            stopPlayback()
            #if canImport(UIKit)
            KathakTheme.hapticSuccess()
            #endif
            checkCameraPermission()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(KathakTheme.title2Font)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Start Live Practice")
                        .font(KathakTheme.title3Font)
                    Text("AI Posture & Rhythm Analysis")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(KathakTheme.softBeige.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
            }
            .foregroundStyle(KathakTheme.creamWhite)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .frame(height: 72) // Taller, very prominent
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [KathakTheme.deepMaroon, KathakTheme.richMaroon],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(KathakTheme.warmGold.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: KathakTheme.deepMaroon.opacity(0.5), radius: 15, y: 8)
            )
        }
        .accessibilityLabel("Start Live Practice. AI Posture and Rhythm Analysis")
        .padding(.horizontal, 24)
        .buttonStyle(.plain)
    }

    // MARK: - Playback

    private func startPlayback() {
        soundEngine.start()
        isPlaying = true
        if currentBeat == 0 { currentBeat = 1 }
        
        playBeat()
        startTimer()
    }

    private func pausePlayback() {
        isPlaying = false
        beatTimer?.invalidate(); beatTimer = nil
        BolSpeechManager.shared.stop()
    }

    private func stopPlayback() {
        isPlaying = false
        beatTimer?.invalidate(); beatTimer = nil
        currentBeat = 0
        soundEngine.stop()
        BolSpeechManager.shared.stop()
    }

    private func restartTimer() {
        beatTimer?.invalidate(); beatTimer = nil
        startTimer()
    }
    
    private func startTimer() {
        let interval = 60.0 / bpm
        let totalBeats = taal.totalBeats
        
        // We want to play from whatever beat we start on, until we hit beat 1 again (the Sam).
        // If we start on beat 1, we play all `totalBeats` beats, plus 1 more to land on beat 1.
        
        beatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [self] _ in
            Task { @MainActor [self] in
                currentBeat = (currentBeat % totalBeats) + 1
                playBeat()
                
                // If we just landed back on Beat 1, our cycle has resolved. Pause here.
                if currentBeat == 1 {
                    scheduleStop()
                }
            }
        }
    }
    
    private func scheduleStop() {
        beatTimer?.invalidate(); beatTimer = nil
        
        // Pause playback state so UI shows Play button again
        isPlaying = false
    }

    private func playBeat() {
        let accent = taal.accent(for: currentBeat)
        soundEngine.playBeat(accent: accent)

        if currentBeat >= 1 && currentBeat <= taal.totalBeats {
            BolSpeechManager.shared.speakBol(taal.bols[currentBeat - 1])
        }
        #if os(iOS)
        soundEngine.triggerHaptic(accent: accent)
        #endif
    }

    // MARK: - Color Helpers

    private func nodeBackground(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam:    return KathakTheme.brightGold.opacity(0.25)
        case .taali:  return KathakTheme.warmGold.opacity(0.15)
        case .khaali: return KathakTheme.terracotta.opacity(0.12)
        case nil:     return Color.white.opacity(0.06)
        }
    }

    private func nodeStroke(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam:    return KathakTheme.brightGold.opacity(0.6)
        case .taali:  return KathakTheme.warmGold.opacity(0.4)
        case .khaali: return KathakTheme.terracotta.opacity(0.3)
        case nil:     return Color.white.opacity(0.1)
        }
    }

    private func nodeTextColor(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam:    return KathakTheme.brightGold
        case .taali:  return KathakTheme.warmGold
        case .khaali: return KathakTheme.terracotta
        case nil:     return KathakTheme.softBeige.opacity(0.7)
        }
    }
    
    // MARK: - Camera Permission Handling
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Already approved, proceed
            navigateToPractice = true
        case .notDetermined:
            // Ask for permission now, BEFORE navigating
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.navigateToPractice = true
                    } else {
                        self.showCameraDeniedAlert = true
                    }
                }
            }
        case .denied, .restricted:
            // Show alert to go to Settings
            showCameraDeniedAlert = true
        @unknown default:
            break
        }
    }
}
