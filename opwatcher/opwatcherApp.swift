//
//  opwatcherApp.swift
//  opwatcher
//
//  Created by Michele Lana on 01/02/25.
//

import SwiftUI

struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
    func updateNSView(_ nsView: NSView, context: Context) {}
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

@main struct MyApp: App {
    
    @State var episode: Int = 0
    @State var isFirstEpisode = true
    @State var playbackPosition: Double = 0.0
    @State var releaseButtons = false
    //@State private var selectedUsername: String = UserDefaults.standard.string(forKey: "selectedUsername") ?? "none"
    @State private var selectedUsername: String = "none"

    @State var fillerEpisodes: [Int] = [
        54, 55, 56, 57, 58, 59, 60, 98, 99, 102, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140,
        141, 142, 143, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 220, 221, 222, 223,
        224, 225, 279, 280, 281, 282, 283, 291, 292, 303, 317, 318, 319, 326, 327, 328, 329, 330,
        331, 332, 333, 334, 335, 336, 382, 383, 384, 406, 407, 426, 427, 428, 429, 457, 458, 492,
        542, 575, 576, 577, 578, 590, 626, 627, 747, 748, 749, 750, 780, 781, 782, 895, 896, 907,
        1029, 1030, 1123,
    ]
    @State var mixedFillerEpisodes: [Int] = [
        45, 46, 47, 61, 68, 69, 101, 226, 354, 421, 489, 520, 574, 625, 628, 633, 653, 657, 679,
        690, 731, 738, 751, 777, 778, 789, 803, 807, 878, 879, 881, 882, 883, 884, 885, 887, 888,
        889, 890, 924, 988, 989, 991,
    ]
    struct WatchedEpisode: Codable {
        var episode: Int
        var playbackPosition: Double
        var username: String
        var timestamp: String
    }
    
    
    private func loadLastWatchedEpisode() {
        // Usa l'username selezionato per caricare i dati dell'utente
        guard !selectedUsername.isEmpty && selectedUsername != "none" else {
            print("Nome utente non selezionato.")
            return
        }
        
        guard let url = URL(string: "https://selfless-comfort-production.up.railway.app/api/lastWatchedEpisode/\(selectedUsername)") else {
            print("Errore URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Metodo GET per ottenere i dati
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Errore nella richiesta GET: \(error)")
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let savedEpisode = try decoder.decode(WatchedEpisode.self, from: data)
                    DispatchQueue.main.async {
                        self.episode = savedEpisode.episode
                        self.playbackPosition = savedEpisode.playbackPosition
                        // Gestisci anche username e timestamp se necessario
                        print("Caricato episodio \(self.episode), posizione \(self.playbackPosition), utente \(savedEpisode.username), timestamp \(savedEpisode.timestamp)")
                    }
                } catch {
                    print("Errore nella decodifica dei dati: \(error)")
                }
            }
        }

        task.resume()
    }


    
    
    func saveLastWatchedEpisode() {
        // Verifica che `selectedUsername` non sia "none"
        guard !selectedUsername.isEmpty && selectedUsername != "none" else {
            print("Nessun nome utente selezionato")
            return
        }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())

        // Crea l'oggetto WatchedEpisode includendo l'username
        let watchedEpisode = WatchedEpisode(episode: episode, playbackPosition: playbackPosition, username: selectedUsername, timestamp: timestamp)
        let encoder = JSONEncoder()

        do {
            let encoded = try encoder.encode(watchedEpisode)

            // Usa l'endpoint che permette di salvare i dati per un utente specifico
            guard let url = URL(string: "https://selfless-comfort-production.up.railway.app/api/lastWatchedEpisode") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = encoded

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Errore nella richiesta POST: \(error)")
                    return
                }

                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("Episodio salvato: \(episode), posizione salvata: \(playbackPosition), utente \(selectedUsername), timestamp \(timestamp)")
                } else {
                    print("Errore nel salvataggio dei dati.")
                }
            }

            task.resume()
        } catch {
            print("Errore nella codifica dei dati: \(error)")
        }
    }

    
    var body: some Scene {
        WindowGroup {
            if selectedUsername != "none" {
                ZStack {
                    ContentView(
                        episode: $episode, playbackPosition: $playbackPosition,
                        fillerEpisodes: $fillerEpisodes,
                        isFirstEpisode: $isFirstEpisode, mixedFillerEpisodes: $mixedFillerEpisodes,                     selectedUsername: $selectedUsername, loadLastWatchedEpisode: loadLastWatchedEpisode, saveLastWatchedEpisode: saveLastWatchedEpisode
                    ).background(VisualEffect().ignoresSafeArea())
                }.onAppear {
                    loadLastWatchedEpisode()
                }.onDisappear {
                    saveLastWatchedEpisode()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NSApp.terminate(nil)  // Chiudi l'app quando la finestra viene chiusa
                    }
                }.frame(minWidth: 800, maxWidth:800, minHeight: 500, maxHeight: 500)

        
            }
            
            else  {
                UserSelectionView(selectedUsername: $selectedUsername)
            }
            

        }
        .windowStyle(.hiddenTitleBar)
        .addWindowResizabilityIfAvailable()
    }
}
