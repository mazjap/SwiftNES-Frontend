import SwiftUI

/// Rebinding for keyboards and controllers, plus input options.
struct ControlsSettingsView: View {
    @Environment(InputManager.self) private var input

    var body: some View {
        @Bindable var settings = input.settings

        Form {
            Section("Keyboard") {
                ForEach(ControllerButton.allCases) { button in
                    BindingRow(
                        title: button.name,
                        boundTo: settings.keyboardKeymap.keys(for: button).map(\.name),
                        target: .keyboard(button)
                    )
                }
            }

            Section {
                ForEach(ControllerButton.gamepadRemappable) { button in
                    BindingRow(
                        title: button.name,
                        boundTo: settings.gamepadKeymap.keys(for: button).map(\.name),
                        target: .gamepad(button)
                    )
                    .disabled(input.gamepads.connectedCount == 0)
                }
            } header: {
                Text("Controller")
            } footer: {
                Text("The D-pad and left stick always steer. Connect a controller to rebind its buttons.")
            }

            Section {
                Toggle("Block Opposite Directions", isOn: $settings.suppressesOpposingDirections)
            } footer: {
                Text("A real NES controller can't press Up and Down, or Left and Right, at the same time. Some games misbehave if they see both.")
            }

            Section {
                Button("Reset to Defaults", role: .destructive, action: settings.resetToDefaults)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Controls")
        .onDisappear(perform: input.cancelCapture)
    }
}

#Preview {
    ControlsSettingsView()
        .environment(EmulatorViewModel().input)
}
