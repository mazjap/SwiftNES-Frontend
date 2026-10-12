/// Which physical inputs press which NES buttons.
///
/// Several keys can press the same button, but each key presses only one.
struct Keymap<Key: Hashable & Comparable & Codable & Sendable>: Equatable, Codable, Sendable {
    private(set) var bindings: [Key: ControllerButton]

    init(_ bindings: [Key: ControllerButton]) {
        self.bindings = bindings
    }

    func button(for key: Key) -> ControllerButton? {
        bindings[key]
    }

    func keys(for button: ControllerButton) -> [Key] {
        bindings.filter { $0.value == button }.keys.sorted()
    }

    /// Makes `key` the only input for `button`. If `key` was pressing a
    /// different button, it stops.
    mutating func bind(_ key: Key, to button: ControllerButton) {
        bindings = bindings.filter { $0.value != button }
        bindings[key] = button
    }
}
