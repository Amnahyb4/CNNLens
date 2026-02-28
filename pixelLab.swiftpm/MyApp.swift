import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LandingView()
            }
            .preferredColorScheme(.dark)
        }
    }
}
