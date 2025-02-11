import SwiftUI
import SwiftNES

struct ContentView: View {
    let emulator = NES()
    
    var body: some View {
        Spacer()
            .onAppear {
                // TODO: - Do NES stuff
            }
    }
}

#Preview {
    ContentView()
}
