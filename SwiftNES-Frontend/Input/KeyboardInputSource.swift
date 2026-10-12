import Foundation
import GameController

/// Feeds hardware keyboard presses into `InputState` as player one.
///
/// Uses GameController's `GCKeyboard` rather than SwiftUI key events: it
/// reports every key's press and release directly, modifiers included (so Shift
/// can be a button), with no key repeat, and no matter which view has focus.
/// This works for Mac keyboards and iPad hardware keyboards alike.
@MainActor
final class KeyboardInputSource {
    /// While set, the next key pressed goes here instead of to the game.
    var capture: ((KeyboardKey) -> Void)?

    private let state: InputState
    private let settings: ControlSettings

    init(state: InputState, settings: ControlSettings) {
        self.state = state
        self.settings = settings
    }

    func start() {
        let center = NotificationCenter.default

        // These observers live as long as the app does. `[weak self]` keeps
        // them from being what keeps this source alive.
        center.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.attachKeyboard() }
        }
        center.addObserver(forName: .GCKeyboardDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.state.releaseAll(from: .keyboard) }
        }

        attachKeyboard()
    }

    func handle(_ key: KeyboardKey, isPressed: Bool) {
        if let capture {
            if isPressed {
                capture(key)
            }

            return
        }

        guard let button = settings.keyboardKeymap.button(for: key) else { return }

        if isPressed {
            state.press(button.nesButton, for: .one, from: .keyboard)
        } else {
            state.release(button.nesButton, for: .one, from: .keyboard)
        }
    }

    private func attachKeyboard() {
        // Every connected keyboard is merged into this one coalesced keyboard
        GCKeyboard.coalesced?.keyboardInput?.keyChangedHandler = { [weak self] _, _, keyCode, isPressed in
            // GameController calls this on the device's handler queue, which is main by default
            MainActor.assumeIsolated {
                self?.handle(KeyboardKey(keyCode), isPressed: isPressed)
            }
        }
    }
}
