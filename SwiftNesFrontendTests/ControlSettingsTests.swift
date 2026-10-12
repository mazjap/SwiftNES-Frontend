import Foundation
import GameController
import Testing
@testable import SwiftNES_Frontend

@MainActor
@Suite("Control Settings")
struct ControlSettingsTests {
    @Test("Fresh settings use the defaults")
    func testDefaults() throws {
        let settings = ControlSettings(defaults: try .isolated())

        #expect(settings.keyboardKeymap == KeyboardKey.defaultKeymap)
        #expect(settings.gamepadKeymap == GamepadControl.defaultKeymap)
        #expect(settings.suppressesOpposingDirections)
    }

    @Test("Changes survive a relaunch")
    func testPersistence() throws {
        let defaults = try UserDefaults.isolated()

        let settings = ControlSettings(defaults: defaults)
        settings.keyboardKeymap.bind(KeyboardKey(.keyW), to: .up)
        settings.gamepadKeymap.bind(.rightTrigger, to: .a)
        settings.suppressesOpposingDirections = false

        let relaunched = ControlSettings(defaults: defaults)

        #expect(relaunched.keyboardKeymap.keys(for: .up) == [KeyboardKey(.keyW)])
        #expect(relaunched.gamepadKeymap.keys(for: .a) == [.rightTrigger])
        #expect(!relaunched.suppressesOpposingDirections)
    }

    @Test("Reset restores and saves the defaults")
    func testReset() throws {
        let defaults = try UserDefaults.isolated()

        let settings = ControlSettings(defaults: defaults)
        settings.keyboardKeymap.bind(KeyboardKey(.keyW), to: .up)
        settings.suppressesOpposingDirections = false

        settings.resetToDefaults()
        let relaunched = ControlSettings(defaults: defaults)

        #expect(relaunched.keyboardKeymap == KeyboardKey.defaultKeymap)
        #expect(relaunched.suppressesOpposingDirections)
    }

    @Test("Unreadable saved data falls back to the defaults")
    func testCorruptData() throws {
        let defaults = try UserDefaults.isolated()
        defaults.set(Data("not json".utf8), forKey: "controls.keyboardKeymap")

        let settings = ControlSettings(defaults: defaults)

        #expect(settings.keyboardKeymap == KeyboardKey.defaultKeymap)
    }
}
