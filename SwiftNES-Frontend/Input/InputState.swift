import Observation
import SwiftNES

/// Every input source's held buttons, merged into what the emulator sees.
///
/// Sources report here rather than to the emulator directly. Each source's
/// buttons are kept separately and the emulator gets their union, so letting go
/// of A on a gamepad doesn't release it while A is still held on the keyboard.
@MainActor
@Observable
final class InputState {
    typealias Button = NES.Controller.Button
    typealias Player = NES.Controller.Player

    /// Drops Up+Down and Left+Right when both are held. Real hardware can't
    /// produce them, and some games misbehave if they see them.
    var suppressesOpposingDirections = true {
        didSet { publishAll() }
    }

    private var held: [InputSource: [Player: Button]] = [:]

    @ObservationIgnored private let controllers: NES.Controller.Inputs

    private static let opposingDirections: [Button] = [[.up, .down], [.left, .right]]

    init(controllers: NES.Controller.Inputs) {
        self.controllers = controllers
    }

    /// The buttons one source is holding for `player`.
    func buttons(for player: Player, from source: InputSource) -> Button {
        held[source]?[player] ?? []
    }

    /// What the emulator sees for `player`: every source merged, with opposing
    /// directions dropped if that's enabled.
    func buttons(for player: Player) -> Button {
        var merged = held.values.reduce(into: Button()) { $0.formUnion($1[player] ?? []) }

        if suppressesOpposingDirections {
            for pair in Self.opposingDirections where merged.isSuperset(of: pair) {
                merged.subtract(pair)
            }
        }

        return merged
    }

    func press(_ buttons: Button, for player: Player, from source: InputSource) {
        update(player, from: source) { $0.formUnion(buttons) }
    }

    func release(_ buttons: Button, for player: Player, from source: InputSource) {
        update(player, from: source) { $0.subtract(buttons) }
    }

    /// Replaces everything `source` is holding for `player`. For sources that
    /// report their full state at once, like gamepads.
    func setHeld(_ buttons: Button, for player: Player, from source: InputSource) {
        update(player, from: source) { $0 = buttons }
    }

    func releaseAll(from source: InputSource) {
        guard held[source] != nil else { return }

        held[source] = nil
        publishAll()
    }

    func releaseAll() {
        guard !held.isEmpty else { return }

        held.removeAll()
        publishAll()
    }

    private func update(_ player: Player, from source: InputSource, _ change: (inout Button) -> Void) {
        let old = buttons(for: player, from: source)
        var new = old
        change(&new)

        // Gamepads report on every tiny stick movement. Skip the write, and the
        // view updates it would trigger, when nothing actually changed.
        guard new != old else { return }

        held[source, default: [:]][player] = new
        publish(player)
    }

    private func publish(_ player: Player) {
        controllers.set(buttons(for: player), for: player)
    }

    private func publishAll() {
        for player in Player.allCases {
            publish(player)
        }
    }
}
