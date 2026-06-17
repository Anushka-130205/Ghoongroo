import SwiftUI
import Combine
import SwiftData

// MARK: - Dashboard Stats Manager
// Tracks practice statistics using @AppStorage for lightweight persistence (streaks,
// last score) and SwiftData for full session history.

@MainActor
final class DashboardStatsManager: ObservableObject {

    @AppStorage("streakCount") var streakCount: Int = 0
    @AppStorage("lastPracticeScore") var lastPracticeScore: Double = 0
    @AppStorage("totalPracticeSeconds") var totalPracticeSeconds: Double = 0
    @AppStorage("lastPracticeDateInterval") var lastPracticeDateInterval: Double = 0
    @AppStorage("practicedDaysJSON") var practicedDaysJSON: String = "[]"

    // MARK: - Day Status for Weekly Visualization

    enum DayStatus {
        case completed
        case missed
        case today
        case future
    }

    // MARK: - Published daily data (refreshed on appear)

    @Published var todaySessionCount: Int = 0
    @Published var todayBestScore: Double = 0
    @Published var todayTotalSeconds: Double = 0
    @Published var todayTaals: [String] = []
    @Published var recentHistory: [PracticeSessionRecord] = []
    @Published var allTimeBest: Double = 0

    // MARK: - Computed

    var totalPracticeTimeFormatted: String {
        let minutes = Int(totalPracticeSeconds) / 60
        let seconds = Int(totalPracticeSeconds) % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m \(seconds)s"
    }

    var todayPracticeTimeFormatted: String {
        let minutes = Int(todayTotalSeconds) / 60
        let seconds = Int(todayTotalSeconds) % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m \(seconds)s"
    }

    var lastPracticeDate: Date? {
        guard lastPracticeDateInterval > 0 else { return nil }
        return Date(timeIntervalSince1970: lastPracticeDateInterval)
    }

    var lastPracticeDateFormatted: String {
        guard let date = lastPracticeDate else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// Returns an array of 7 DayStatus values for the current week (Mon–Sun)
    var weeklyPracticeStatus: [DayStatus] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find the Monday of the current week
        let weekday = calendar.component(.weekday, from: today)
        // weekday: Sun=1, Mon=2, ..., Sat=7. Offset to make Mon=0
        let offset = (weekday + 5) % 7 // days since Monday
        guard let monday = calendar.date(byAdding: .day, value: -offset, to: today) else {
            return Array(repeating: .future, count: 7)
        }

        let practicedDates = decodePracticedDays()

        return (0..<7).map { dayIndex in
            guard let date = calendar.date(byAdding: .day, value: dayIndex, to: monday) else {
                return .future
            }
            let dateString = Self.dateFormatter.string(from: date)

            if calendar.isDate(date, inSameDayAs: today) {
                // Today: show as completed if practiced, otherwise in-progress
                return practicedDates.contains(dateString) ? .completed : .today
            } else if date > today {
                return .future
            } else {
                return practicedDates.contains(dateString) ? .completed : .missed
            }
        }
    }

    // MARK: - Refresh (call on view appear)

    func refreshDailyStats() {
        let context = DatabaseManager.shared.context

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        guard let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart) else { return }

        // Fetch today's sessions
        let todayPredicate = #Predicate<PracticeSessionRecord> { record in
            record.date >= todayStart && record.date < todayEnd
        }
        let todayDescriptor = FetchDescriptor<PracticeSessionRecord>(predicate: todayPredicate)
        let todayRecords = (try? context.fetch(todayDescriptor)) ?? []

        todaySessionCount = todayRecords.count
        todayBestScore = todayRecords.map(\.graceScore).max() ?? 0
        todayTotalSeconds = todayRecords.reduce(0) { $0 + $1.durationSeconds }
        todayTaals = Array(Set(todayRecords.map(\.taalName)))

        // Load last 10 sessions for recent history display
        var historyDescriptor = FetchDescriptor<PracticeSessionRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        historyDescriptor.fetchLimit = 10
        recentHistory = (try? context.fetch(historyDescriptor)) ?? []

        // All-time best
        let allSessionsDescriptor = FetchDescriptor<PracticeSessionRecord>()
        let allSessions = (try? context.fetch(allSessionsDescriptor)) ?? []
        allTimeBest = allSessions.map(\.graceScore).max() ?? 0
    }

    // MARK: - Record Practice Session

    func recordPractice(score: Double, durationSeconds: Double, taalId: String, taalName: String, scoreResult: ScoreResult? = nil) {
        // 1. Update lightweight AppStorage stats
        lastPracticeScore = score
        totalPracticeSeconds += durationSeconds

        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = lastPracticeDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 1 {
                // Consecutive day — increase streak
                streakCount += 1
            } else if daysBetween > 1 {
                // Streak broken — reset
                streakCount = 1
            }
            // Same day — no change to streak
        } else {
            // First practice ever
            streakCount = 1
        }

        lastPracticeDateInterval = Date().timeIntervalSince1970
        markTodayAsPracticed()

        // 2. Save full session record to SwiftData
        let context = DatabaseManager.shared.context
        let record = PracticeSessionRecord(
            id: UUID().uuidString,
            date: Date(),
            taalId: taalId,
            taalName: taalName,
            graceScore: score,
            postureAccuracy: scoreResult?.postureAccuracy ?? score,
            stepAccuracy: scoreResult?.stepAccuracy ?? score,
            timingPrecision: scoreResult?.timingPrecision ?? score,
            durationSeconds: durationSeconds,
            strongestRegion: scoreResult?.strongestRegion ?? "Unknown",
            weakestRegion: scoreResult?.weakestRegion ?? "Unknown"
        )
        context.insert(record)
        do {
            try context.save()
        } catch {
            print("[SwiftData] Failed to save session: \(error)")
        }

        // 3. Refresh published daily data
        refreshDailyStats()
    }

    // MARK: - Weekly Tracking Helpers

    private func markTodayAsPracticed() {
        var days = decodePracticedDays()
        let todayString = Self.dateFormatter.string(from: Date())
        if !days.contains(todayString) {
            days.append(todayString)
        }
        // Prune entries older than 7 days
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        days = days.filter { dateString in
            if let date = Self.dateFormatter.date(from: dateString) {
                return date >= sevenDaysAgo
            }
            return false
        }
        encodePracticedDays(days)
    }

    private func decodePracticedDays() -> [String] {
        guard let data = practicedDaysJSON.data(using: .utf8),
              let days = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return days
    }

    private func encodePracticedDays(_ days: [String]) {
        if let data = try? JSONEncoder().encode(days),
           let json = String(data: data, encoding: .utf8) {
            practicedDaysJSON = json
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
