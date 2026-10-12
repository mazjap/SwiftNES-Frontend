import SwiftUI

/// One button's current binding. Tapping it waits for a new key or control;
/// tapping again cancels.
struct BindingRow: View {
    let title: String
    let boundTo: [String]
    let target: BindingTarget

    @Environment(InputManager.self) private var input

    var body: some View {
        LabeledContent(title) {
            Button(buttonTitle, action: toggleCapture)
        }
    }

    private var isCapturing: Bool {
        input.capturing == target
    }

    private var buttonTitle: String {
        if isCapturing {
            switch target {
            case .keyboard: "Press a Key…"
            case .gamepad: "Press a Button…"
            }
        } else if boundTo.isEmpty {
            "Not Set"
        } else {
            boundTo.formatted(.list(type: .or))
        }
    }

    private func toggleCapture() {
        if isCapturing {
            input.cancelCapture()
        } else {
            input.beginCapture(target)
        }
    }
}
