//
//  EpisodePlayerView.swift
//  One Piece Watcher
//
//  Created by Michele Lana on 03/02/25.
//

import AVKit
import SwiftUI

struct EpisodePlayerView: View {
    @Binding var episode: Int  // Legge l'episodio selezionato dall'utente
    @Binding var playbackPosition: Double
    @State private var player: AVPlayer?
    @Binding var fillerEpisodes: [Int]
    @Binding var mixedFillerEpisodes: [Int]
    @Binding var skipFiller: Bool
    @Binding var skipMixed: Bool
    @State var isPlaying = false
    @Binding var isFirstEpisode : Bool
    @Binding var settings : Bool
    @Binding var cinema: Bool

    private var videoURL: URL {
        let baseURL: String
        switch episode {
        case let ep where ep >= 1060:
            baseURL = "https://srv30.sake.streampeaker.org/DDL/ANIME/OnePiece/"
        case let ep where ep >= 951:
            baseURL = "https://srv21.kurai.streampeaker.org/DDL/ANIME/OnePiece/"
        case let ep where ep >= 801:
            baseURL = "https://srv23.shiro.streampeaker.org/DDL/ANIME/OnePiece/"
        case let ep where ep >= 401:
            baseURL = "https://srv38.fukurou.streampeaker.org/DDL/ANIME/OnePiece/"
        default: baseURL = "https://srv37.nezumi.streampeaker.org/DDL/ANIME/OnePiece/"
        }
        let episodeString = String(format: "%04d", episode)
        return URL(string: "\(baseURL)\(episodeString)/playlist.m3u8")!
    }
    
    var body: some View {
            
            AVPlayerViewRepresentable(
                player: player ?? AVPlayer(),
                showsFullScreenToggleButton: true
            ).onAppear { setupPlayer()
                
            }
            .onChange(of: episode) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    setupPlayer()
                }
                
            }
            .onDisappear {
                EpisodeStateManager.save(
                    episode: episode,
                    playbackPosition: playbackPosition,
                    skipFiller: skipFiller,
                    skipMixed: skipMixed,
                    isFirstEpisode: isFirstEpisode
                )
            }
            .padding(.horizontal, 20).offset(y: 12)
            
            //Play/Pause
            if !settings && !cinema {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .opacity(0.4)
                }
                .buttonStyle(.borderless)
                .foregroundColor(Color.white)
                .font(.system(size: 200))
                
            }
        //Cinema
        Button(action: {cinema.toggle()
            if cinema {reduceWindowHeight(to: 345)}
            else {reduceWindowHeight(to: 578)}
        }) {
            Image(systemName: cinema ? "rectangle.expand.vertical" : "rectangle.compress.vertical")
                .opacity(cinema ? 0.25 : 0.7)
        }
        .buttonStyle(.borderless)
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(20).padding(.horizontal, 5)
        .font(.system(size: 50))
            
    }
    
        func setupPlayer() {
        isPlaying = false
        player?.pause()
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player!.preventsDisplaySleepDuringVideoPlayback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // 🎯 Carica la posizione salvata per questo episodio
                let savedPosition = EpisodeStateManager.loadPlaybackPosition(for: episode)
                
                if savedPosition > 5 { // evitiamo di fare seek se la posizione è quasi 0
                    let time = CMTime(seconds: savedPosition, preferredTimescale: 1)
                    player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
                    print("Seek automatico a \(savedPosition) sec per episodio \(episode)")
                }
                
                // ⏱ Aggiorna posizione ogni 5 secondi
                player?.addPeriodicTimeObserver(
                    forInterval: CMTime(seconds: 5, preferredTimescale: 1), queue: .main
                ) { time in
                    self.playbackPosition = time.seconds
                    
                    if let duration = player?.currentItem?.duration.seconds, duration.isFinite {
                        // Se siamo negli ultimi 40 secondi
                        if duration - time.seconds <= 40 {
                            // Salva posizione 0 per il prossimo episodio
                            EpisodeStateManager.savePlaybackPosition(for: episode + 1, position: 0, duration: duration)
                            
                            // Passa automaticamente al prossimo episodio se non già fatto
                            if isPlaying {
                                player?.pause()
                                episode += 1
                                playbackPosition = 0
                                setupPlayer() // Carica subito il prossimo episodio
                                print("➡️ Passato automaticamente all'episodio \(episode)")
                            }
                        } else {
                            // Salva normalmente
                            EpisodeStateManager.savePlaybackPosition(for: episode, position: time.seconds, duration: duration)
                        }
                    }
                }
            }
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func reduceWindowHeight(to newHeight: CGFloat) {
        if let window = NSApplication.shared.windows.first {
            var frame = window.frame
            let heightDelta = frame.height - newHeight

            // Aggiusta la posizione Y per mantenere il top in posizione
            frame.origin.y += heightDelta
            frame.size.height = newHeight

            window.setFrame(frame, display: true, animate: true)
        }
    }
}

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
