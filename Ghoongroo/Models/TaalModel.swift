import SwiftUI

// MARK: - Taal Data Model
// Represents a rhythmic cycle (taal) used in Kathak and Hindustani music

struct Taal: Identifiable, Hashable {
    let id: String
    let name: String
    let hindiName: String
    let totalBeats: Int
    let vibhaags: [Int]               // Beat groupings, e.g. [4,4,4,4]
    let bols: [String]                // Syllable for each beat
    let markers: [Int: BeatAccent]    // Beat number → accent type
    let description: String
    let icon: String                  // SF Symbol
    let imageName: String             // Asset image for card display
    let meaningDescription: String    // Short meaning shown on card

    /// Type of structural accent on a beat
    enum BeatAccent: String {
        case sam     // First beat — strongest
        case taali   // Clap beat
        case khaali  // Wave beat (empty)
    }

    /// Returns the accent type for a given beat (1-indexed)
    func accent(for beat: Int) -> BeatAccent? {
        markers[beat]
    }

    /// Returns which vibhaag a beat belongs to (0-indexed)
    func vibhaagIndex(for beat: Int) -> Int {
        var sum = 0
        for (i, count) in vibhaags.enumerated() {
            sum += count
            if beat <= sum { return i }
        }
        return vibhaags.count - 1
    }

    /// Starting beat number for each vibhaag (1-indexed)
    var vibhaagStartBeats: [Int] {
        var starts = [1]
        var sum = 0
        for count in vibhaags.dropLast() {
            sum += count
            starts.append(sum + 1)
        }
        return starts
    }
}

// MARK: - Static Taal Library

extension Taal {

    static let allTaals: [Taal] = [teental, jhaptal, ektaal]

    // ─── Teental (16 beats) ────────────────────────────────

    static let teental = Taal(
        id: "teental",
        name: "Teental",
        hindiName: "16 Beats",
        totalBeats: 16,
        vibhaags: [4, 4, 4, 4],
        bols: [
            "Dha", "Dhin", "Dhin", "Dha",     // Vibhaag 1  (Sam)
            "Dha", "Dhin", "Dhin", "Dha",     // Vibhaag 2  (Taali)
            "Dha", "Tin",  "Tin",  "Ta",      // Vibhaag 3  (Khaali)
            "Ta",  "Dhin", "Dhin", "Dha"      // Vibhaag 4  (Taali)
        ],
        markers: [
            1:  .sam,
            5:  .taali,
            9:  .khaali,
            13: .taali
        ],
        description: "The most common taal in Hindustani music. A 16-beat cycle divided into four equal vibhaags of 4 beats each. It is the foundation for most Kathak compositions and the first taal every student learns.",
        icon: "waveform.path",
        imageName: "teental_card",
        meaningDescription: "The foundation of Kathak — a balanced 16-beat cycle (4×4) that anchors every classical performance."
    )

    // ─── Jhaptal (10 beats) ────────────────────────────────

    static let jhaptal = Taal(
        id: "jhaptal",
        name: "Jhaptal",
        hindiName: "10 Beats",
        totalBeats: 10,
        vibhaags: [2, 3, 2, 3],
        bols: [
            "Dhi", "Na",                       // Vibhaag 1  (Sam)
            "Dhi", "Dhi", "Na",               // Vibhaag 2  (Taali)
            "Ti",  "Na",                       // Vibhaag 3  (Khaali)
            "Dhi", "Dhi", "Na"                // Vibhaag 4  (Taali)
        ],
        markers: [
            1:  .sam,
            3:  .taali,
            6:  .khaali,
            8:  .taali
        ],
        description: "A 10-beat cycle with asymmetric vibhaags (2+3+2+3), creating a distinctive lilting rhythm. Commonly used in khayal performances and semi-classical Kathak compositions that require a more nuanced rhythmic feel.",
        icon: "waveform.path",
        imageName: "jhaptal_card",
        meaningDescription: "An asymmetric 10-beat cycle (2+3+2+3) — its lilting rhythm gives Khayal its distinctive nuance."
    )

    // ─── Ektaal (12 beats) ─────────────────────────────────

    static let ektaal = Taal(
        id: "ektaal",
        name: "Ektaal",
        hindiName: "12 Beats",
        totalBeats: 12,
        vibhaags: [2, 2, 2, 2, 2, 2],
        bols: [
            "Dhin", "Dhin",                    // Vibhaag 1  (Sam)
            "DhaGe", "TiRaKiTa",              // Vibhaag 2  (Khaali)
            "Tu",  "Na",                       // Vibhaag 3  (Taali)
            "Kat", "Ta",                       // Vibhaag 4  (Khaali)
            "DhaGe", "TiRaKiTa",              // Vibhaag 5  (Taali)
            "Dhi", "Na"                        // Vibhaag 6  (Taali)
        ],
        markers: [
            1:  .sam,
            3:  .khaali,
            5:  .taali,
            7:  .khaali,
            9:  .taali,
            11: .taali
        ],
        description: "A 12-beat cycle divided into six pairs, used extensively in slow-tempo (vilambit) compositions. Its symmetrical structure allows for elaborate improvisations and is favored in classical Kathak for its meditative, expansive quality.",
        icon: "waveform.path",
        imageName: "ektaal_card",
        meaningDescription: "A meditative 12-beat cycle of six pairs — favored for slow, expansive Vilambit compositions."
    )
}
