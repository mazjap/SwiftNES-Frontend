import CoreGraphics
import SwiftNES
import Testing
@testable import SwiftNES_Frontend

@MainActor
@Suite("D-pad")
struct DPadTests {
    typealias Button = NES.Controller.Button

    static let size = 150.0

    /// A point `distance` from the center, at `degrees` counterclockwise from right.
    static func point(atDegrees degrees: Double, distance: Double = 60) -> CGPoint {
        let radians = degrees * .pi / 180
        return CGPoint(x: size / 2 + cos(radians) * distance, y: size / 2 - sin(radians) * distance)
    }

    nonisolated static let sectors: [(degrees: Double, direction: Button)] = [
        (0, .right),
        (45, [.up, .right]),
        (90, .up),
        (135, [.up, .left]),
        (180, .left),
        (225, [.down, .left]),
        (270, .down),
        (315, [.down, .right])
    ]

    @Test("Each 45° sector picks its direction", arguments: sectors)
    func testSectors(degrees: Double, expected: Button) {
        #expect(DPad.direction(at: Self.point(atDegrees: degrees), in: Self.size) == expected)
    }

    @Test("Sectors are centered on their direction")
    func testSectorEdges() {
        #expect(DPad.direction(at: Self.point(atDegrees: 22), in: Self.size) == .right)
        #expect(DPad.direction(at: Self.point(atDegrees: 23), in: Self.size) == [.up, .right])
        #expect(DPad.direction(at: Self.point(atDegrees: -22), in: Self.size) == .right)
    }

    @Test("Touches in the center press nothing")
    func testDeadZone() {
        #expect(DPad.direction(at: CGPoint(x: Self.size / 2, y: Self.size / 2), in: Self.size) == [])
        #expect(DPad.direction(at: Self.point(atDegrees: 90, distance: 10), in: Self.size) == [])
    }

    @Test("Dragging past the edge keeps its direction")
    func testOutsideBounds() {
        #expect(DPad.direction(at: CGPoint(x: -40, y: Self.size / 2), in: Self.size) == .left)
    }
}
