
import SwiftUI
import AVKit

struct VideoPlayerItemView: View {
    let url: URL
    var isPlaying: Bool = true
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if player == nil {
                    player = AVPlayer(url: url)
                }
                if isPlaying {
                    player?.play()
                }
            }
            .onChange(of: isPlaying) { _, newValue in
                if newValue {
                    player?.play()
                } else {
                    player?.pause()
                }
            }
            .onDisappear {
                player?.pause()
            }
    }
}
