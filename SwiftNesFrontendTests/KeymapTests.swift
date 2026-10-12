import GameController
import Testing
@testable import SwiftNES_Frontend

@Suite("Keymap")
struct KeymapTests {
    @Test("Binding a key replaces the button's old keys")
    func testBindReplacesButtonKeys() {
        var keymap = GamepadControl.defaultKeymap

        keymap.bind(.buttonY, to: .a)

        #expect(keymap.keys(for: .a) == [.buttonY])
        #expect(keymap.button(for: .buttonB) == nil, "B used to press A")
    }

    @Test("Binding a key moves it off whatever it pressed before")
    func testBindMovesKey() {
        var keymap = GamepadControl.defaultKeymap

        keymap.bind(.buttonA, to: .start)

        #expect(keymap.button(for: .buttonA) == .start)
        #expect(keymap.keys(for: .b) == [], "buttonA used to press B")
        #expect(keymap.keys(for: .start) == [.buttonA])
    }

    @Test("Default keyboard layout")
    func testDefaultKeyboardLayout() {
        let keymap = KeyboardKey.defaultKeymap

        #expect(keymap.button(for: KeyboardKey(.keyX)) == .a)
        #expect(keymap.button(for: KeyboardKey(.keyZ)) == .b)
        #expect(keymap.button(for: KeyboardKey(.returnOrEnter)) == .start)
        #expect(keymap.button(for: KeyboardKey(.rightShift)) == .select)
        #expect(keymap.button(for: KeyboardKey(.upArrow)) == .up)
    }

    @Test("Key names")
    func testKeyNames() {
        #expect(KeyboardKey(.keyA).name == "A")
        #expect(KeyboardKey(.keyZ).name == "Z")
        #expect(KeyboardKey(.one).name == "1")
        #expect(KeyboardKey(.zero).name == "0")
        #expect(KeyboardKey(.F12).name == "F12")
        #expect(KeyboardKey(.rightShift).name == "Right Shift")
    }
}
