import SwiftUI
import TodoCounterFeature

@main
struct TodoCounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: ContentView.liveStore)
        }
    }
}
