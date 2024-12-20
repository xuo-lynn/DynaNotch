import SwiftUI

@main
struct MacOS_NotchApp: App {
    var body: some Scene {
        WindowGroup {
            SongView(songModel: SongModel())
        }
    }
}
