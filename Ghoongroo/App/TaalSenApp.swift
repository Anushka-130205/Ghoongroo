import SwiftUI
import SwiftData

// MARK: - Ghoongroo
// Swift Student Challenge App — Practice Kathak with AI-powered pose feedback

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct GhoongrooApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(KathakTheme.warmGold)
                .modelContainer(DatabaseManager.shared.container)
        }
    }
}
