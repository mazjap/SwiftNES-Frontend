import SwiftUI

/// Opens the controls settings in a sheet, for platforms without a Settings window.
struct ControlsSettingsButton: View {
    @State private var isShowingSettings = false

    var body: some View {
        Button("Controls", systemImage: "gamecontroller", action: showSettings)
            .labelStyle(.iconOnly)
            .padding()
            .sheet(isPresented: $isShowingSettings) {
                NavigationStack {
                    ControlsSettingsView()
                        .toolbar {
                            Button("Done", action: hideSettings)
                        }
                }
            }
    }

    private func showSettings() {
        isShowingSettings = true
    }

    private func hideSettings() {
        isShowingSettings = false
    }
}
