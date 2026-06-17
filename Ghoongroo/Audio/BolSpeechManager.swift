import AVFoundation

final class BolSpeechManager {

    static let shared = BolSpeechManager()

    var isEnabled = true

    private let synthesizer = AVSpeechSynthesizer()

    private let bolIPAMap: [String: String] = [
        "dha": "d̪ʱa",
        "dhi" : "dhi",
        "ta":  "t̪a",
        "tin": "t̪ɪn",
        "na":  "na",
        "ge":  "ɡe",
        "kat": "kət",
        "thei": "t̪ʱeː",
        "tat": "t̪ət̪",
        "aa": "aː",
        "tirakita" : "t̪ɪɾəkɪt̪ə",
        "tu" : "tu",
        "dhage": "d̪ʱaɡe"
    ]

    private init() {}

    func speakBol(_ bol: String) {
        Task { @MainActor in
            guard self.isEnabled else { return }

            let normalizedBol = bol.lowercased()
            let attributed = NSMutableAttributedString(string: normalizedBol)

            if let ipa = self.bolIPAMap[normalizedBol] {
                attributed.addAttribute(
                    NSAttributedString.Key(rawValue: AVSpeechSynthesisIPANotationAttribute),
                    value: ipa,
                    range: NSRange(location: 0, length: normalizedBol.count)
                )
            }

            let utterance = AVSpeechUtterance(attributedString: attributed)
            utterance.voice = AVSpeechSynthesisVoice(language: "hi-IN")
            utterance.rate = 0.45
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0

            self.synthesizer.stopSpeaking(at: .immediate)
            self.synthesizer.speak(utterance)
        }
    }

    func stop() {
        Task { @MainActor in
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
            }
        }
    }
}

extension BolSpeechManager: @unchecked Sendable {}
