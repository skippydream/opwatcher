import SwiftUI
import AVKit

struct CustomVideoPlayerView: NSViewRepresentable {
    let url: URL
    var showsFullScreenToggleButton: Bool = true

    func makeNSView(context: Context) -> AVPlayerView {
        print("[Player] makeNSView: Creazione AVPlayerView")
        
        let playerView = AVPlayerView()
        let player = AVPlayer(url: url)
        playerView.player = player

        playerView.controlsStyle = .inline
        playerView.showsFullScreenToggleButton = showsFullScreenToggleButton
        player.preventsDisplaySleepDuringVideoPlayback = true

        return playerView
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        let currentAsset = nsView.player?.currentItem?.asset as? AVURLAsset
        if currentAsset?.url != url {
            print("[Player] updateNSView: Nuovo URL, aggiorno player")
            nsView.player = AVPlayer(url: url)
            nsView.player?.preventsDisplaySleepDuringVideoPlayback = true
        } else {
            print("[Player] updateNSView: URL già caricato")
        }
    }

    static func dismantleNSView(_ nsView: AVPlayerView, coordinator: ()) {
        print("[Player] dismantleNSView: rilascio player e risorse")
        nsView.player?.pause()
        nsView.player?.replaceCurrentItem(with: nil)
        nsView.player = nil
    }
}
