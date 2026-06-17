import SwiftUI

// MARK: - Discover Kathak View
// Hub showing Discover Kathak modules as large interactive cards.
// Tapping a card opens the step-by-step lesson directly.

struct DiscoverKathakView: View {

    @State private var animateCards = false
    @State private var selectedModule: DiscoverModule?
    @State private var showLesson = false

    @Environment(\.dismiss) private var dismiss

    private let modules = DiscoverModule.allModules

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                Text("Explore the art, tradition, and technique behind every movement.")
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 300), spacing: 20)],
                    spacing: 20
                ) {
                    ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                        Button {
                            #if canImport(UIKit)
                            KathakTheme.hapticSelection()
                            #endif
                            selectedModule = module
                            showLesson = true
                        } label: {
                            moduleCard(module, index: index)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(module.title), \(module.subtitle). \(module.topics.first?.steps.count ?? 0) Steps.")
                                .accessibilityHint("Double tap to open this lesson")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(
            KathakTheme.backgroundGradient
                .ignoresSafeArea()
                .overlay(
                    ParticleField(count: 6)
                        .opacity(0.15)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                )
        )
        .navigationTitle("Discover Kathak")
        .navigationBarBackButtonHidden(false)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .navigationDestination(isPresented: $showLesson) {
            if let module = selectedModule,
               let topic = module.topics.first {
                TopicLessonView(topic: topic, moduleTitle: module.title)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { animateCards = true }
        }
    }

    // MARK: - Module Card

    private func moduleCard(_ module: DiscoverModule, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(module.accentColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: module.icon)
                        .font(KathakTheme.titleFont)
                        .foregroundStyle(KathakTheme.brightGold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(module.title)
                        .font(KathakTheme.title3Font)
                        .foregroundStyle(KathakTheme.softBeige)

                    Text(module.subtitle)
                        .font(KathakTheme.caption2Font)
                        .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(module.accentColor.opacity(0.4))
            }

            // Step count
            HStack(spacing: 6) {
                Image(systemName: "photo.stack")
                    .font(KathakTheme.captionFont)
                Text("\(module.topics.first?.steps.count ?? 0) Steps")
                    .font(KathakTheme.caption2Font)
                    .lineLimit(1)
            }
            .foregroundStyle(module.accentColor.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(module.accentColor.opacity(0.1)))

            // Accent bar
            Capsule()
                .fill(module.accentColor.opacity(0.3))
                .frame(height: 3)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(module.accentColor.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(module.accentColor.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 4)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 25)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
    }
}
