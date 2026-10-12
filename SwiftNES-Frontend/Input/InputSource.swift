import SwiftNES

/// Where a button press came from.
///
/// `InputState` tracks each source's buttons separately, so one device letting
/// go of a button doesn't release it while another is still holding it.
enum InputSource: Hashable, Sendable {
    case keyboard

    /// A game controller, identified by the player it's assigned to.
    case gamepad(NES.Controller.Player)

    case touch
}
