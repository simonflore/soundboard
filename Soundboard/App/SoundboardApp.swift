import SwiftUI

@main
struct SoundboardApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onAppear {
                    appState.setupMIDICallbacks()
                    appState.connectLaunchpad()

                    // Force dark appearance for the neon arena aesthetic
                    if let window = NSApplication.shared.windows.first {
                        window.appearance = NSAppearance(named: .darkAqua)
                        window.backgroundColor = NSColor(red: 0.04, green: 0.04, blue: 0.07, alpha: 1.0)
                        window.titlebarAppearsTransparent = true
                    }
                }
                .preferredColorScheme(.dark)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 950, height: 700)

        Settings {
            SettingsView()
                .environment(appState)
                .preferredColorScheme(.dark)
        }
    }
}
