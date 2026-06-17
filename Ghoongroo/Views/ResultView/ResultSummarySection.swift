import SwiftUI

struct ResultSummarySection: View {

    let score: ScoreResult

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Overall Score (hero row)
            overallScoreRow
            
            // Category badges
            categoryBadgesRow
                .padding(.bottom, 12)
            
            Divider().background(KathakTheme.warmGold.opacity(0.2))
            
            // ML-derived metrics
            scoreRow("Detected Step", score.detectedStep, icon: "figure.dance", color: KathakTheme.warmGold)
            scoreRow("Posture AI", score.mlPostureLabel, icon: "brain.head.profile", color: postureColor)
            
            Divider().background(KathakTheme.warmGold.opacity(0.2))
            
            // Score breakdown bars (new 5-metric system)
            scoreBarRow("Posture Accuracy", value: score.postureAccuracy, icon: "figure.stand", barColor: barColor(for: score.postureAccuracy))
            scoreBarRow("Joint Alignment", value: score.jointAlignment, icon: "hands.clap.fill", barColor: barColor(for: score.jointAlignment))
            scoreBarRow("Balance Stability", value: score.balanceStability, icon: "checkmark.shield.fill", barColor: barColor(for: score.balanceStability))
            scoreBarRow("Rhythm Sync", value: score.rhythmSync, icon: "metronome.fill", barColor: barColor(for: score.rhythmSync))
            scoreBarRow("Movement Smoothness", value: score.movementSmoothness, icon: "wind", barColor: barColor(for: score.movementSmoothness))
            
            Divider().background(KathakTheme.warmGold.opacity(0.2))

            // Session metrics
            scoreRow("Stability", score.stabilityLabel, icon: "checkmark.shield.fill", color: stabilityColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(KathakTheme.charcoal.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(KathakTheme.warmGold.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: KathakTheme.saffron.opacity(0.3).opacity(0.15), radius: 10, y: 5)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Overall Score Hero
    
    private var overallScoreRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(KathakTheme.warmGold.opacity(0.2), lineWidth: 4)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: score.graceScore / 100)
                    .stroke(overallColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(score.graceScore))")
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(overallColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Grace Score")
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                Text(overallLabel)
                    .font(KathakTheme.caption2Font)
                    .foregroundStyle(overallColor)
            }
            Spacer()
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Category Badges
    
    private var categoryBadgesRow: some View {
        HStack(spacing: 8) {
            if score.postureAccuracy > 80 { CategoryBadge(text: "Stable Posture", color: .green) }
            if score.rhythmSync > 80 { CategoryBadge(text: "On Rhythm", color: .green) }
            if score.rhythmSync < 60 { CategoryBadge(text: "Needs Timing Work", color: .orange) }
            if score.jointAlignment > 80 { CategoryBadge(text: "Great Alignment", color: .green) }
            if score.movementSmoothness > 80 { CategoryBadge(text: "Fluid Movement", color: .green) }
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Score Bar Row
    
    private func scoreBarRow(_ title: String, value: Double, icon: String, barColor: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(KathakTheme.captionFont)
                    .foregroundStyle(barColor)
                    .frame(width: 16)
                Text(title)
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                Spacer()
                Text("\(Int(value))%")
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(barColor)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(KathakTheme.warmGold.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(width: geo.size.width * min(value / 100, 1), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Text Row
    
    private func scoreRow(_ title: String, _ value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(KathakTheme.captionFont)
                .foregroundStyle(color)
                .frame(width: 16)
            Text(title)
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(KathakTheme.softBeige)
            Spacer()
            Text(value)
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(color)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Colors
    
    private var overallColor: Color {
        if score.graceScore > 80 { return .green }
        else if score.graceScore > 60 { return KathakTheme.warmGold }
        else { return .red.opacity(0.8) }
    }
    
    private var overallLabel: String {
        if score.graceScore > 80 { return "Excellent Performance" }
        else if score.graceScore > 60 { return "Good — Keep Practicing" }
        else { return "Needs Improvement" }
    }
    
    private var postureColor: Color {
        switch score.mlPostureLabel {
        case "Excellent": return .green
        case "Good": return .green.opacity(0.8)
        case "Fair": return KathakTheme.warmGold
        default: return .red.opacity(0.8)
        }
    }
    
    private func barColor(for value: Double) -> Color {
        if value > 80 { return .green }
        else if value > 60 { return KathakTheme.warmGold }
        else { return .red.opacity(0.8) }
    }
    
    private var stabilityColor: Color {
        switch score.stabilityLabel {
        case "Solid": return .green
        case "Fair": return KathakTheme.warmGold
        default: return .red.opacity(0.8)
        }
    }
}

// MARK: - Subcomponents

struct CategoryBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(KathakTheme.caption2Font)
            .foregroundStyle(KathakTheme.charcoal)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}
