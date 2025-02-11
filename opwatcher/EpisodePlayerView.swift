//
//  EpisodePlayerView.swift
//  One Piece Watcher
//
//  Created by Michele Lana on 03/02/25.
//

import SwiftUI
import AVKit


struct EpisodePlayerView: View {
    @Binding var episode: Int // Legge l'episodio selezionato dall'utente
    @State private var player: AVPlayer?
    @Binding var isFullscreen: Bool
    @State private var isButtonsVisible = false
    @Binding var fillerEpisodes : [Int]
    @Binding var mixedFillerEpisodes : [Int]
    @State var lastWatchedEpisode : Int
    @Binding var showPlayer : Bool
    @Binding var commands : Bool

    var saveLastWatchedEpisode: () -> Void

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
        default:
            baseURL = "https://srv37.nezumi.streampeaker.org/DDL/ANIME/OnePiece/"
        }
        let episodeString = String(format: "%04d", episode)
        return URL(string: "\(baseURL)\(episodeString)/playlist.m3u8")!
    }

    
    var body: some View {
        ZStack {
            AVPlayerViewRepresentable(player: player ?? AVPlayer(),
                                      showsFullScreenToggleButton: true)
                .onAppear { setupPlayer()
                }
                .onChange(of: episode) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        setupPlayer()
                        saveLastWatchedEpisode()  
                    }
                }
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 30)

    }
    
    private func setupPlayer() {
        player?.pause()
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player!.preventsDisplaySleepDuringVideoPlayback = true
    }
}
