import SwiftUI

// MARK: - Topic Lesson View
// Step-by-step interactive lesson with 2D illustrations.

struct TopicLessonView: View {

    let topic: DiscoverTopic
    var moduleTitle: String = ""

    @State private var currentStep = 0
    @State private var animateIn = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isCompact: Bool { verticalSizeClass == .compact }

    var body: some View {
        ZStack {
            KathakTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                GeometryReader { geo in
                    VStack(spacing: isCompact ? 10 : 16) {
                        // Step text above illustration
                        stepContent
                            .padding(.top, isCompact ? 8 : 14)
                            .opacity(animateIn ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.15), value: animateIn)

                        // Progress dots
                        progressDots

                        // 2D Dancer Illustration
                        DancerIllustration(
                            visualKey: topic.steps[currentStep].visualKey,
                            accentColor: topic.accentColor
                        )
                        .frame(maxHeight: 280)
                        .padding(.horizontal, 20)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                        .animation(.easeOut(duration: 0.5), value: animateIn)

                        Spacer(minLength: 0)
                    }
                }

                bottomBar
            }
        }
        .navigationTitle(moduleTitle.isEmpty ? topic.title : moduleTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .onAppear {
            withAnimation { animateIn = true }
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<topic.steps.count, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? topic.accentColor : Color.white.opacity(0.15))
                    .frame(width: i == currentStep ? 28 : 12, height: 5)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Step Content

    private var stepContent: some View {
        let step = topic.steps[currentStep]
        return VStack(spacing: 8) {
            Text(step.title)
                .font(KathakTheme.title2Font)
                .foregroundStyle(topic.accentColor)
                .multilineTextAlignment(.center)

            Text(step.description)
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 28)
                .fixedSize(horizontal: false, vertical: true)
        }
        .id(currentStep)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.title). \(step.description)")
        .accessibilityValue("Step \(currentStep + 1) of \(topic.steps.count)")
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button {
                #if canImport(UIKit)
                KathakTheme.hapticLight()
                #endif
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    currentStep -= 1
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .accessibilityLabel("Previous Step")
            .opacity(currentStep > 0 ? 1 : 0)

            Spacer()

            Button {
                #if canImport(UIKit)
                KathakTheme.hapticMedium()
                #endif
                if currentStep < topic.steps.count - 1 {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentStep += 1
                    }
                } else {
                    dismiss()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(currentStep == topic.steps.count - 1 ? "Done" : "Next")
                    Image(systemName: currentStep == topic.steps.count - 1 ? "checkmark" : "chevron.right")
                }
                .font(KathakTheme.headlineFont)
                .foregroundStyle(KathakTheme.deepMaroon)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Capsule().fill(topic.accentColor))
            }
            .accessibilityLabel(currentStep == topic.steps.count - 1 ? "Finish Lesson" : "Next Step")
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}
