import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main struct MyApp: App {
    init() {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
