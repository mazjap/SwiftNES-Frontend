import SwiftNES
import SwiftUI

/// An on-screen D-pad. One touch picks from eight directions, so sliding a
/// thumb around it moves through the diagonals the way a real D-pad rocks.
struct DPad: View {
    typealias Button = NES.Controller.Button

    @Environment(InputManager.self) private var input

    /// Resets itself if the system cancels the touch, which a plain
    /// `onEnded` would miss, leaving a direction stuck down.
    @GestureState private var direction: Button = []

    private static let size = TouchControlMetrics.dPadSize
    private static let armLength = size / 3

    /// Counterclockwise from right, in 45° steps.
    private static let sectors: [Button] = [
        .right, [.up, .right], .up, [.up, .left],
        .left, [.down, .left], .down, [.down, .right]
    ]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.tertiary)
                .frame(width: Self.armLength, height: Self.armLength)

            ForEach(ControllerButton.directions) { arm in
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHeld(arm) ? .secondary : .tertiary)
                    .frame(width: Self.armLength, height: Self.armLength)
                    .offset(offset(of: arm))
            }
        }
        .frame(width: Self.size, height: Self.size)
        .contentShape(.rect)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($direction) { value, direction, _ in
                    direction = Self.direction(at: value.location, in: Self.size)
                }
        )
        .onChange(of: direction) { old, new in
            input.state.release(old.subtracting(new), for: .one, from: .touch)
            input.state.press(new.subtracting(old), for: .one, from: .touch)
        }
        .accessibilityElement()
        .accessibilityLabel("D-pad")
    }

    /// The directions pressed by a touch at `point` on a D-pad `size` points square.
    static func direction(at point: CGPoint, in size: Double) -> Button {
        let dx = point.x - size / 2
        let dy = size / 2 - point.y // Flipped so up is positive

        guard (dx * dx + dy * dy).squareRoot() > size * TouchControlMetrics.dPadDeadZone else { return [] }

        // Rounding to the nearest multiple of 45° centers each sector on its direction
        let steps = Int((atan2(dy, dx) / (.pi / 4)).rounded())
        return sectors[(steps + 8) % 8]
    }

    private func isHeld(_ arm: ControllerButton) -> Bool {
        input.state.buttons(for: .one, from: .touch).contains(arm.nesButton)
    }

    private func offset(of arm: ControllerButton) -> CGSize {
        switch arm {
        case .up: CGSize(width: 0, height: -Self.armLength)
        case .down: CGSize(width: 0, height: Self.armLength)
        case .left: CGSize(width: -Self.armLength, height: 0)
        case .right: CGSize(width: Self.armLength, height: 0)
        default: .zero
        }
    }
}
