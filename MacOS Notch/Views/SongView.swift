import SwiftUI
import AppKit

struct SongView: View {
    @StateObject var songModel: SongModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.5)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                VStack {
                    if let title = songModel.title {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                    } else {
                        Text("Unknown Title")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    if let artist = songModel.artist {
                        Text(artist)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    } else {
                        Text("Unknown Artist")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text(formatTime(songModel.elapsedTime))
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        ProgressView(value: songModel.elapsedTime, total: songModel.duration ?? 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.white)
                            .frame(width: geometry.size.width * 0.5)
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                        
                        Text(formatTime(songModel.duration))
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: {
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 20)
                }
                
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval?) -> String {
        guard let time = time else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    SongView(songModel: SongModel())
}
