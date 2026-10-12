import Foundation
import Observation
import SwiftNES

/// Owns everything input: the merged state, the settings, and the devices
/// feeding them. Views reach it through the environment.
@MainActor
@Observable
final class InputManager {
    let state: InputState
    let settings: ControlSettings
    let gamepads: GamepadInputSource
    let keyboard: KeyboardInputSource

    /// The button waiting for a new key or control, if settings is rebinding one.
    private(set) var capturing: BindingTarget?

    @ObservationIgnored private var hasStarted = false

    init(controllers: NES.Controller.Inputs, defaults: UserDefaults = .standard) {
        let settings = ControlSettings(defaults: defaults)
        let state = InputState(controllers: controllers)
        state.suppressesOpposingDirections = settings.suppressesOpposingDirections

        self.settings = settings
        self.state = state
        self.gamepads = GamepadInputSource(state: state, settings: settings)
        self.keyboard = KeyboardInputSource(state: state, settings: settings)

        settings.onChange = { [weak self] in
            self?.settingsChanged()
        }
    }

    /// Starts listening for devices. Safe to call more than once.
    func start() {
        guard !hasStarted else { return }

        hasStarted = true
        keyboard.start()
        gamepads.start()
    }

    /// Lets go of everything, for when the app loses focus and would miss the
    /// releases of anything still held.
    func releaseAll() {
        state.releaseAll()
    }

    /// Sends the next key or control pressed to `target` instead of the game.
    func beginCapture(_ target: BindingTarget) {
        cancelCapture()
        state.releaseAll()
        capturing = target

        switch target {
        case let .keyboard(button):
            keyboard.capture = { [weak self] key in
                self?.finishCapture(key, for: button)
            }
        case let .gamepad(button):
            gamepads.capture = { [weak self] control in
                self?.finishCapture(control, for: button)
            }
        }
    }

    func cancelCapture() {
        capturing = nil
        keyboard.capture = nil
        gamepads.capture = nil
    }

    private func finishCapture(_ key: KeyboardKey, for button: ControllerButton) {
        // Escape cancels, so it can't be bound
        if key != .escape {
            settings.keyboardKeymap.bind(key, to: button)
        }

        cancelCapture()
    }

    private func finishCapture(_ control: GamepadControl, for button: ControllerButton) {
        settings.gamepadKeymap.bind(control, to: button)
        cancelCapture()
    }

    private func settingsChanged() {
        state.suppressesOpposingDirections = settings.suppressesOpposingDirections

        // A key held across a rebind would be released as a different button
        // than it was pressed as, leaving the old one stuck. Start clean instead.
        state.releaseAll()
    }
}
