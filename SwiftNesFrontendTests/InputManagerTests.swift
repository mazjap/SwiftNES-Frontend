import GameController
import SwiftNES
import Testing
@testable import SwiftNES_Frontend

@MainActor
@Suite("Input Manager")
struct InputManagerTests {
    let controllers = NES.Controller.Inputs()
    let input: InputManager

    init() throws {
        input = InputManager(controllers: controllers, defaults: try .isolated())
    }

    // MARK: - Keyboard

    @Test("Mapped keys press and release player one's buttons")
    func testKeyboardMapping() {
        input.keyboard.handle(KeyboardKey(.keyX), isPressed: true)
        input.keyboard.handle(KeyboardKey(.leftArrow), isPressed: true)
        #expect(controllers.buttons(for: .one) == [.a, .left])

        input.keyboard.handle(KeyboardKey(.keyX), isPressed: false)
        #expect(controllers.buttons(for: .one) == .left)
    }

    @Test("Unmapped keys do nothing")
    func testUnmappedKey() {
        input.keyboard.handle(KeyboardKey(.keyQ), isPressed: true)

        #expect(controllers.buttons(for: .one) == [])
    }

    // MARK: - Rebinding

    @Test("Capturing binds the next key pressed, and it isn't sent to the game")
    func testKeyboardCapture() {
        input.beginCapture(.keyboard(.a))
        #expect(input.capturing == .keyboard(.a))

        input.keyboard.handle(KeyboardKey(.keyJ), isPressed: true)

        #expect(input.capturing == nil)
        #expect(input.settings.keyboardKeymap.keys(for: .a) == [KeyboardKey(.keyJ)])
        #expect(controllers.buttons(for: .one) == [], "The captured press shouldn't reach the game")

        input.keyboard.handle(KeyboardKey(.keyJ), isPressed: true)
        #expect(controllers.buttons(for: .one) == .a, "The new key should now press A")
    }

    @Test("Escape cancels a capture without binding")
    func testEscapeCancelsCapture() {
        input.beginCapture(.keyboard(.a))

        input.keyboard.handle(.escape, isPressed: true)

        #expect(input.capturing == nil)
        #expect(input.settings.keyboardKeymap == KeyboardKey.defaultKeymap)
    }

    @Test("Starting a capture lets go of everything held")
    func testCaptureReleasesHeldButtons() {
        input.keyboard.handle(KeyboardKey(.rightArrow), isPressed: true)

        input.beginCapture(.gamepad(.start))

        #expect(controllers.buttons(for: .one) == [])
    }

    @Test("Cancelling a capture returns keys to the game")
    func testCancelCapture() {
        input.beginCapture(.keyboard(.b))
        input.cancelCapture()

        input.keyboard.handle(KeyboardKey(.keyZ), isPressed: true)

        #expect(controllers.buttons(for: .one) == .b)
    }

    // MARK: - Settings

    @Test("Changing a setting releases held buttons so none get stuck")
    func testSettingsChangeReleases() {
        input.keyboard.handle(KeyboardKey(.keyX), isPressed: true)

        // Rebind A while X is still held: X's release would now be for B
        input.settings.keyboardKeymap.bind(KeyboardKey(.keyX), to: .b)
        #expect(controllers.buttons(for: .one) == [])

        input.keyboard.handle(KeyboardKey(.keyX), isPressed: false)
        #expect(controllers.buttons(for: .one) == [])
    }

    @Test("The suppression setting reaches the input state")
    func testSuppressionSettingApplies() {
        input.settings.suppressesOpposingDirections = false

        input.keyboard.handle(KeyboardKey(.leftArrow), isPressed: true)
        input.keyboard.handle(KeyboardKey(.rightArrow), isPressed: true)

        #expect(controllers.buttons(for: .one) == [.left, .right])
    }
}
