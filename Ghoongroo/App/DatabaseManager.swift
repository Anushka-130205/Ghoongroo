import Foundation
import SwiftData

@MainActor
final class DatabaseManager {
    static let shared = DatabaseManager()

    let container: ModelContainer
    let context: ModelContext

    private init() {
        do {
            let schema = Schema([
                PracticeSessionRecord.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
            context = ModelContext(container)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
}
