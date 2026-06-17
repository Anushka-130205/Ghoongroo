import SwiftUI

// MARK: - Discover Kathak Data Model

struct DiscoverModule: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let topics: [DiscoverTopic]
}

struct DiscoverTopic: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let sceneType: SceneType
    let steps: [DiscoverStep]

    enum SceneType {
        case posture
        case abhinaya
        case essence
    }
}

struct DiscoverStep: Identifiable {
    let id = UUID()
    let stepNumber: Int
    let title: String
    let description: String
    /// Key for the visual scene — drives pose + overlay selection
    let visualKey: String
    /// Start pose key (dancer begins here)
    var startPoseKey: String = ""
    /// End pose key (dancer transitions to this)
    var endPoseKey: String = ""
}

// MARK: - Static Content Library
// Character: Female Kathak dancer in white Anarkali, gold borders,
// dupatta, ghungroo, classical bun, minimal flowers, red bindi.

private let accent = Color.orange

extension DiscoverModule {

    static let allModules: [DiscoverModule] = [
        postureTraining,
        abhinayaTraining,
        heritageTraining
    ]

    // ═══════════════════════════════════════════════════════════
    // MODULE 1: Body & Posture Training (4 steps)
    // ═══════════════════════════════════════════════════════════

    static let postureTraining = DiscoverModule(
        id: "posture_training",
        title: "Body & Posture",
        subtitle: "Master the foundation of Kathak alignment",
        icon: "figure.stand",
        accentColor: accent,
        topics: [
            DiscoverTopic(
                id: "posture_steps",
                title: "Posture Training",
                subtitle: "Four steps to perfect alignment",
                icon: "figure.stand",
                accentColor: accent,
                sceneType: .posture,
                steps: [
                    DiscoverStep(
                        stepNumber: 1,
                        title: "Foundational Stance",
                        description: "Place feet slightly apart, soften the knees, and straighten the spine. Shoulders relax symmetrically, arms curve softly at your sides. The Anarkali skirt falls in elegant folds, and ghungroo are silent. This stable base supports every movement in Kathak.",
                        visualKey: "pose_foundation",
                        startPoseKey: "relaxed",
                        endPoseKey: "pose_foundation"
                    ),
                    DiscoverStep(
                        stepNumber: 2,
                        title: "Vertical Spine Alignment",
                        description: "Stand fully upright, engaging the core and lifting the ribcage. Chin is slightly lifted, shoulders level, and hips centered. The silhouette forms one clean vertical line from bun to ankles, providing the axis for spins.",
                        visualKey: "pose_spine",
                        startPoseKey: "pose_foundation",
                        endPoseKey: "pose_spine"
                    ),
                    DiscoverStep(
                        stepNumber: 3,
                        title: "Balanced Arm Frame",
                        description: "Raise both arms in a controlled semicircle at chest height. Elbows are lifted, and wrists are soft. Keep the spine perfectly upright and shoulders level. This frame helps maintain balance and creates a beautiful silhouette.",
                        visualKey: "pose_arm_frame",
                        startPoseKey: "pose_spine",
                        endPoseKey: "pose_arm_frame"
                    ),
                    DiscoverStep(
                        stepNumber: 4,
                        title: "Controlled Arm Extension",
                        description: "Extend one arm outward in a graceful curved line at shoulder height, while the opposite arm remains curved near the torso. Lower body remains stable and grounded. Shoulders must stay level as the sleeve follows the arm's curve.",
                        visualKey: "pose_arm_extend",
                        startPoseKey: "pose_arm_frame",
                        endPoseKey: "pose_arm_extend"
                    )
                ]
            )
        ]
    )

    // ═══════════════════════════════════════════════════════════
    // MODULE 2: Expression & Abhinaya Training (4 steps)
    // ═══════════════════════════════════════════════════════════

