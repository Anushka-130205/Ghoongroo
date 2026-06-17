import SwiftUI

// MARK: - Taal Info Sheet
// Native-style sheet shown on the Visualizer screen. Displays About, Structure,
// and Bols before the user proceeds to interact with the visualizer.

struct TaalInfoSheet: View {

    let taal: Taal
    var onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var taalAccentColor: Color {
        switch taal.id {
        case "teental": return KathakTheme.warmGold
        case "jhaptal":  return KathakTheme.terracotta
        case "ektaal":   return KathakTheme.saffron
        default:         return KathakTheme.warmGold
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Text("About \(taal.name)")
                        .font(KathakTheme.title3Font)
                        .foregroundStyle(taalAccentColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                        .accessibilityAddTraits(.isHeader)

                    // About
                    aboutSection

                    sectionDivider

                    // Structure
                    structureSection

                    sectionDivider

                    // Bols
                    bolsSection

                    // Continue button at bottom of content
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            onContinue()
                        }
                    } label: {
                        Text("Let's Visualize")
                            .font(KathakTheme.headlineFont)
                        .foregroundStyle(KathakTheme.deepMaroon)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(KathakTheme.goldShimmer)
                                .shadow(color: KathakTheme.warmGold.opacity(0.4), radius: 12, y: 4)
                        )
                    }
                    .accessibilityLabel("Continue to Visualize Rhythm")
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .background(KathakTheme.backgroundGradient.ignoresSafeArea())
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }

    // MARK: - Beat Strip

    private var beatStrip: some View {
        HStack(spacing: 3) {
            ForEach(0..<taal.totalBeats, id: \.self) { i in
                let accent = taal.accent(for: i + 1)
                RoundedRectangle(cornerRadius: 2)
                    .fill(beatStripColor(accent))
                    .frame(height: 6)
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Overview", icon: "doc.text")

            Text(taal.description)
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.75))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                legendItem("✕ Sam", color: KathakTheme.brightGold, desc: "First")
                legendItem("+ Taali", color: KathakTheme.warmGold, desc: "Clap")
                legendItem("○ Khaali", color: KathakTheme.terracotta, desc: "Wave")
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    // MARK: - Structure Section

    private var structureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Structure", icon: "square.grid.2x2")

            let starts = taal.vibhaagStartBeats
            ForEach(0..<taal.vibhaags.count, id: \.self) { vi in
                let start = starts[vi]
                let count = taal.vibhaags[vi]
                let accent = taal.accent(for: start)
                let endBeat = start + count - 1

                HStack(spacing: 10) {
                    Text(vibhaagLabel(accent))
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(vibhaagColor(accent))
                        .frame(width: 14, height: 14)
                        .background(Circle().fill(vibhaagColor(accent).opacity(0.15)))

                    Text("Vibhaag \(vi + 1)")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                        .frame(width: 70, alignment: .leading)

                    Spacer()

                    HStack(spacing: 4) {
                        ForEach((start - 1)..<endBeat, id: \.self) { bi in
                            Text(taal.bols[bi])
                                .font(KathakTheme.caption2Font)
                                .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
                        }
                    }
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Vibhaag \(vi + 1) containing beats \(start) through \(endBeat).")

                if vi < taal.vibhaags.count - 1 {
                    Divider().background(KathakTheme.warmGold.opacity(0.08))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    // MARK: - Bols Section

    private var bolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Bols (Syllables)", icon: "text.alignleft")

            Text("The rhythmic syllables of this taal:")
                .font(KathakTheme.captionFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.4))

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4),
                spacing: 8
            ) {
                ForEach(0..<taal.totalBeats, id: \.self) { i in
                    let accent = taal.accent(for: i + 1)
                    VStack(spacing: 2) {
                        Text(taal.bols[i])
                            .font(KathakTheme.captionFont)
                            .foregroundStyle(bolColor(accent))
                        Text("\(i + 1)")
                            .font(KathakTheme.captionFont)
                            .foregroundStyle(KathakTheme.softBeige.opacity(0.25))
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Beat \(i + 1). \(taal.bols[i])")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(bolBG(accent))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(bolStroke(accent), lineWidth: 0.5))
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .bold()
                .foregroundStyle(KathakTheme.warmGold)
            Text(title)
                .font(.title3)
                .bold()
                .font(KathakTheme.headlineFont)
                .foregroundStyle(KathakTheme.softBeige)
        }
    }

    private var sectionDivider: some View {
        OrnamentalDivider()
//            .background(KathakTheme.warmGold.opacity(0.12))
//            .padding(.horizontal, 24)
    }

    private func legendItem(_ label: String, color: Color, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label).font(KathakTheme.captionFont).foregroundStyle(color)
            Text(desc).font(KathakTheme.captionFont).foregroundStyle(KathakTheme.softBeige.opacity(0.3))
        }
    }

    private func beatStripColor(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam:    return KathakTheme.brightGold.opacity(0.9)
        case .taali:  return KathakTheme.warmGold.opacity(0.55)
        case .khaali: return KathakTheme.terracotta.opacity(0.45)
        case nil:     return taalAccentColor.opacity(0.2)
        }
    }

    private func vibhaagLabel(_ accent: Taal.BeatAccent?) -> String {
        switch accent {
        case .sam: return "✕"; case .taali: return "+"; case .khaali: return "○"; case nil: return "·"
        }
    }

    private func vibhaagColor(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam: return KathakTheme.brightGold; case .taali: return KathakTheme.warmGold
        case .khaali: return KathakTheme.terracotta; case nil: return KathakTheme.softBeige.opacity(0.4)
        }
    }

    private func bolColor(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam: return KathakTheme.brightGold; case .taali: return KathakTheme.warmGold.opacity(0.8)
        case .khaali: return KathakTheme.terracotta.opacity(0.7); case nil: return KathakTheme.softBeige.opacity(0.5)
        }
    }

    private func bolBG(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam: return KathakTheme.brightGold.opacity(0.08); case .taali: return KathakTheme.warmGold.opacity(0.05)
        case .khaali: return KathakTheme.terracotta.opacity(0.04); case nil: return Color.white.opacity(0.02)
        }
    }

    private func bolStroke(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam: return KathakTheme.brightGold.opacity(0.2); case .taali: return KathakTheme.warmGold.opacity(0.1)
        case .khaali: return KathakTheme.terracotta.opacity(0.08); case nil: return Color.white.opacity(0.04)
        }
    }
}
