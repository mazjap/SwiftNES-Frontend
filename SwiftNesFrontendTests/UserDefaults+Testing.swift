import Foundation
import Testing

extension UserDefaults {
    /// A defaults domain of its own, so tests don't see each other's settings or the app's.
    static func isolated() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "SwiftNESFrontendTests.\(UUID())"))
    }
}