    static let abhinayaTraining = DiscoverModule(
        id: "abhinaya_training",
        title: "Expression & Abhinaya",
        subtitle: "The art of storytelling through face and eyes",
        icon: "face.smiling.fill",
        accentColor: accent,
        topics: [
            DiscoverTopic(
                id: "abhinaya_steps",
                title: "Expression Training",
                subtitle: "Four steps to master emotional clarity",
                icon: "face.smiling.fill",
                accentColor: accent,
                sceneType: .abhinaya,
                steps: [
                    DiscoverStep(
                        stepNumber: 1,
                        title: "Nava Rasa – Emotion",
                        description: "Maintain a neutral body posture while focusing entirely on the face. Channel Shringara (grace) with a subtle, controlled smile and glistening eyes. This exercise builds micro-expression control for storytelling.",
                        visualKey: "expression_bhava",
                        startPoseKey: "relaxed",
                        endPoseKey: "expression_bhava"
                    ),
                    DiscoverStep(
                        stepNumber: 2,
                        title: "Drishti – Eye Focus",
                        description: "Keep the head perfectly steady. Shift only the eyes diagonally upward with precision. The audience follows your story through your gaze, making eye control essential for storytelling.",
                        visualKey: "expression_drishti",
                        startPoseKey: "expression_bhava",
                        endPoseKey: "expression_drishti"
                    ),
                    DiscoverStep(
                        stepNumber: 3,
                        title: "Hand Mudra Storytelling",
                        description: "Angle the upper body with grace and hold a classical mudra like Pataka. Focus your eyes directly on your fingertips. The facial expression must align with the hand gesture to create a unified narrative.",
                        visualKey: "expression_mudra",
                        startPoseKey: "expression_drishti",
                        endPoseKey: "expression_mudra"
                    ),
                    DiscoverStep(
                        stepNumber: 4,
                        title: "Combined Expression",
                        description: "Extend one arm in a storytelling mudra while maintaining a stable posture. Align your eyes with the hand's direction and project a strong, dramatic gaze. This fusion is the essence of Abhinaya.",
                        visualKey: "expression_combined",
                        startPoseKey: "expression_mudra",
                        endPoseKey: "expression_combined"
                    )
                ]
            )
        ]
    )

    // ═══════════════════════════════════════════════════════════
    // MODULE 3: Visual Heritage & Grace (4 steps)
    // ═══════════════════════════════════════════════════════════

    static let heritageTraining = DiscoverModule(
        id: "heritage_training",
        title: "Visual Heritage & Grace",
        subtitle: "The aesthetic beauty and classical identity",
        icon: "sparkles",
        accentColor: accent,
        topics: [
            DiscoverTopic(
                id: "heritage_steps",
                title: "Heritage Training",
                subtitle: "Four steps to aesthetic mastery",
                icon: "sparkles",
                accentColor: accent,
                sceneType: .essence,
                steps: [
                    DiscoverStep(
                        stepNumber: 1,
                        title: "Chakkars – Spin Prep",
                        description: "Prepare for a spin (Chakkar) by positioning your feet precisely and extending your arms in a soft circular frame. Balance is key as the Anarkali skirt begins to lift naturally, preparing for the rotation.",
                        visualKey: "heritage_spin_prep",
                        startPoseKey: "relaxed",
                        endPoseKey: "heritage_spin_prep"
                    ),
                    DiscoverStep(
                        stepNumber: 2,
                        title: "Mid-Spin Grace",
                        description: "As you rotate, maintain a perfectly upright spine and level chin. The flared Anarkali skirt moves in a beautiful, circular motion, creating a visual halo around the dancer. Control your arms to maintain momentum and grace.",
                        visualKey: "heritage_mid_spin",
                        startPoseKey: "heritage_spin_prep",
                        endPoseKey: "heritage_mid_spin"
                    ),
                    DiscoverStep(
                        stepNumber: 3,
                        title: "Costume Flow Emphasis",
                        description: "Focus on the fluid motion of the dupatta and the white-and-gold Anarkali fabric. Even subtle movements highlight the fine draping and the elegant silhouette, reinforcing the classical Kathak identity.",
                        visualKey: "heritage_costume_flow",
                        startPoseKey: "heritage_mid_spin",
                        endPoseKey: "heritage_costume_flow"
                    ),
                    DiscoverStep(
                        stepNumber: 4,
                        title: "Cultural Identity Pose",
                        description: "Arrive at a static, regal pose inspired by classical temple sculpture. Hold a composed mudra at chest level with a calm, confident expression. This pose reflects the ancient roots and dignified presence of a Kathak artist.",
                        visualKey: "heritage_cultural_pose",
                        startPoseKey: "heritage_costume_flow",
                        endPoseKey: "heritage_cultural_pose"
                    )
                ]
            )
        ]
    )
}
