/// A button being rebound in settings, and which kind of device the new input comes from.
enum BindingTarget: Hashable {
    case keyboard(ControllerButton)
    case gamepad(ControllerButton)
}
