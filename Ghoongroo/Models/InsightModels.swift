import Foundation
import SwiftUI

// MARK: - Insight Types

enum InsightType {
    case timingDrift
    case postureInstability
    case rushingArms
    case perfectSam
    case balanceIssue
    case recovery
    // Positive (green) Kathak-specific detections
    case goodSpineAlignment
    case gracefulArms
    case cleanFootwork
    case steadyShoulders
    case properAramandi    // Correct knee bend
    
    var title: String {
        switch self {
        case .timingDrift: return "Timing Drift"
        case .postureInstability: return "Posture Instability"
        case .rushingArms: return "Rushing Arms"
        case .perfectSam: return "Perfect Sam"
        case .balanceIssue: return "Balance Issue"
        case .recovery: return "Recovery"
        case .goodSpineAlignment: return "Spine Aligned"
        case .gracefulArms: return "Graceful Arms"
        case .cleanFootwork: return "Clean Footwork"
        case .steadyShoulders: return "Steady Frame"
        case .properAramandi: return "Good Aramandi"
        }
    }
    
    var color: SwiftUI.Color {
        switch self {
        case .timingDrift: return KathakTheme.terracotta
        case .postureInstability: return KathakTheme.terracotta
        case .rushingArms: return KathakTheme.terracotta
        case .perfectSam: return .green
        case .balanceIssue: return KathakTheme.terracotta
        case .recovery: return .green
        case .goodSpineAlignment: return .green
        case .gracefulArms: return .green
        case .cleanFootwork: return .green
        case .steadyShoulders: return .green
        case .properAramandi: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .timingDrift: return "clock.badge.exclamationmark"
        case .postureInstability: return "figure.fall"
        case .rushingArms: return "hand.raised.slash.fill"
        case .perfectSam: return "star.fill"
        case .balanceIssue: return "exclamationmark.triangle.fill"
        case .recovery: return "arrow.uturn.up"
        case .goodSpineAlignment: return "figure.stand"
        case .gracefulArms: return "hands.sparkles.fill"
        case .cleanFootwork: return "shoe.fill"
        case .steadyShoulders: return "checkmark.shield.fill"
        case .properAramandi: return "figure.flexibility"
        }
    }
    
    var isPositive: Bool {
        switch self {
        case .perfectSam, .recovery, .goodSpineAlignment, .gracefulArms, 
             .cleanFootwork, .steadyShoulders, .properAramandi:
            return true
        default:
            return false
        }
    }
}

// MARK: - Practice Insight

/// A human-readable insight generated from raw pose and timing data.
struct PracticeInsight: Identifiable {
    let id = UUID()
    let timeRange: ClosedRange<Double> // Relative time in the session (seconds)
    let type: InsightType
    let message: String
    var phraseIndex: Int? = nil
    var location: CGPoint? = nil // Spatial coordinates for UI overlay
}

// MARK: - Dance Phrase

/// Represents a distinct section of practice, usually corresponding to one full cycle of the active Taal.
struct DancePhrase: Identifiable {
    let id = UUID()
    let cycleNumber: Int
    let startTime: Double
    let endTime: Double
    let stabilityScore: Double
    let insights: [PracticeInsight]
}

// MARK: - Video Annotation

/// Maps an insight to a specific timestamp for UI timeline integration.
struct VideoAnnotation: Identifiable {
    let id = UUID()
    let time: Double // Specific timestamp for timeline plotting
    let insight: PracticeInsight
}
