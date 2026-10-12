import SwiftUI

/// The on-screen controller for touch devices: D-pad on the left, buttons on the right.
///
/// Start and Select sit above A and B rather than in the middle, so in
/// landscape they stay off the game screen.
struct TouchControlsOverlay: View {
    var body: some View {
        HStack(alignment: .bottom) {
            DPad()

            Spacer()

            VStack(alignment: .trailing) {
                HStack {
                    TouchButton(button: .select)
                    TouchButton(button: .start)
                }

                HStack {
                    TouchButton(button: .b)
                    TouchButton(button: .a)
                }
            }
        }
        .padding()
    }
}
