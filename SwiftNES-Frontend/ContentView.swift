import SwiftUI

struct ContentView: View {
    @Environment(EmulatorViewModel.self) private var emulator
    @Environment(\.scenePhase) private var scenePhase

    #if os(macOS)
    /// Tracks whether this window is key. `scenePhase` stays active on macOS
    /// when another window, like Settings, takes focus.
    @Environment(\.appearsActive) private var appearsActive
    #endif

    var body: some View {
        GameScreen(frame: emulator.currentFrame)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            #if os(iOS)
            .overlay(alignment: .bottom) {
                // A connected controller makes the on-screen one redundant
                if emulator.input.gamepads.connectedCount == 0 {
                    TouchControlsOverlay()
                }
            }
            #endif
            #if !os(macOS)
            .overlay(alignment: .topTrailing) {
                ControlsSettingsButton()
            }
            #endif
            .task {
                await emulator.run()
            }
            // Releases that happen while the app isn't active never reach it,
            // so anything held when focus leaves would stay stuck.
            .onChange(of: scenePhase) { _, phase in
                if phase != .active {
                    emulator.input.releaseAll()
                }
            }
            #if os(macOS)
            .onChange(of: appearsActive) { _, isActive in
                if !isActive {
                    emulator.input.releaseAll()
                }
            }
            #endif
    }
}

#Preview {
    let emulator = EmulatorViewModel()

    ContentView()
        .environment(emulator)
        .environment(emulator.input)
}
