import Foundation
import GameController
import Observation
import SwiftNES

/// Feeds game controllers into `InputState`: the first one connected is
/// player one, the second is player two.
@MainActor
@Observable
final class GamepadInputSource {
    typealias Player = NES.Controller.Player

    /// How many controllers are currently assigned to players.
    private(set) var connectedCount = 0

    /// While set, the next control pressed goes here instead of to the game.
    @ObservationIgnored var capture: ((GamepadControl) -> Void)?

    @ObservationIgnored private var slots: [Player: GCController] = [:]
    @ObservationIgnored private var pressedControls: [Player: Set<GamepadControl>] = [:]
    @ObservationIgnored private let state: InputState
    @ObservationIgnored private let settings: ControlSettings

    /// How far a thumbstick has to move before it counts as a direction. High
    /// enough to ignore drift, low enough that diagonals register.
    private static let stickThreshold: Float = 0.5

    init(state: InputState, settings: ControlSettings) {
        self.state = state
        self.settings = settings
    }

    func start() {
        let center = NotificationCenter.default

        // These observers live as long as the app does. Neither reads the
        // notification's controller: both rescan the full list instead, which
        // also recovers from any missed notification.
        center.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.reconcile() }
        }
        center.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.reconcile() }
        }

        reconcile()
    }

    /// Frees the slots of controllers that went away, then assigns any new
    /// controllers to free slots.
    private func reconcile() {
        let connected = GCController.controllers()

        for (player, controller) in slots where !connected.contains(where: { $0 === controller }) {
            slots[player] = nil
            pressedControls[player] = nil
            state.releaseAll(from: .gamepad(player))
        }

        for controller in connected where !slots.values.contains(where: { $0 === controller }) {
            guard let player = Player.allCases.first(where: { slots[$0] == nil }) else { break }
            guard attach(controller, as: player) else { continue }

            slots[player] = controller
        }

        connectedCount = slots.count
    }

    /// - Returns: `false` if the controller has no gamepad profile to read.
    private func attach(_ controller: GCController, as player: Player) -> Bool {
        // The handlers ignore their arguments and read the controller back out
        // of its slot, so no GameController objects cross into the closure.
        // GameController calls them on the handler queue, which is main by default.
        if let gamepad = controller.extendedGamepad {
            gamepad.valueChangedHandler = { [weak self] _, _ in
                MainActor.assumeIsolated { self?.refresh(player) }
            }
        } else if let gamepad = controller.microGamepad {
            gamepad.valueChangedHandler = { [weak self] _, _ in
                MainActor.assumeIsolated { self?.refresh(player) }
            }
        } else {
            return false
        }

        controller.playerIndex = player == .one ? .index1 : .index2
        return true
    }

    /// Reads the controller's whole state and reports it.
    private func refresh(_ player: Player) {
        guard let controller = slots[player] else { return }

        var held: NES.Controller.Button = []
        var pressed: Set<GamepadControl> = []

        if let gamepad = controller.extendedGamepad {
            held.formUnion(Self.directions(of: gamepad.dpad))
            held.formUnion(Self.directions(of: gamepad.leftThumbstick))
            pressed = Set(GamepadControl.allCases.filter { $0.input(on: gamepad)?.isPressed == true })
        } else if let gamepad = controller.microGamepad {
            // Too few buttons to be worth remapping, so this layout is fixed
            held.formUnion(Self.directions(of: gamepad.dpad))
            if gamepad.buttonA.isPressed { held.insert(.a) }
            if gamepad.buttonX.isPressed { held.insert(.b) }
            if gamepad.buttonMenu.isPressed { held.insert(.start) }
        }

        let newlyPressed = pressed.subtracting(pressedControls[player] ?? [])
        pressedControls[player] = pressed

        if let capture {
            if let control = newlyPressed.min() {
                capture(control)
            }

            return
        }

        for control in pressed {
            if let button = settings.gamepadKeymap.button(for: control) {
                held.insert(button.nesButton)
            }
        }

        state.setHeld(held, for: player, from: .gamepad(player))
    }

    /// Works for both D-pads, whose axes are always -1, 0, or 1, and analog sticks.
    private static func directions(of pad: GCControllerDirectionPad) -> NES.Controller.Button {
        var directions: NES.Controller.Button = []

        if pad.yAxis.value > stickThreshold { directions.insert(.up) }
        if pad.yAxis.value < -stickThreshold { directions.insert(.down) }
        if pad.xAxis.value < -stickThreshold { directions.insert(.left) }
        if pad.xAxis.value > stickThreshold { directions.insert(.right) }

        return directions
    }
}
