import Foundation
import SwiftUI
import SwiftUIRegistryShowcaseFeature

@main
struct SwiftUIRegistryShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .transformEnvironment(\.dynamicTypeSize) { size in
                    if ProcessInfo.processInfo.arguments.contains("-accessibility-size") {
                        size = .accessibility3
                    }
                }
                .transformEnvironment(\.layoutDirection) { direction in
                    if ProcessInfo.processInfo.arguments.contains("-right-to-left") {
                        direction = .rightToLeft
                    }
                }
        }
    }
}
