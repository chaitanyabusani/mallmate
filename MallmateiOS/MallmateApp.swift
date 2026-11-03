import SwiftUI

@main
struct MallmateApp: App {
    @StateObject private var model = MallmateModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .tint(MallmatePalette.green)
        }
    }
}
