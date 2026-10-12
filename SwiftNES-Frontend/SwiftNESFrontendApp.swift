import SwiftUI

@main
struct SwiftNESFrontendApp: App {
    @State private var emulator = EmulatorViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(emulator)
                .environment(emulator.input)
        }

        #if os(macOS)
        Settings {
            ControlsSettingsView()
                .environment(emulator.input)
        }
        #endif
    }
}
