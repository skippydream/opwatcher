import SwiftUI

struct UserSelectionView: View {
    @Binding var selectedUsername: String
    @ObservedObject var episodeService = EpisodeService()
    @State private var selectedEpisode: Episode? = nil // Episodio selezionato
    
    // Funzione per formattare il timestamp
    func formatTimestamp(_ timestamp: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: timestamp) {
            let readableFormatter = DateFormatter()
            readableFormatter.dateStyle = .medium
            readableFormatter.timeStyle = .short
            return readableFormatter.string(from: date)
        }
        return timestamp // Se la data non è valida, restituisci il timestamp originale
    }
    // Funzione per convertire i secondi in minuti e secondi
      func formatPlaybackPosition(_ seconds: Int) -> String {
          let minutes = seconds / 60
          let remainingSeconds = seconds % 60
          return "\(minutes) min \(remainingSeconds) sec"
      }
    
    var body: some View {
        VStack {
            List(episodeService.episodes) { episode in
                VStack(alignment: .leading) {
                    Text("Username: \(episode.username)")
                        .font(.headline)
                                                .foregroundColor(.primary)
                    Text("Episodio: \(episode.episode)")
                        .font(.subheadline)
                                                .foregroundColor(.secondary)
                    Text("Posizione di riproduzione: \(formatPlaybackPosition(Int(episode.playbackPosition)))")
                        .font(.subheadline)
                                                .foregroundColor(.secondary)
                    Text("Ultimo salvataggio: \(formatTimestamp(episode.timestamp))") // Usa il formato leggibile
                        .font(.subheadline)
                                                .foregroundColor(.secondary)
                }
                .padding()                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .padding(.horizontal)
                                .padding(.vertical, 5)            }
            .onAppear {
                episodeService.fetchEpisodes() // Carica i dati quando la vista appare
            }
            
            VStack {
                Text("Seleziona un utente")
                    .font(.largeTitle)
                    .padding()
                
                HStack {
                    Button(action: {
                        selectedUsername = "ludo"
                        UserDefaults.standard.set("ludo", forKey: "selectedUsername")
                        
                        // Trova l'episodio associato a Ludo
                        if let ludoEpisode = episodeService.episodes.first(where: { $0.username == "ludo" }) {
                            selectedEpisode = ludoEpisode
                        }
                    }) {
                        Text("Lu")
                            .font(.system(size: 40))
                            .opacity(0.7)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .clipShape(Circle()) // Rende il bottone circolare
                    }
                    .padding()
                    .buttonStyle(.borderless)
                    Button(action: {
                        selectedUsername = "mic"
                        UserDefaults.standard.set("mic", forKey: "selectedUsername")
                        
                        // Trova l'episodio associato a Mic
                        if let micEpisode = episodeService.episodes.first(where: { $0.username == "mic" }) {
                            selectedEpisode = micEpisode
                        }
                    }) {
                        Text("Mic")
                            .font(.system(size: 40))
                            .opacity(0.7)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle()) // Rende il bottone circolare
                    }
                    .padding()
                    .buttonStyle(.borderless)
                    
                    
                    
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .edgesIgnoringSafeArea(.all)
        }
        .frame(minWidth: 800, maxWidth:800, minHeight: 500, maxHeight: 500)
    }
}
