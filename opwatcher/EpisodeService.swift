import Foundation
import Combine


// Modello Episode con conformità a Codable per la decodifica dei dati JSON
struct Episode: Identifiable, Codable {
    var id: String { username }
    var episode: Int
    var playbackPosition: Double // Ora è Double per gestire i valori decimali
    var username: String
    var timestamp: String
}

class EpisodeService: ObservableObject {
    @Published var episodes: [Episode] = [] // Contiene gli episodi caricati

    // Funzione per caricare gli episodi da una API
    func fetchEpisodes() {
        guard let urlMic = URL(string: "https://selfless-comfort-production.up.railway.app/api/lastWatchedEpisode/mic"),
              let urlLudo = URL(string: "https://selfless-comfort-production.up.railway.app/api/lastWatchedEpisode/ludo") else {
            return // Restituisci se non possiamo creare gli URL
        }

        // Creiamo un gruppo di operazioni per gestire più richieste simultaneamente
        let dispatchGroup = DispatchGroup()

        // Richiesta per l'utente Mic
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: urlMic) { data, response, error in
            if let error = error {
                print("Errore nella richiesta per Mic: \(error.localizedDescription)")
            } else if let data = data {
                // Stampa i dati ricevuti per Mic
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Dati ricevuti per Mic: \(jsonString)") // Stampa i dati raw per il debug
                }

                // Decodifica la risposta JSON
                do {
                    let episode = try JSONDecoder().decode(Episode.self, from: data)
                    DispatchQueue.main.async {
                        self.episodes.append(episode)
                    }
                } catch {
                    print("Errore nella decodifica per Mic: \(error.localizedDescription)")
                }
            }
            dispatchGroup.leave()
        }.resume()
        // Richiesta per l'utente Ludo
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: urlLudo) { data, response, error in
            if let error = error {
                print("Errore nella richiesta per Ludo: \(error.localizedDescription)")
            } else if let data = data {
                // Stampa i dati ricevuti per Ludo
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Dati ricevuti per Ludo: \(jsonString)") // Stampa i dati raw per il debug
                }

                // Decodifica la risposta JSON
                do {
                    let episode = try JSONDecoder().decode(Episode.self, from: data)
                    DispatchQueue.main.async {
                        self.episodes.append(episode)
                    }
                } catch {
                    print("Errore nella decodifica per Ludo: \(error.localizedDescription)")
                }
            }
            dispatchGroup.leave()
        }.resume()

        // Dopo aver completato entrambe le richieste
        dispatchGroup.notify(queue: .main) {
            print("Tutti i dati sono stati caricati.")
        }
    }
}

