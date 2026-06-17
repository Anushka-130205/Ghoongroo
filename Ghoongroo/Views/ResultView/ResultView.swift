import SwiftUI
import AVKit

struct ResultView: View {

    let score: ScoreResult
    let taalName: String
    var onPracticeAgain: () -> Void
    var onHome: () -> Void

    @State private var animatedGraceScore: Double = 0
    @State private var showAIFeedback = false

    var salutationTitle: String {
        switch score.graceScore {
        case 90...100: return "Outstanding Performance"
        case 75..<90:  return "Graceful Progress"
        case 50..<75:  return "Good Effort – Keep Practicing"
        default:       return "Every Step Is A Lesson"
        }
    }

    var body: some View {
        ZStack {
            KathakTheme.backgroundGradient.ignoresSafeArea()
            ParticleField(count: 20).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // MARK: - Dynamic Salutation
                        Text(salutationTitle)
                            .font(KathakTheme.largeTitleFont)
                            .foregroundStyle(KathakTheme.softBeige)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .shadow(color: KathakTheme.charcoal.opacity(0.5), radius: 4, y: 2)
                        
                        // MARK: - Large Result Summary Card
                        VStack(spacing: 24) {
                            
                            // Overall Grace Score
                            VStack(spacing: 8) {
                                Text("\(Int(animatedGraceScore))")
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                    .foregroundStyle(KathakTheme.goldShimmer)
                                    .contentTransition(.numericText())
                                    .shadow(color: KathakTheme.warmGold.opacity(0.2), radius: 10)
                                
                                Text("Overall Grace Evaluation")
                                    .font(KathakTheme.headlineFont)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.15))
                            
                            // Progress Bars
                            VStack(spacing: 20) {
                                ProgressBarRow(title: "Posture Accuracy", value: score.postureAccuracy, color: KathakTheme.warmGold)
                                ProgressBarRow(title: "Step Precision", value: score.stepAccuracy, color: KathakTheme.saffron)
                                ProgressBarRow(title: "Rhythm Alignment", value: score.timingPrecision, color: KathakTheme.brightGold)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.15))
                            
                            // Insights
                            VStack(spacing: 16) {
                                InsightRow(
                                    icon: "star.fill",
                                    label: "Strongest Area",
                                    text: "Excellent \(score.strongestRegion.lowercased()) control",
                                    color: KathakTheme.warmGold
                                )
                                InsightRow(
                                    icon: "arrow.up.forward.circle.fill",
                                    label: "Improvement Suggestion",
                                    text: "Focus on stabilizing \(score.weakestRegion.lowercased()) alignment",
                                    color: KathakTheme.terracotta
                                )
                            }
                        }
                        .padding(28)
                        .background(
                            LinearGradient(
                                colors: [KathakTheme.charcoal.opacity(0.8), KathakTheme.deepMaroon.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // MARK: - Action Buttons (Bottom Fixed)
                VStack(spacing: 16) {
                    Button(action: onPracticeAgain) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Practice Again")
                        }
                        .font(KathakTheme.headlineFont)
                        .foregroundStyle(KathakTheme.deepMaroon)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(KathakTheme.goldShimmer, in: Capsule())
                    }
                    
                    Button(action: onHome) {
                        Text("Back to Dashboard")
                            .font(KathakTheme.headlineFont)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1), in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 16)
                .background(
                    KathakTheme.backgroundGradient
                        .mask(LinearGradient(
                            stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.1)],
                            startPoint: .top, endPoint: .bottom
                        ))
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KathakTheme.charcoal, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAIFeedback = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("Feedback")
                    }
                    .font(KathakTheme.subheadlineFont.weight(.medium))
                    .foregroundStyle(KathakTheme.warmGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(KathakTheme.warmGold.opacity(0.15), in: Capsule())
                }
            }
        }
        .sheet(isPresented: $showAIFeedback) {
            AIFeedbackSheet(insights: [], score: score)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animatedGraceScore = score.graceScore
            }
        }
    }
}

fileprivate struct ProgressBarRow: View {
    let title: String
    let value: Double
    let color: Color
    @State private var animatedValue: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                Spacer()
                Text("\(Int(animatedValue))%")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: max(0, min(geometry.size.width * CGFloat(animatedValue / 100), geometry.size.width)), height: 8)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                animatedValue = value
            }
        }
    }
}

fileprivate struct InsightRow: View {
    let icon: String
    let label: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(KathakTheme.captionFont)
                    .foregroundStyle(.white.opacity(0.6))
                
                Text(text)
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}
