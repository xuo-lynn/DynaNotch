import Foundation
import AppKit
import SwiftUI

class SongModel: ObservableObject {
    @Published var albumArt: NSImage? {
        didSet {
            print("Album Art changed: \(String(describing: albumArt))")
        }
    }
    @Published var title: String? {
        didSet {
            print("Title changed: \(String(describing: title))")
        }
    }
    @Published var artist: String? {
        didSet {
            print("Artist changed: \(String(describing: artist))")
        }
    }
    @Published var duration: TimeInterval? {
        didSet {
            print("Duration changed: \(String(describing: duration))")
        }
    }

    private let nowPlayingController = SongController()
    private var updateTimer: Timer?

    init() {
        updateNowPlayingInfo()
    }

    func updateNowPlayingInfo() {
        nowPlayingController?.fetchNowPlayingInfo { [weak self] nowPlayingInfo in
            DispatchQueue.main.async {
                self?.title = nowPlayingInfo.songTitle
                self?.artist = nowPlayingInfo.artistName
                self?.albumArt = nowPlayingInfo.albumArt
                self?.duration = nowPlayingInfo.songDuration
            }
        }
    }
}
