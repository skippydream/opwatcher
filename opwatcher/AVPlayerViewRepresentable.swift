import AVKit
import SwiftUI
import AVFoundation

struct AVPlayerViewRepresentable: NSViewRepresentable {
    var player: AVPlayer
    var showsFullScreenToggleButton: Bool
    
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .inline
        playerView.showsFullScreenToggleButton = showsFullScreenToggleButton
        return playerView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        // Controlla se il player è cambiato o se la vista deve essere aggiornata
        if nsView.player != player {
            nsView.player = player
        }
    }
}
