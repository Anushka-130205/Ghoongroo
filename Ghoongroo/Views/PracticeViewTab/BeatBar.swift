import SwiftUI

// MARK: - Beat Bar
// Dynamic taal-aware beat cycle bar with current beat highlighting and bol labels

struct BeatBar: View {

    @ObservedObject var beatManager: BeatManager

    private var taal: Taal { beatManager.taal }

    var body: some View {
        VStack(spacing: 6) {
            // Vibhaag labels
            vibhaagLabels

            // Beat indicators — grouped by vibhaag
            beatRow

            // Current bol + progress
            if beatManager.isPlaying {
                currentBolDisplay
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(KathakTheme.warmGold.opacity(0.2), lineWidth: 1)
                )
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Vibhaag Labels

    private var vibhaagLabels: some View {
        HStack(spacing: 0) {
            let starts = taal.vibhaagStartBeats
            ForEach(0..<taal.vibhaags.count, id: \.self) { vi in
                let accent = taal.accent(for: starts[vi])
                HStack(spacing: 2) {
                    Text(markerSymbol(accent))
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(markerColor(accent).opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Beat Row

    private var beatRow: some View {
        HStack(spacing: 2) {
            ForEach(1...taal.totalBeats, id: \.self) { beat in
                beatIndicator(beat: beat)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Current Bol Display

    private var currentBolDisplay: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Text(beatManager.currentBol)
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(
                        beatManager.isSam
                            ? KathakTheme.brightGold
                            : KathakTheme.softBeige
                    )
                    .animation(.easeInOut(duration: 0.1), value: beatManager.currentBeat)

                Text("· \(taal.name)")
                    .font(KathakTheme.caption2Font)
                    .foregroundStyle(KathakTheme.warmGold.opacity(0.4))
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(KathakTheme.goldShimmer)
                        .frame(
                            width: geo.size.width * beatManager.progress,
                            height: 3
                        )
                        .animation(
                            .linear(duration: beatManager.beatInterval),
                            value: beatManager.progress
                        )
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 8)
        }
    }

    // MARK: - Beat Indicator

    private func beatIndicator(beat: Int) -> some View {
        let isCurrent = beat == beatManager.currentBeat
        let isPast = beat < beatManager.currentBeat || beatManager.currentCycle > 0
        let accent = taal.accent(for: beat)

        return VStack(spacing: 2) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(backgroundColor(isCurrent: isCurrent, isPast: isPast, accent: accent))
                    .frame(width: beatDotWidth, height: 26)

                if accent == .sam {
                    Text("✕")
                        .font(KathakTheme.captionFont)
                        .foregroundStyle(isCurrent ? KathakTheme.deepMaroon : KathakTheme.warmGold)
                } else {
                    Text("\(beat)")
                        .font(KathakTheme.caption2Font)
                        .foregroundStyle(
                            isCurrent
                                ? KathakTheme.deepMaroon
                                : KathakTheme.softBeige.opacity(0.6)
                        )
                }
            }
            .scaleEffect(isCurrent ? 1.15 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isCurrent)

            // Bol label
            Text(taal.bols[beat - 1])
                .font(KathakTheme.caption2Font)
                .foregroundStyle(
                    isCurrent
                        ? KathakTheme.brightGold
                        : KathakTheme.softBeige.opacity(0.3)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sizing Helpers

    /// Adapt sizing for different beat counts (10, 12, 16)
    private var beatDotWidth: CGFloat {
        taal.totalBeats > 12 ? 16 : 20
    }

    // MARK: - Color Helpers

    private func backgroundColor(isCurrent: Bool, isPast: Bool, accent: Taal.BeatAccent?) -> Color {
        if isCurrent {
            return KathakTheme.brightGold
        }
        switch accent {
        case .sam:
            return KathakTheme.warmGold.opacity(0.25)
        case .taali:
            return KathakTheme.warmGold.opacity(0.12)
        case .khaali:
            return KathakTheme.terracotta.opacity(0.12)
        case nil:
            return Color.white.opacity(isPast ? 0.08 : 0.05)
        }
    }

    private func markerSymbol(_ accent: Taal.BeatAccent?) -> String {
        switch accent {
        case .sam:    return "✕"
        case .taali:  return "+"
        case .khaali: return "○"
        case nil:     return "·"
        }
    }

    private func markerColor(_ accent: Taal.BeatAccent?) -> Color {
        switch accent {
        case .sam:    return KathakTheme.brightGold
        case .taali:  return KathakTheme.warmGold
        case .khaali: return KathakTheme.terracotta
        case nil:     return KathakTheme.softBeige
        }
    }
}
