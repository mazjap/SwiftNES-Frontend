import GameController

/// A rebindable button on an extended gamepad.
///
/// The D-pad and thumbsticks aren't listed because they always steer.
enum GamepadControl: String, CaseIterable, Codable, Comparable, Sendable {
    case buttonA, buttonB, buttonX, buttonY
    case leftShoulder, rightShoulder, leftTrigger, rightTrigger
    case menu, options
    case leftStickButton, rightStickButton

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var name: String {
        switch self {
        case .buttonA: "A"
        case .buttonB: "B"
        case .buttonX: "X"
        case .buttonY: "Y"
        case .leftShoulder: "Left Shoulder"
        case .rightShoulder: "Right Shoulder"
        case .leftTrigger: "Left Trigger"
        case .rightTrigger: "Right Trigger"
        case .menu: "Menu"
        case .options: "Options"
        case .leftStickButton: "Left Stick Press"
        case .rightStickButton: "Right Stick Press"
        }
    }

    /// This control's input on `gamepad`, if the gamepad has one.
    func input(on gamepad: GCExtendedGamepad) -> GCControllerButtonInput? {
        switch self {
        case .buttonA: gamepad.buttonA
        case .buttonB: gamepad.buttonB
        case .buttonX: gamepad.buttonX
        case .buttonY: gamepad.buttonY
        case .leftShoulder: gamepad.leftShoulder
        case .rightShoulder: gamepad.rightShoulder
        case .leftTrigger: gamepad.leftTrigger
        case .rightTrigger: gamepad.rightTrigger
        case .menu: gamepad.buttonMenu
        case .options: gamepad.buttonOptions
        case .leftStickButton: gamepad.leftThumbstickButton
        case .rightStickButton: gamepad.rightThumbstickButton
        }
    }

    /// Matches the NES layout by position rather than by letter: the NES has
    /// B on the left and A on the right, so the bottom face button (`buttonA`)
    /// is NES B and the right one (`buttonB`) is NES A.
    static let defaultKeymap = Keymap<GamepadControl>([
        .buttonA: .b,
        .buttonB: .a,
        .menu: .start,
        .options: .select
    ])
}
