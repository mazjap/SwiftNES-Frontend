# SwiftNES

A modern SwiftUI-based frontend for [SwiftNES Core](https://github.com/mazjap/SwiftNES) - a Nintendo Entertainment System (NES) emulator written in Swift. This project handles the user interface, graphics rendering, and audio output, while interfacing with the core emulation logic provided by the backend.

## Overview

This frontend will provide:

- A native SwiftUI interface for macOS, iOS, & visionOS (perhaps tvOS & watchOS as well)
- Metal-based rendering for efficient graphics display
- Audio output using AVAudioEngine
- Input handling for keyboard, touch, and game controllers
- ROM loading and management

The project aims to create a responsive, user-friendly interface while maintaining accurate emulation through the SwiftNES Core.

## Project Status

The frontend is in early development, awaiting completion of core components in the backend. Currently, you can:

- Run a built-in Snake game demo (demonstrates CPU emulation)
- Experience the basic UI framework

### Roadmap

The following features are under development:

#### Graphics

- [ ] Metal-based rendering pipeline
- [ ] SwiftUI integration via MTKView wrapper
- [ ] Shader development for NES color palette
- [ ] Frame timing synchronization

_Blocked by PPU completion in core_

#### Audio

- [ ] AVAudioEngine integration
- [ ] NES audio signal processing
- [ ] Sample rate conversion
- [ ] Buffer management

_Blocked by APU completion in core_

#### Input

- [ ] Complete input system
- [ ] Keyboard mapping
- [ ] Touch controls for iOS
- [ ] Game controller support
- [ ] Input configuration UI

#### UI/UX

- [ ] ROM library management
- [ ] Emulation state saving/loading
- [ ] Configuration interface
- [ ] Debug visualization tools

See [the backend repository](https://github.com/mazjap/SwiftNES) for more details on what's still needed.

## Getting Started

### Requirements

- Platform Version (subject to change): macOS 11.0+ | iOS 14.0+ | visionOS 1.0+ 
- Xcode Version: 15.0+
- Swift Version: 6.0+

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/mazjap/SwiftNES-Frontend.git
   cd SwiftNES-Frontend
   ```

2. **Open in Xcode:**

   ```bash
   xed .
   ```

3. **Configure settings:**
   - Open project settings
   - Select your development team
   - Adjust bundle identifier if needed
   - Select run destination


6. **Build & run (`⌘R`):**

## Development Setup

The project uses Swift Package Manager for dependency management. The main dependencies are:

- SwiftNES Core (backend emulator)
- Metal frameworks for graphics
- AVFoundation for audio

## Contributing

While this project is primarily for educational purposes and not accepting direct contributions, feedback and suggestions are welcome via:

- Opening issues
- Suggesting improvements
- Reporting bugs

## License

This project is released under the MIT License. See the [LICENSE file](./LICENSE) for more information. Attribution, while not required, is appreciated.

## Acknowledgments

- [SwiftNES Core](https://github.com/mazjap/SwiftNES) - The backend emulation engine
- [Metal-Swift](https://developer.apple.com/metal/) - Graphics rendering
- [NESDev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki) - NES hardware documentation
- [Apple Game Controller](https://developer.apple.com/documentation/gamecontroller) - Input handling documentation
