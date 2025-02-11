import SwiftUI
import AVKit
import Firebase

struct AVPlayerViewRepresentable: NSViewRepresentable {
    var player: AVPlayer
    @State private var currentPosition: Double = 0
    let db = Firestore.firestore()

    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .floating
        playerView.autoresizingMask = [.width, .height]

        // Start listening to player position changes
        startListeningToPlayer()

        return playerView
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player?.currentItem?.asset != player.currentItem?.asset {
            nsView.player = player
        }
    }

    // Start listening to player position changes
    func startListeningToPlayer() {
        // Monitor the current position of the player
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), queue: .main) { time in
            let position = CMTimeGetSeconds(time)
            if self.currentPosition != position {
                self.currentPosition = position
                self.syncPositionWithFirestore(position)
            }
        }
    }

    // Sync the video position with Firestore
    func syncPositionWithFirestore(_ position: Double) {
        db.collection("videosync").document("video1")  // Usa un ID unico per il documento
            .setData(["position": position], merge: true) { error in
                if let error = error {
                    print("Error updating position: \(error)")
                }
            }
    }

    // Get the position from Firestore
    func fetchPositionFromFirestore() {
        db.collection("videosync").document("video1").getDocument { snapshot, error in
            if let error = error {
                print("Error fetching position: \(error)")
                return
            }

            if let snapshot = snapshot, snapshot.exists, let position = snapshot.get("position") as? Double {
                self.currentPosition = position
                self.seekToPosition(position)
            }
        }
    }

    // Seek the player to the desired position
    func seekToPosition(_ position: Double) {
        let time = CMTime(seconds: position, preferredTimescale: 600)
        player.seek(to: time)
    }
}
