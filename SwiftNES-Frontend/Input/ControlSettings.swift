import Foundation
import Observation

/// The player's control preferences, saved to `UserDefaults`.
@MainActor
@Observable
final class ControlSettings {
    var keyboardKeymap: Keymap<KeyboardKey> {
        didSet { save(keyboardKeymap, forKey: Keys.keyboardKeymap) }
    }

    var gamepadKeymap: Keymap<GamepadControl> {
        didSet { save(gamepadKeymap, forKey: Keys.gamepadKeymap) }
    }

    var suppressesOpposingDirections: Bool {
        didSet {
            defaults.set(suppressesOpposingDirections, forKey: Keys.suppressesOpposingDirections)
            onChange?()
        }
    }

    /// Called after any setting changes.
    @ObservationIgnored var onChange: (() -> Void)?

    @ObservationIgnored private let defaults: UserDefaults

    private enum Keys {
        static let keyboardKeymap = "controls.keyboardKeymap"
        static let gamepadKeymap = "controls.gamepadKeymap"
        static let suppressesOpposingDirections = "controls.suppressesOpposingDirections"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Anything missing or unreadable falls back to the defaults
        keyboardKeymap = Self.load(forKey: Keys.keyboardKeymap, from: defaults) ?? KeyboardKey.defaultKeymap
        gamepadKeymap = Self.load(forKey: Keys.gamepadKeymap, from: defaults) ?? GamepadControl.defaultKeymap
        suppressesOpposingDirections = defaults.object(forKey: Keys.suppressesOpposingDirections) as? Bool ?? true
    }

    func resetToDefaults() {
        keyboardKeymap = KeyboardKey.defaultKeymap
        gamepadKeymap = GamepadControl.defaultKeymap
        suppressesOpposingDirections = true
    }

    private func save(_ value: some Encodable, forKey key: String) {
        // Keymaps are plain dictionaries of Codable values, so encoding can't fail
        defaults.set(try? JSONEncoder().encode(value), forKey: key)
        onChange?()
    }

    private static func load<Value: Decodable>(forKey key: String, from defaults: UserDefaults) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }

        return try? JSONDecoder().decode(Value.self, from: data)
    }
}
