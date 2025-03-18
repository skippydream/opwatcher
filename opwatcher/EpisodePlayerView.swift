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
                .onDisappear { savePlaybackPosition() }
                .padding(.horizontal, 20).offset(y: 12)

                //Play/Pause
        if !settings {
            Button(action: togglePlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .font(.system(size: 200))
            .opacity(0.6)

        }
            
    }
    
    func savePlaybackPosition() {
        let currentTime = player?.currentTime()
        playbackPosition = currentTime!.seconds
        UserDefaults.standard.set(playbackPosition, forKey: "playbackPosition")
    }
    
        func setupPlayer() {
        isPlaying = false
        player?.pause()
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player!.preventsDisplaySleepDuringVideoPlayback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                if isFirstEpisode {
                    let time = CMTime(seconds: playbackPosition, preferredTimescale: 1)
                    player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
                    print("posizione - Ho seekkato")
                    isFirstEpisode = false
                }
                player?.addPeriodicTimeObserver(
                    forInterval: CMTime(seconds: 5, preferredTimescale: 1), queue: .main
                ) { time in
                    self.playbackPosition = time.seconds  // usa self direttamente
                    print("posizione - ho aggiornato")
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
