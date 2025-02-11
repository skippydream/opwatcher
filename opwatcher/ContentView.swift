import SwiftUI
import AVKit

struct ContentView: View {
    @Binding var episode: Int
    @State var showPlayer = true
    @State var commands = true
    @State var inputEpisode: String = "" // Episodio inserito dall'utente
    @State var isFullscreen = false
    @Binding var fillerEpisodes : [Int]
    @Binding var mixedFillerEpisodes : [Int]
    @Binding var lastWatchedEpisode : Int
    @State private var fillerAlert = false  // Variabile per mostrare l'alert
    @State private var mixedFillerAlert = false  // Variabile per mostrare l'alert
    @State private var errorMessage: String?  // Aggiungi una variabile per il messaggio di errore
    @State private var mixedFillerAlertMessage: String = "" // Variabile per il messaggio dell'alert
    @State private var searchExpand = false
    @FocusState private var isInputFocused: Bool
    
    var loadLastWatchedEpisode: () -> Void // Funzione di callback per caricare l'episodio
    var saveLastWatchedEpisode: () -> Void
    
    var body: some View {
            VStack {
                if showPlayer {
                    ZStack {
                        EpisodePlayerView(episode: $episode,
                                          isFullscreen: $isFullscreen,
                                          fillerEpisodes: $fillerEpisodes,
                                          mixedFillerEpisodes: $mixedFillerEpisodes,
                                          lastWatchedEpisode: lastWatchedEpisode,
                                          showPlayer: $showPlayer,
                                          commands: $commands,
                                          saveLastWatchedEpisode: saveLastWatchedEpisode)
                        
                    }
                    .background(Color.black)
                    
                    if searchExpand {

                        TextField("Cerca un episodio (es. 37)", text: $inputEpisode)
                        
                            .focused($isInputFocused)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 15))
                            .background(RoundedRectangle(cornerRadius: 100)
                                .strokeBorder(Color.gray, lineWidth: 0.5))
                            .font(.system(size: 24, weight: .ultraLight))
                            .frame(maxWidth: .infinity)
                            .onSubmit {
                                if let episodeInt = Int(inputEpisode) {
                                    if fillerEpisodes.contains(episodeInt) {
                                        fillerAlert = true
                                    }
                                    else if mixedFillerEpisodes.contains(episodeInt) {
                                        mixedFillerAlert = true
                                    }
                                    else {
                                        // Se l'episodio non è filler o mixed filler, procedi con il video
                                        episode = episodeInt
                                        showPlayer = true
                                    }
                                }
                                else {
                                    // Se ci sono episodi filler tra i successivi, mostra l'avviso
                                    mixedFillerAlert = true  // Mostra l'alert
                                }
                            }
                            .alert("L'episodio \(inputEpisode) è Filler", isPresented: $fillerAlert) {
                                Button("OK", role: .cancel) { }
                            }
                            .alert(isPresented: $mixedFillerAlert) {
                                Alert(
                                    title: Text("Episodio mixed Canon/Filler"),  // Titolo dell'alert
                                    message: Text("Vuoi guardarlo lo stesso?"),
                                    primaryButton: .default(Text("Procedi")) {
                                        // Quando l'utente preme "Procedi", esegui le stesse azioni
                                        episode = Int(inputEpisode) ?? episode
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showPlayer = true
                                        }
                                    },
                                    secondaryButton: .cancel {                           }
                                )
                            }
                            .padding(.horizontal, 80)
                            .padding(.top, 10)
                            .onAppear {
                                // Quando il TextField appare, imposta il focus su di esso
                                isInputFocused = true
                            }
                            .onChange(of: searchExpand) { value in
                                if value {
                                    isInputFocused = true  // Imposta il focus quando si espande
                                } else {
                                    isInputFocused = false  // Rimuovi il focus quando si nasconde
                                }

                            }

                    }


                }
                
                if commands {
                   
                                        
                    HStack {
                        // precedente episodio
                        Button(action: {
                            episode -= 1
                        }) {
                            Image(systemName: "arrow.backward.circle.fill") // Icona per "indietro"
                        }
                        .buttonStyle(.borderless)
                        .font(.system(size: 65)) // Impostiamo la dimensione dell'icona
                        .padding(.horizontal, 30)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
      //                  Divider()
       //                     .frame(height: 60)
                        
                        // Carica l'ultimo episodio
      //                  Button(action: {
      //                     episode = lastWatchedEpisode
                        //                      showPlayer = true
                        //                  }) {
                        //                       Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        //                       VStack {
                        //                           Text("Ep. salvato:")
                        //                              .font(.caption)
                        //                          Text("\(lastWatchedEpisode)")
                        //                              .font(.system(size: 30)) // Impostiamo la dimensione dell'icona
                        //                             .foregroundColor(
                        //                         mixedFillerEpisodes.contains(lastWatchedEpisode) ? Color.orange :
                        //                               fillerEpisodes.contains(lastWatchedEpisode) ? Color.red :
                        //                                 Color.gray // Colore di default (bianco)
                        //                        )
                        //                  }
                    //
                        //                }
                    //                .buttonStyle(.borderless)
                        //                .disabled(true)
                        //                .font(.system(size: 50)) // Impostiamo la dimensione dell'icona
                        //                .padding()
                        //                .opacity(0.8)

                        
      //                  Divider()
      //                      .frame(height: 40)
      //                  Button(action: {
      //                      saveLastWatchedEpisode()
      //                      lastWatchedEpisode = episode
      //                  }) {
       //                     Image(systemName: "square.and.arrow.down")
       //                 }
       //                 .buttonStyle(.borderless)
      //                  .padding(.bottom, 5)
      //                  .font(.system(size: 60)) // Impostiamo la dimensione dell'icona
     //                   .padding()
         //               Divider()
         //                   .frame(height: 30)
                        
                        
                        //Cerca
                        Button(action: {
                            searchExpand.toggle() // Carica l'ultimo episodio
                        }) {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .opacity(0.4)

                        }
                        .buttonStyle(.borderless)
                        .font(.system(size: 50)) // Impostiamo la dimensione dell'icona
                        .padding()

                        Divider()
                            .frame(height: 30)
                        
                        //TextField
                        Button(action: {
                            
                        }) {
                            Image(systemName: "film.fill")
                                .font(.system(size: 55))
                            VStack {
                                Text("Ep. attuale:")
                                    .font(.caption)
                                Text("\(episode)")
                                    .font(.system(size: 30))
                                    .foregroundColor(
                                        mixedFillerEpisodes.contains(episode) ? Color.orange :
                                            fillerEpisodes.contains(episode) ? Color.red :
                                            Color.gray // Colore di default (bianco)
                                    )
                            }

                        }
                        .buttonStyle(.borderless)
                        .disabled(true)
                        .font(.system(size: 50)) // Impostiamo la dimensione dell'icona
                        .padding()
                        .opacity(0.8)

                        
             //           Divider()
              //              .frame(height: 60)
                        // prossimo episodio
                        Button(action: {
                            episode += 1
                        }) {
                            Image(systemName: "arrow.forward.circle.fill") // Icona per "indietro"
                              
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        .buttonStyle(.borderless)
                        .font(.system(size: 65)) // Impostiamo la dimensione dell'icona
                        .padding()
                        .padding(.horizontal, 30)


                    }
                    .offset(y: -5)
                    
                }
                
                
            }
        
    }


}
