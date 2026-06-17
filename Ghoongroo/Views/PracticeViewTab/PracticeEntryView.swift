import SwiftUI

// MARK: - Practice Entry View
// Landing screen: user selects a rhythm → Visualizer Screen → Live Practice
// Cards are full-width, image-rich panels filling the screen vertically.

struct PracticeEntryView: View {

    @State private var selectedTaal: Taal? = nil
    @State private var showTaalInfo = false
    @State private var animateCards = false
    @State private var pressedIndex: Int? = nil

    // Path-based navigation for robust full-popping
    @State private var navPath = NavigationPath()

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isCompactHeight: Bool { verticalSizeClass == .compact }

    var onBack: (() -> Void)? = nil

    private let coreTaals = [Taal.teental, Taal.jhaptal, Taal.ektaal]

    /// Per-taal accent color, consistent with the rest of the app
    private func accentColor(for taal: Taal) -> Color {
        switch taal.id {
        case "teental": return KathakTheme.warmGold
        case "jhaptal":  return KathakTheme.terracotta
        case "ektaal":   return KathakTheme.saffron
        default:         return KathakTheme.warmGold
        }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Choose a Rhythm")
                            .font(KathakTheme.titleFont)
                            .foregroundStyle(KathakTheme.softBeige)

                        Text("Explore & practice classical Taal patterns")
                            .font(KathakTheme.subheadlineFont)
                            .foregroundStyle(KathakTheme.softBeige.opacity(0.45))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Full-screen rhythm cards
                    VStack(spacing: 18) {
                        ForEach(Array(coreTaals.enumerated()), id: \.element.id) { index, taal in
                            Button {
                                #if canImport(UIKit)
                                KathakTheme.hapticSelection()
                                #endif
                                selectedTaal = taal
                                navPath.append(taal)
                            } label: {
                                rhythmCard(taal, index: index)
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("\(taal.name) Rhythm, \(taal.totalBeats) Beats, \(taal.vibhaags.count) Vibhaags.")
                                    .accessibilityHint("Double tap to open visualizer and start practice.")
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)

                } // VStack
                .padding(.bottom, 40)
            } // ScrollView
            .background(
                ZStack {
                    KathakTheme.backgroundGradient.ignoresSafeArea()

                    // Subtle radial center glow for depth
                    RadialGradient(
                        colors: [
                            KathakTheme.warmGold.opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 400
                    )
                    .ignoresSafeArea()
                }
            )
            .navigationTitle("Practice")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            // Sheet 1: Taal Info
            .sheet(isPresented: $showTaalInfo) {
                if let taal = selectedTaal {
                    TaalInfoSheet(taal: taal) {
                        navPath.append(taal)
                    }
                }
            }
            // Navigation: Visualizer Screen via Path
            .navigationDestination(for: Taal.self) { sessionTaal in
                TaalVisualizerScreen(taal: sessionTaal) {
                    navPath.removeLast(navPath.count) // Pop to root
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) { animateCards = true }
            }
        }
    }

    // MARK: - Full-Screen Rhythm Card

    private func rhythmCard(_ taal: Taal, index: Int) -> some View {
        let accent = accentColor(for: taal)

        return HStack(spacing: 0) {
            // Left: Text content
            VStack(alignment: .leading, spacing: 8) {
                // Taal name
                Text(taal.name)
                    .font(KathakTheme.title2Font)
                    .foregroundStyle(KathakTheme.creamWhite)

                // Meaning description
                Text(taal.meaningDescription)
                    .font(KathakTheme.captionFont)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.7))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Badges
                HStack(spacing: 8) {
                    badge(text: "\(taal.totalBeats) Beats", color: KathakTheme.saffron)
                    badge(text: "\(taal.vibhaags.count) Vibhaags", color: KathakTheme.terracotta)
                }

                // Chevron hint
                HStack(spacing: 4) {
                    Text("Start Practice")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(accent.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .font(KathakTheme.caption2Font)
                        .foregroundStyle(accent.opacity(0.5))
                }
                .padding(.top, 2)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: Image
            Image(taal.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150)
                .clipped()
        }
        .frame(height: isCompactHeight ? 160 : 200)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            KathakTheme.deepBrown,
                            KathakTheme.charcoal.opacity(0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(accent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 14, y: 6)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 25)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08),
            value: animateCards
        )
    }

    // MARK: - Badge

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(KathakTheme.captionFont)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.2), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - Scale Button Style (tap press animation)

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
