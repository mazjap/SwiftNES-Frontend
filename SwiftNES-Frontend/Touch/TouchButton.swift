import SwiftUI

/// An on-screen A, B, Start, or Select button, held for as long as it's touched.
struct TouchButton: View {
    let button: ControllerButton

    @Environment(InputManager.self) private var input

    /// Resets itself if the system cancels the touch, which a plain
    /// `onEnded` would miss, leaving the button stuck down.
    @GestureState private var isTouching = false

    var body: some View {
        Text(button.name)
            .font(isFaceButton ? .title2.bold() : .footnote.bold())
            .frame(
                width: isFaceButton ? TouchControlMetrics.faceButtonSize : TouchControlMetrics.menuButtonWidth,
                height: isFaceButton ? TouchControlMetrics.faceButtonSize : TouchControlMetrics.menuButtonHeight
            )
            .background(isHeld ? .secondary : .tertiary, in: .capsule)
            .frame(minHeight: TouchControlMetrics.minimumTapSize)
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isTouching) { _, isTouching, _ in
                        isTouching = true
                    }
            )
            .onChange(of: isTouching) { _, isTouching in
                setPressed(isTouching)
            }
            .accessibilityAddTraits(.isButton)
    }

    private var isFaceButton: Bool {
        button == .a || button == .b
    }

    private var isHeld: Bool {
        input.state.buttons(for: .one, from: .touch).contains(button.nesButton)
    }

    private func setPressed(_ isPressed: Bool) {
        if isPressed {
            input.state.press(button.nesButton, for: .one, from: .touch)
        } else {
            input.state.release(button.nesButton, for: .one, from: .touch)
        }
    }
}
