import Foundation
import SwiftData

@Model
final class PracticeSessionRecord: Identifiable {
    @Attribute(.unique) var id: String
    var date: Date
    var taalId: String
    var taalName: String
    var graceScore: Double
    var postureAccuracy: Double
    var stepAccuracy: Double
    var timingPrecision: Double
    var durationSeconds: Double
    var strongestRegion: String
    var weakestRegion: String

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        taalId: String,
        taalName: String,
        graceScore: Double,
        postureAccuracy: Double,
        stepAccuracy: Double,
        timingPrecision: Double,
        durationSeconds: Double,
        strongestRegion: String,
        weakestRegion: String
    ) {
        self.id = id
        self.date = date
        self.taalId = taalId
        self.taalName = taalName
        self.graceScore = graceScore
        self.postureAccuracy = postureAccuracy
        self.stepAccuracy = stepAccuracy
        self.timingPrecision = timingPrecision
        self.durationSeconds = durationSeconds
        self.strongestRegion = strongestRegion
        self.weakestRegion = weakestRegion
    }
}
