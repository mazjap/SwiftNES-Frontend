import SwiftNES
import Testing
@testable import SwiftNES_Frontend

@MainActor
@Suite("Input State")
struct InputStateTests {
    let controllers = NES.Controller.Inputs()
    let state: InputState

    init() {
        state = InputState(controllers: controllers)
    }

    @Test("One source releasing a button doesn't release it for another")
    func testSourcesDontFight() {
        state.press(.a, for: .one, from: .keyboard)
        state.press(.a, for: .one, from: .gamepad(.one))
        state.release(.a, for: .one, from: .gamepad(.one))

        #expect(controllers.buttons(for: .one) == .a, "Keyboard is still holding A")

        state.release(.a, for: .one, from: .keyboard)
        #expect(controllers.buttons(for: .one) == [])
    }

    @Test("Sources are merged per player")
    func testMergesPerPlayer() {
        state.press(.left, for: .one, from: .keyboard)
        state.press(.b, for: .one, from: .touch)
        state.setHeld([.start, .up], for: .two, from: .gamepad(.two))

        #expect(controllers.buttons(for: .one) == [.left, .b])
        #expect(controllers.buttons(for: .two) == [.start, .up])
    }

    @Test("Set held replaces only that source's buttons")
    func testSetHeld() {
        state.press(.a, for: .one, from: .keyboard)
        state.setHeld([.b, .right], for: .one, from: .gamepad(.one))
        state.setHeld(.select, for: .one, from: .gamepad(.one))

        #expect(state.buttons(for: .one, from: .gamepad(.one)) == .select)
        #expect(controllers.buttons(for: .one) == [.a, .select])
    }

    @Test("Releasing one source leaves the others")
    func testReleaseAllFromSource() {
        state.press(.a, for: .one, from: .keyboard)
        state.press(.b, for: .one, from: .touch)

        state.releaseAll(from: .touch)

        #expect(controllers.buttons(for: .one) == .a)
    }

    @Test("Release all clears every source and player")
    func testReleaseAll() {
        state.press(.a, for: .one, from: .keyboard)
        state.setHeld(.b, for: .two, from: .gamepad(.two))

        state.releaseAll()

        #expect(controllers.buttons(for: .one) == [])
        #expect(controllers.buttons(for: .two) == [])
    }

    // MARK: - Opposing directions

    @Test("Opposing directions cancel out when suppression is on")
    func testSuppressesOpposingDirections() {
        state.press([.up, .down, .left, .a], for: .one, from: .keyboard)

        #expect(controllers.buttons(for: .one) == [.left, .a])
    }

    @Test("Opposing directions from different sources also cancel out")
    func testSuppressesAcrossSources() {
        state.press(.left, for: .one, from: .keyboard)
        state.press(.right, for: .one, from: .touch)

        #expect(controllers.buttons(for: .one) == [])
    }

    @Test("Opposing directions pass through when suppression is off")
    func testAllowsOpposingDirections() {
        state.suppressesOpposingDirections = false
        state.press([.up, .down], for: .one, from: .keyboard)

        #expect(controllers.buttons(for: .one) == [.up, .down])
    }

    @Test("Toggling suppression updates the emulator immediately")
    func testTogglingSuppressionRepublishes() {
        state.press([.left, .right], for: .one, from: .keyboard)
        #expect(controllers.buttons(for: .one) == [])

        state.suppressesOpposingDirections = false
        #expect(controllers.buttons(for: .one) == [.left, .right])
    }
}
