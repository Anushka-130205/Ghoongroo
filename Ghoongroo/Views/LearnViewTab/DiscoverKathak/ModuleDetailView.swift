import SwiftUI

// MARK: - Module Detail View
// Topic list for a selected Discover Kathak module.

struct DiscoverModuleDetailView: View {

    let module: DiscoverModule

    @State private var selectedTopic: DiscoverTopic?
    @State private var showLesson = false
    @State private var animateCards = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Module header
                Text(module.subtitle)
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Topic cards
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 300), spacing: 16)],
                    spacing: 16
                ) {
                    ForEach(Array(module.topics.enumerated()), id: \.element.id) { index, topic in
                        topicCard(topic, index: index)
                            .onTapGesture {
                                #if canImport(UIKit)
                                KathakTheme.hapticLight()
                                #endif
                                selectedTopic = topic
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    showLesson = true
                                }
                            }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(KathakTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle(module.title)
        .navigationBarBackButtonHidden(false)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .navigationDestination(isPresented: $showLesson) {
            if let topic = selectedTopic {
                TopicLessonView(topic: topic, moduleTitle: module.title)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { animateCards = true }
        }
    }

    // MARK: - Topic Card

    private func topicCard(_ topic: DiscoverTopic, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(topic.accentColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: topic.icon)
                    .font(KathakTheme.titleFont)
                    .foregroundStyle(topic.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)

                Text(topic.subtitle)
                    .font(KathakTheme.caption2Font)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.5))

                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                        .font(KathakTheme.captionFont)
                    Text("\(topic.steps.count) Steps")
                        .font(KathakTheme.caption2Font)
                }
                .foregroundStyle(topic.accentColor.opacity(0.7))
                .padding(.top, 2)
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(KathakTheme.titleFont)
                .foregroundStyle(topic.accentColor.opacity(0.6))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(topic.accentColor.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(topic.accentColor.opacity(0.2), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.15), radius: 8, y: 3)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: animateCards)
    }
}
