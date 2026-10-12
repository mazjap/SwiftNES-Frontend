import SwiftNES
import SwiftUI

/// The emulator's output.
struct GameScreen: View {
    let frame: CGImage?

    #if os(macOS)
    @FocusState private var isFocused: Bool
    #endif

    var body: some View {
        Group {
            if let frame {
                Image(nativeImage: NativeImage(cgImage: frame))
            } else {
                Text("No frame :/")
                    .font(.largeTitle)
            }
        }
        .aspectRatio(Double(NES.PPU.Frame.width) / Double(NES.PPU.Frame.height), contentMode: .fit)
        #if os(macOS)
        // Game input is read through GameController, but AppKit still sees each
        // key press and beeps when no view handles it. Taking focus and claiming
        // every key keeps it quiet. Command shortcuts are left for the menus.
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .onAppear(perform: takeFocus)
        .onKeyPress(phases: .all, action: claim)
        #endif
    }

    #if os(macOS)
    private func takeFocus() {
        isFocused = true
    }

    private func claim(_ press: KeyPress) -> KeyPress.Result {
        press.modifiers.contains(.command) ? .ignored : .handled
    }
    #endif
}
