import SwiftNES

/// One button on an NES controller.
///
/// `NES.Controller.Button` is an option set shaped for the hardware's shift
/// register. This is the same eight buttons as a plain enum, so they can be
/// listed, stored in keymaps, and shown in settings.
enum ControllerButton: String, CaseIterable, Codable, Identifiable, Sendable {
    case a, b, select, start, up, down, left, right

    var id: Self { self }

    var nesButton: NES.Controller.Button {
        switch self {
        case .a: .a
        case .b: .b
        case .select: .select
        case .start: .start
        case .up: .up
        case .down: .down
        case .left: .left
        case .right: .right
        }
    }

    var name: String {
        switch self {
        case .a: "A"
        case .b: "B"
        case .select: "Select"
        case .start: "Start"
        case .up: "Up"
        case .down: "Down"
        case .left: "Left"
        case .right: "Right"
        }
    }

    static let directions: [ControllerButton] = [.up, .down, .left, .right]

    /// The buttons a gamepad can rebind. Its D-pad and left stick always steer.
    static let gamepadRemappable: [ControllerButton] = [.a, .b, .select, .start]
}
