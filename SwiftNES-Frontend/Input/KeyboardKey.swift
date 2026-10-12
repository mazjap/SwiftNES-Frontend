import GameController

/// A key on a hardware keyboard, stored as its HID usage code so keymaps can be saved.
struct KeyboardKey: Hashable, Comparable, Codable, Sendable {
    let rawValue: Int

    init(_ code: GCKeyCode) {
        rawValue = code.rawValue
    }

    static let escape = KeyboardKey(.escape)

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var name: String {
        Self.names[rawValue] ?? "Key \(rawValue)"
    }

    static let defaultKeymap = Keymap<KeyboardKey>([
        KeyboardKey(.upArrow): .up,
        KeyboardKey(.downArrow): .down,
        KeyboardKey(.leftArrow): .left,
        KeyboardKey(.rightArrow): .right,
        KeyboardKey(.keyX): .a,
        KeyboardKey(.keyZ): .b,
        KeyboardKey(.returnOrEnter): .start,
        KeyboardKey(.rightShift): .select
    ])

    private static let names: [Int: String] = {
        var names: [Int: String] = [:]

        // Letters, digits, and F-keys are contiguous runs of HID usage codes
        for (offset, letter) in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".enumerated() {
            names[GCKeyCode.keyA.rawValue + offset] = String(letter)
        }
        for (offset, digit) in "1234567890".enumerated() {
            names[GCKeyCode.one.rawValue + offset] = String(digit)
        }
        for number in 1...12 {
            names[GCKeyCode.F1.rawValue + number - 1] = "F\(number)"
        }

        let named: [GCKeyCode: String] = [
            .returnOrEnter: "Return",
            .escape: "Escape",
            .deleteOrBackspace: "Delete",
            .tab: "Tab",
            .spacebar: "Space",
            .capsLock: "Caps Lock",
            .hyphen: "-",
            .equalSign: "=",
            .openBracket: "[",
            .closeBracket: "]",
            .backslash: "\\",
            .semicolon: ";",
            .quote: "'",
            .graveAccentAndTilde: "`",
            .comma: ",",
            .period: ".",
            .slash: "/",
            .upArrow: "Up Arrow",
            .downArrow: "Down Arrow",
            .leftArrow: "Left Arrow",
            .rightArrow: "Right Arrow",
            .leftShift: "Left Shift",
            .rightShift: "Right Shift",
            .leftControl: "Left Control",
            .rightControl: "Right Control",
            .leftAlt: "Left Option",
            .rightAlt: "Right Option",
            .leftGUI: "Left Command",
            .rightGUI: "Right Command"
        ]

        for (code, name) in named {
            names[code.rawValue] = name
        }

        return names
    }()
}
