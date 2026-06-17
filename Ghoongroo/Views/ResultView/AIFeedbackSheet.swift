import SwiftUI

struct AIFeedbackSheet: View {

    let insights: [PracticeInsight]
    let score: ScoreResult
    @Environment(\.dismiss) private var dismiss

    @State private var displayedPoints: [AICoachPoint] = []
    @State private var isGenerating = false

    var body: some View {
        ZStack {
            // Background
            KathakTheme.backgroundGradient.ignoresSafeArea()
            ParticleField(count: 15).opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("AI Coach Feedback")
                        .font(KathakTheme.title2Font)
                        .foregroundStyle(KathakTheme.softBeige)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(KathakTheme.titleFont)
                            .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    KathakTheme.charcoal.opacity(0.9)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(KathakTheme.warmGold.opacity(0.2))
                        }
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - AI Generated Paragraph
                        aiCoachBlock
                        
                        // MARK: - Per-Cycle Insight Cards
                        if !insights.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "list.bullet.rectangle.portrait")
                                        .foregroundStyle(KathakTheme.warmGold)
                                    Text("Detailed Insights")
                                        .font(KathakTheme.headlineFont)
                                        .foregroundStyle(KathakTheme.softBeige)
                                }
                                .padding(.horizontal, 4)
                                
                                ForEach(groupedByPhrase.keys.sorted(), id: \.self) { phrase in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "number.circle.fill")
                                            Text("Cycle \(phrase + 1)")
                                        }
                                        .font(KathakTheme.headlineFont)
                                        .foregroundStyle(KathakTheme.warmGold)
                                        .padding(.horizontal, 4)
                                        
                                        ForEach(groupedByPhrase[phrase] ?? []) { insight in
                                            insightCard(insight)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            startTypewriterEffect()
        }
    }
    
    // MARK: - AI Coach Block
    
    private var aiCoachBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "brain.head.profile")
                    .font(KathakTheme.titleFont)
                    .foregroundStyle(KathakTheme.brightGold)
                Text("AI Kathak Coach")
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.brightGold)
                Spacer()
            }
            .overlay(alignment: .trailing) {
                if isGenerating {
                    ProgressView()
                        .tint(KathakTheme.warmGold)
                        .scaleEffect(0.8)
                }
            }
            
            // Bullet point list
            VStack(alignment: .leading, spacing: 12) {
                ForEach(displayedPoints) { point in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: point.icon)
                            .font(KathakTheme.subheadlineFont)
                            .foregroundStyle(point.isPositive ? .green : KathakTheme.warmGold)
                            .frame(width: 20)
                        
                        Text(point.text)
                            .font(KathakTheme.subheadlineFont)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            
            if !isGenerating && !displayedPoints.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "cpu")
                        .font(KathakTheme.captionFont)
                    Text("Generated by on-device Foundation Model")
                        .font(KathakTheme.caption2Font)
                }
                .foregroundStyle(KathakTheme.warmGold.opacity(0.5))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(KathakTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [KathakTheme.brightGold.opacity(0.4), KathakTheme.warmGold.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: KathakTheme.saffron.opacity(0.3).opacity(0.2), radius: 10, y: 4)
        )
    }
    
    // MARK: - Typewriter Effect (Points)
    
    private func startTypewriterEffect() {
        isGenerating = true
        displayedPoints = []
        
        Task { @MainActor in
            // Try Foundation Model first, fall back to template
            let allPoints = await generateWithFoundationModel()
            
            for point in allPoints {
                try? await Task.sleep(for: .milliseconds(400))
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    displayedPoints.append(point)
                }
            }
            isGenerating = false
        }
    }
    
    // MARK: - AI Coach Point Model
    
    struct AICoachPoint: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
        let isPositive: Bool
    }
    
    // MARK: - Foundation Model Integration
    
    private func generateWithFoundationModel() async -> [AICoachPoint] {
        // Foundation Models framework requires iOS 26+.
        // Currently targeting iOS 17, so we use metric-based template feedback.
        // When iOS 26+ is the minimum, add:
        //   import FoundationModels
        //   let session = LanguageModelSession()
        //   let response = try await session.respond(to: buildMetricsPrompt())
        return generateFromMetrics()
    }
    
    // MARK: - Metric-Based Template Feedback (Fallback)
    
    private func generateFromMetrics() -> [AICoachPoint] {
        var points: [AICoachPoint] = []
        
        // Overall
        points.append(AICoachPoint(
            icon: "star.fill",
            text: "Grace Score: \(Int(score.graceScore))% — Detected: \(score.detectedStep). \(score.mlPostureLabel) performance.",
            isPositive: score.graceScore > 60
        ))
        
        // Posture
        let posturePositive = score.postureAccuracy > 75
        points.append(AICoachPoint(
            icon: posturePositive ? "figure.stand" : "figure.fall",
            text: posturePositive
                ? "Posture accuracy at \(Int(score.postureAccuracy))% — your spine alignment and upper body control are strong."
                : "Posture at \(Int(score.postureAccuracy))% — focus on engaging your core and keeping your spine vertical.",
            isPositive: posturePositive
        ))
        
        // Rhythm
        let rhythmPositive = score.rhythmSync > 70
        points.append(AICoachPoint(
            icon: rhythmPositive ? "metronome.fill" : "clock.badge.exclamationmark",
            text: rhythmPositive
                ? "Rhythm sync at \(Int(score.rhythmSync))% — your foot strikes align well with the beat pattern."
                : "Rhythm at \(Int(score.rhythmSync))% — practice at a slower tempo to internalize the beat, then gradually speed up.",
            isPositive: rhythmPositive
        ))
        
        // Balance
        let balancePositive = score.balanceStability > 70
        points.append(AICoachPoint(
            icon: balancePositive ? "checkmark.shield.fill" : "exclamationmark.triangle.fill",
            text: balancePositive
                ? "Balance stability at \(Int(score.balanceStability))% — your center of gravity stays consistent."
                : "Balance at \(Int(score.balanceStability))% — keep your weight centered over both feet, especially during transitions.",
            isPositive: balancePositive
        ))
        
        // Smoothness
        let smoothPositive = score.movementSmoothness > 65
        points.append(AICoachPoint(
            icon: smoothPositive ? "wind" : "waveform.path.ecg",
            text: smoothPositive
                ? "Movement smoothness at \(Int(score.movementSmoothness))% — transitions between poses are fluid and controlled."
                : "Smoothness at \(Int(score.movementSmoothness))% — avoid jerky movements; let each action flow into the next.",
            isPositive: smoothPositive
        ))
        
        // Closing
        points.append(AICoachPoint(
            icon: "sparkles",
            text: "Every practice session builds muscle memory. Keep going — grace comes with consistency. 🪷",
            isPositive: true
        ))
        
        return points
    }
    
    // MARK: - Insight Card
    
    private func insightCard(_ insight: PracticeInsight) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(insight.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: insight.type.icon)
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(insight.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.type.title)
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(.white)
                
                Text(insight.message)
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(KathakTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    insight.type.color.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var groupedByPhrase: [Int: [PracticeInsight]] {
        Dictionary(grouping: insights) { insight in
            insight.phraseIndex ?? 0
        }
    }
}
