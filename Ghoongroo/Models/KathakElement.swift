import SwiftUI

// MARK: - Kathak Element (Lean Data Model)

/// Pure data model for Kathak learning elements. Contains only lesson content
/// with zero scoring logic. All evaluation happens in GraceScoreEngine.

struct KathakElement: Identifiable {
    let id = UUID()
    let name: String
    let hindiName: String
    let icon: String
    let color: Color
    let difficulty: Difficulty
    let steps: [Step]
    
    struct Step: Identifiable {
        let id = UUID()
        let title: String
        let description: String
    }
    
    enum Difficulty: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
    
    // MARK: - Content Library
    
    static func elements(for difficulty: Difficulty) -> [KathakElement] {
        switch difficulty {
        case .beginner:
            return beginnerElements
        case .intermediate:
            return intermediateElements
        case .advanced:
            return advancedElements
        }
    }
    
    // MARK: - Beginner
    
    private static let beginnerElements: [KathakElement] = [
        KathakElement(
            name: "Namaskar",
            hindiName: "नमस्कार",
            icon: "hands.sparkles.fill",
            color: KathakTheme.warmGold,
            difficulty: .beginner,
            steps: [
                Step(title: "Stand Tall", description: "Stand with feet together, spine vertical. The Anarkali falls in clean vertical folds. Arms rest at sides, ghungroo silent at both ankles. Gaze forward."),
                Step(title: "Join Palms", description: "Bring palms together at chest level, fingertips pointing upward at chin height. The dupatta drapes over one forearm, framing the Namaskar gesture naturally."),
                Step(title: "Bow Gently", description: "Incline the upper body forward with a controlled hinge at the waist. The spine stays aligned — the Anarkali bodice follows the torso's incline without creasing."),
                Step(title: "Return", description: "Rise back to standing with grace and control. Arms return to sides, palms release. The dupatta settles. Arrive back at Sama Sthiti — still and composed.")
            ]
        ),
        KathakElement(
            name: "Thaat",
            hindiName: "ठाट",
            icon: "figure.stand",
            color: KathakTheme.saffron,
            difficulty: .beginner,
            steps: [
                Step(title: "Foundation", description: "Stand with feet shoulder-width apart, weight evenly distributed. The Anarkali's flare opens slightly with the wider stance. Ghoongroo rest silently at both ankles."),
                Step(title: "Knee Bend", description: "Bend both knees outward gently, lowering the center of gravity. The Anarkali hem lifts slightly, revealing the ghungroo. The spine remains vertical throughout."),
                Step(title: "Arms Extended", description: "Raise both arms to shoulder height with soft elbow curves. The sleeves follow the semicircular arm shape. The dupatta flows along one arm's arc without pulling the torso."),
                Step(title: "Hold & Breathe", description: "Maintain the Thaat stance with steady breath. Eyes focused forward, shoulders level. The entire silhouette — bun, spine, Anarkali — forms a balanced, symmetrical shape.")
            ]
        ),
        KathakElement(
            name: "Tatkaar",
            hindiName: "तत्कार",
            icon: "shoe.fill",
            color: KathakTheme.terracotta,
            difficulty: .beginner,
            steps: [
                Step(title: "Flat Foot", description: "Place the entire right foot flat on the ground, heel first. The ghungroo produce one clean sound on contact. The Anarkali hem shifts briefly with the weight transfer."),
                Step(title: "Right Strike", description: "Lift and strike the right foot flat with crisp precision. Weight transfers fully. The standing left leg remains stable, ghungroo silent on that ankle."),
                Step(title: "Left Strike", description: "Strike the left foot flat, alternating the rhythm. Each foot produces a distinct ghungroo sound. The Anarkali sways subtly with each weight transfer."),
                Step(title: "Build Speed", description: "Gradually increase the speed of alternating strikes while maintaining clarity in each sound. The dupatta stays controlled, the spine vertical, the silhouette stable.")
            ]
        )
    ]
    
    // MARK: - Intermediate
    
