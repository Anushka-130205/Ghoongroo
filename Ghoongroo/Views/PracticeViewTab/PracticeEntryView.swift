import SwiftUI

// MARK: - Practice Entry View
// Landing screen: user selects a rhythm → Taal Info Sheet → Visualizer Screen → Live Practice

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

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

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

                    // Rhythm cards
                    VStack(spacing: 20) {
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

                }
                .padding(.bottom, 40)
            }
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

    // MARK: - Rhythm Card

    private func rhythmCard(_ taal: Taal, index: Int) -> some View {
        HStack(spacing: 16) {
            // Waveform icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                KathakTheme.warmGold.opacity(0.18),
                                KathakTheme.warmGold.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: taal.icon)
                    .font(KathakTheme.titleFont)
                    .foregroundStyle(KathakTheme.brightGold)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(taal.name)
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)

                HStack(spacing: 8) {
                    badge(text: "\(taal.totalBeats) Beats", color: KathakTheme.saffron)
                    badge(text: "\(taal.vibhaags.count) Vibhaags", color: KathakTheme.terracotta)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(KathakTheme.warmGold.opacity(0.4))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(KathakTheme.warmGold.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(KathakTheme.warmGold.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 12, y: 5)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
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
                    .fill(color.opacity(0.12))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.15), lineWidth: 0.5)
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
