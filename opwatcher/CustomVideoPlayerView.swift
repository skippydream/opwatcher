import SwiftUI
import AVKit

struct CustomVideoPlayerView: NSViewRepresentable {
    let url: URL
    var showsFullScreenToggleButton: Bool = true

    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        let player = AVPlayer(url: url)
        
        playerView.player = player
        
        // Proprietà personalizzate:
        playerView.controlsStyle = .inline
        playerView.showsFullScreenToggleButton = showsFullScreenToggleButton
        player.preventsDisplaySleepDuringVideoPlayback = true
        
        return playerView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player?.currentItem?.asset != AVAsset(url: url) {
            nsView.player = AVPlayer(url: url)
            nsView.player?.preventsDisplaySleepDuringVideoPlayback = true
        }
    }
}
