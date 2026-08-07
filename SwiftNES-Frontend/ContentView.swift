import SwiftUI
import SwiftNES

actor NESRunner {
    private let emulator = NES()
    
    func insertCartridge(_ url: URL) throws {
        try emulator.load(cartridge: .init(fileURL: url))
    }
    
    func start() throws -> AsyncThrowingStream<NES.FrameOrFinish, Error> {
        try emulator.runStream()
    }
}

@MainActor
class ViewModel: ObservableObject {
    private let runner = NESRunner()
    @Published var currentFrame: CGImage?
    
    nonisolated
    func start() async {
        do {
            guard let url = Bundle.main.url(forResource: "donkey_kong", withExtension: "nes") else {
                print("bad")
                throw NSError()
            }
            
            try await runner.insertCartridge(url)
            
            for try await result in try await runner.start() {
                switch result {
                case let .frame(newFrame):
                    let space = CGColorSpaceCreateDeviceRGB()
                    // `toARGB()` hands back 0xAARRGGBB *as a UInt32*, which on a
                    // little-endian machine sits in memory as [BB, GG, RR, AA].
                    // byteOrder32Little tells CoreGraphics to read each pixel as a
                    // little-endian word rather than as bytes in A,R,G,B order —
                    // without it, alpha comes from blue and red/green are swapped.
                    let info = CGBitmapInfo(
                        rawValue: CGBitmapInfo.byteOrder32Little.rawValue
                            | CGImageAlphaInfo.noneSkipFirst.rawValue
                    )
                    let imagePixels = newFrame.toARGB()
                    let bytesPerPixel = MemoryLayout<UInt32>.size
                    let pixelData = imagePixels.withUnsafeBufferPointer {
                        Data(buffer: $0)
                    }
                    guard let provider = CGDataProvider(data: pixelData as CFData) else {
                        print("bad image stuff!")
                        return
                    }
                    let image = CGImage(
                        width: NES.PPU.Frame.width,
                        height: NES.PPU.Frame.height,
                        bitsPerComponent: 8,
                        bitsPerPixel: 32,
                        bytesPerRow: NES.PPU.Frame.width * bytesPerPixel,
                        space: space,
                        bitmapInfo: info,
                        provider: provider,
                        decode: nil,
                        shouldInterpolate: true,
                        intent: .defaultIntent
                    )
                    
                    await MainActor.run {
                        self.currentFrame = image
                    }
                case let .finish(reason):
                    print("end??? \(reason)")
                }
            }
        } catch {
            print("Hit an error :/ \(error)")
        }
    }
}

@available(macOS 12.0, *)
struct ContentView: View {
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        Group {
            if let image = vm.currentFrame {
                Image(nsImage: NSImage(cgImage: image, size: NSSize(width: NES.PPU.Frame.width, height: NES.PPU.Frame.height)))
            } else {
                Text("No frame :/")
                    .font(.largeTitle)
            }
        }
        .aspectRatio(Double(NES.PPU.Frame.width) / Double(NES.PPU.Frame.height), contentMode: .fit)
        .task {
            await vm.start()
        }
    }
}

@available(macOS 12.0, *)
#Preview {
    ContentView()
}