    private static let intermediateElements: [KathakElement] = [
        KathakElement(
            name: "Teental",
            hindiName: "तीनताल",
            icon: "metronome.fill",
            color: KathakTheme.brightGold,
            difficulty: .intermediate,
            steps: [
                Step(title: "16 Beats", description: "Teental is a cycle of 16 beats in 4 vibhaags of 4 beats each. Stand in Sama Sthiti, hands at sides. Count each beat with subtle foot taps, ghungroo marking the rhythm."),
                Step(title: "Sam", description: "The first beat (Sam) is the most significant — all compositions resolve here. Mark Sam with a firm flat-foot strike; the ghungroo ring together in one unified sound."),
                Step(title: "Taali & Khaali", description: "Vibhaags 1, 2, 4 are Taali (clap); Vibhaag 3 is Khaali (wave). Clap hands at Taali marks, wave the right palm at Khaali. The dupatta arm stays level."),
                Step(title: "Practice", description: "Recite the bols aloud: Dha Dhin Dhin Dha | Dha Dhin Dhin Dha | Dha Tin Tin Ta | Ta Dhin Dhin Dha. Pair each bol with a foot strike — ghungroo singing the pattern.")
            ]
        ),
        KathakElement(
            name: "Hasta Mudra",
            hindiName: "हस्त मुद्रा",
            icon: "hand.raised.fill",
            color: KathakTheme.warmGold,
            difficulty: .intermediate,
            steps: [
                Step(title: "Pataka", description: "All fingers extended and pressed together, thumb bent at the palm base. Hold the hand at chest height against the Anarkali bodice for clear visibility. This mudra represents resolve or forest."),
                Step(title: "Tripataka", description: "Ring finger bends inward while other fingers stay straight — forming a crown shape. Raise the hand slightly above shoulder level. The white sleeve frames the gesture clearly."),
                Step(title: "Kartarimukha", description: "Index and middle finger spread apart like scissors, other fingers folded. Rotate the wrist gently to display the hand from multiple angles. Clean finger separation is visible at zoom focus."),
                Step(title: "Ardhachandra", description: "Thumb stretches away from the straight, joined fingers — a half-moon shape. Hold at eye level with the arm in a soft semicircular curve. The dupatta follows the arm line without obscuring the mudra.")
            ]
        )
    ]
    
    // MARK: - Advanced
    
    private static let advancedElements: [KathakElement] = [
        KathakElement(
            name: "Chakkar",
            hindiName: "चक्कर",
            icon: "arrow.trianglehead.2.counterclockwise.rotate.90",
            color: KathakTheme.saffron,
            difficulty: .advanced,
            steps: [
                Step(title: "Spot", description: "Fix your gaze on a single point at eye level. Stand in Sama Sthiti — spine is the rotation axis. The bun sits directly above the spine center, stabilizing head movement."),
                Step(title: "Pivot", description: "Push from the standing foot and begin rotating around the spine axis. Arms extend with soft curves to generate controlled momentum. The Anarkali begins to lift at the hem."),
                Step(title: "Head Snap", description: "As the body passes 270°, snap the head around to reacquire the spot. The bun, being centered, pivots cleanly. The body continues its arc without breaking the spin's balance."),
                Step(title: "Land", description: "Complete the full 360° rotation and land precisely where you began. The Anarkali settles back to vertical folds. The dupatta follows the deceleration, returning to its draped position.")
            ]
        ),
        KathakElement(
            name: "Jhaptal",
            hindiName: "झपताल",
            icon: "waveform",
            color: KathakTheme.terracotta,
            difficulty: .advanced,
            steps: [
                Step(title: "10 Beats", description: "Jhaptal is an asymmetric cycle of 10 beats: 2+3+2+3. Stand with feet together, ghungroo ready. The uneven groupings create a distinctive swing that challenges even trained dancers."),
                Step(title: "Vibhaag Structure", description: "Dhi Na | Dhi Dhi Na | Ti Na | Dhi Dhi Na. Each vibhaag has different length. Mark transitions with weight shifts between feet — the Anarkali sways with the asymmetric rhythm."),
                Step(title: "Sam Emphasis", description: "The Sam lands on 'Dhi' — mark it with a firm flat-foot stamp, ghungroo ringing. Every composition resolves on this beat. The body settles into Sama Sthiti momentarily at each Sam."),
                Step(title: "Master the Asymmetry", description: "The uneven vibhaag lengths make Jhaptal musically rich but physically demanding. Let the body internalize the 2-3-2-3 grouping through repeated foot patterns until the rhythm feels natural.")
            ]
        ),
        KathakElement(
            name: "Ektaal",
            hindiName: "एकताल",
            icon: "waveform.circle.fill",
            color: KathakTheme.brightGold,
            difficulty: .advanced,
            steps: [
                Step(title: "12 Beats", description: "Ektaal has 12 beats in 6 vibhaags of 2 beats each. Stand in Thaat position — knees slightly bent, arms with soft curves. The slow cycle gives each beat space and weight."),
                Step(title: "Slow Grandeur", description: "Often performed in Vilambit laya (very slow tempo). Each beat extends, allowing the Anarkali to settle fully between movements. The dupatta drape remains undisturbed at this measured pace."),
                Step(title: "Bol Pattern", description: "Dhin Dhin | DhaGe TiRaKiTa | Tu Na | Ka Ta | DhaGe TiRaKiTa | Dhi Na. Pair each bol with controlled foot placements — ghungroo articulate each syllable with precision."),
                Step(title: "Advanced Layakari", description: "Master speed divisions: Dugun (2×) doubles the foot strikes per beat; Chaugun (4×) quadruples them. The ghungroo must remain clear at every speed. The body stays controlled and centered.")
            ]
        )
    ]
}
