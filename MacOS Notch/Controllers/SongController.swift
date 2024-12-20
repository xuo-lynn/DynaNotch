import AppKit
import Combine

struct NowPlayingInfo {
    var songTitle: String
    var artistName: String
    var albumArt: NSImage
    var songDuration: TimeInterval
}

class SongController: ObservableObject {
    @Published var songTitle: String = ""
    @Published var artistName: String = ""
    @Published var albumArt: NSImage = NSImage()
    @Published var isPlaying: Bool = false
    @Published var songDuration: TimeInterval = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var playbackRate: Double = 0

    private let mediaRemoteBundle: CFBundle
    private let MRMediaRemoteGetNowPlayingInfo: @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private let MRMediaRemoteGetNowPlayingApplicationIsPlaying: @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void

    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?

    init?() {
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")),
              let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString),
              let MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString)
        else {
            print("Failed to load MediaRemote.framework or get function pointers")
            return nil
        }

        self.mediaRemoteBundle = bundle
        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
        self.MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationIsPlayingPointer, to: (@convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void).self)
    }

    func fetchNowPlayingInfo(completion: @escaping (NowPlayingInfo) -> Void) {
        var nowPlayingInfo = NowPlayingInfo(
            songTitle: "",
            artistName: "",
            albumArt: NSImage(),
            songDuration: 0
        )
        
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.global(qos: .userInitiated)) { [weak self] information in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.songTitle = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? "Unknown Title"
                self.artistName = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? "Unknown Artist"
                self.songDuration = information["kMRMediaRemoteNowPlayingInfoDuration"] as? TimeInterval ?? 0
                self.elapsedTime = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? TimeInterval ?? 0
                self.playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double ?? 0

                if let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data,
                   let artworkImage = NSImage(data: artworkData) {
                    self.albumArt = artworkImage
                    print("Album art successfully retrieved.")
                } else {
                    print("No album art available.")
                }

                print("Title: \(self.songTitle), Artist: \(self.artistName), Duration: \(self.songDuration), Artwork: \(String(describing: information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data))")
                
                nowPlayingInfo.songTitle = self.songTitle
                nowPlayingInfo.artistName = self.artistName
                nowPlayingInfo.songDuration = self.songDuration
                nowPlayingInfo.albumArt = self.albumArt

                self.MRMediaRemoteGetNowPlayingApplicationIsPlaying(DispatchQueue.main) { [weak self] isPlaying in
                    self?.isPlaying = isPlaying
                }

                completion(nowPlayingInfo)
            }
        }
    }
}
