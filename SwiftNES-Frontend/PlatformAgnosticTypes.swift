import SwiftUI

#if os(macOS)
typealias NativeColor = NSColor
typealias NativeImage = NSImage

extension NSImage {
    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
}
#else
typealias NativeColor = UIColor
typealias NativeImage = UIImage
#endif

extension Color {
    init(nativeColor: NativeColor) {
        #if os(macOS)
        self.init(nsColor: nativeColor)
        #else
        self.init(uiColor: nativeColor)
        #endif
    }
}

extension Image {
    init(nativeImage: NativeImage) {
        #if canImport(AppKit)
        self.init(nsImage: nativeImage)
        #else
        self.init(uiImage: nativeImage)
        #endif
    }
}
