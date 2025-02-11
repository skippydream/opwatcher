//
//  opwatcherApp.swift
//  opwatcher
//
//  Created by Michele Lana on 01/02/25.
//

import SwiftUI

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
    
}

extension Scene {
    func addWindowResizabilityIfAvailable() -> some Scene {
        if #available(macOS 13, *) {
            return self.windowResizability(.contentSize)
        } else {
            return self
        }
    }
}

@main
struct MyApp: App {

    @State var episode: Int = 0
    @State var fillerEpisodes: [Int] = [
        54, 55, 56, 57, 58, 59, 60, 98, 99, 102, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 220, 221, 222, 223, 224, 225, 279, 280, 281, 282, 283, 291, 292, 303, 317, 318, 319, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 382, 383, 384, 406, 407, 426, 427, 428, 429, 457, 458, 492, 542, 575, 576, 577, 578, 590, 626, 627, 747, 748, 749, 750, 780, 781, 782, 895, 896, 907, 1029, 1030, 1123
        ]
    
    @State var mixedFillerEpisodes: [Int] = [
        45, 46, 47, 61, 68, 69, 101, 226, 354, 421, 489, 520, 574, 625, 628, 633, 653, 657, 679, 690, 731, 738, 751, 777, 778, 789, 803, 807, 878, 879, 881, 882, 883, 884, 885, 887, 888, 889, 890, 924, 988, 989, 991
    ]
    
    private func loadLastWatchedEpisode() {
        if let savedEpisode = UserDefaults.standard.value(forKey: "lastWatchedEpisode") as? Int {
            episode = savedEpisode
        }
    }
    // Funzione per salvare l'episodio corrente in UserDefaults
    private func saveLastWatchedEpisode() {
        UserDefaults.standard.set(episode, forKey: "lastWatchedEpisode")
    }
    
    @State private var lastWatchedEpisode: Int = {
            // Carica l'episodio salvato da UserDefaults (se presente)
            if let savedEpisode = UserDefaults.standard.value(forKey: "lastWatchedEpisode") as? Int {
                return savedEpisode
            }
            return 0 // Restituisci 0 se non c'è un episodio salvato
        }()

    var body: some Scene {
        
        WindowGroup {
                ZStack{
                    ContentView(episode: $episode, fillerEpisodes: $fillerEpisodes, mixedFillerEpisodes: $mixedFillerEpisodes, lastWatchedEpisode: $lastWatchedEpisode, loadLastWatchedEpisode: loadLastWatchedEpisode, saveLastWatchedEpisode: saveLastWatchedEpisode)
                        .background(VisualEffect().ignoresSafeArea());
                    
                }
                .onAppear {
                                   loadLastWatchedEpisode()
                               }
                .onDisappear {
                                NSApp.terminate(nil) // Chiudi l'app quando la finestra viene chiusa
                            }
               .frame(minWidth: 800,
                       maxWidth: 800,
                      minHeight: 550,
                      maxHeight: 550)

        }
        .addWindowResizabilityIfAvailable()
        
    }
    // Funzione per caricare l'ultimo episodio guardato da UserDefaults
}


