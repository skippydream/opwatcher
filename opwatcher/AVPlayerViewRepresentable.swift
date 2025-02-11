import AVFoundation
import AVKit
import SwiftUI

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
          if nsView.player != player { nsView.player = player }
     }
}
