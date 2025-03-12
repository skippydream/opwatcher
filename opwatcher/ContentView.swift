import AVKit
import SwiftUI

struct ContentView: View {
    @Binding var episode: Int
    @Binding var playbackPosition: Double
    @State var inputEpisode: String = ""
    @Binding var fillerEpisodes: [Int]
    @Binding var isFirstEpisode : Bool
    @Binding var mixedFillerEpisodes: [Int]
    @State private var errorMessage: String?
    @State private var searchExpand = false
    @State var settings = false
    @State private var showPlayer = true
    @State var buttonsReady = false
    @State var skipFiller: Bool = UserDefaults.standard.bool(forKey: "skipFiller")
    @State var skipMixed: Bool = UserDefaults.standard.bool(forKey: "skipMixed")
    @FocusState private var isInputFocused: Bool

    
    var loadLastWatchedEpisode: () -> Void
    var saveLastWatchedEpisode: () -> Void

    var body: some View {
            VStack {
                
                if showPlayer {
                    ZStack {
                        
                        EpisodePlayerView(
                            episode: $episode, playbackPosition: $playbackPosition,
                            fillerEpisodes: $fillerEpisodes,
                            mixedFillerEpisodes: $mixedFillerEpisodes, 
                            skipFiller: $skipFiller,
                            skipMixed: $skipMixed,
                            isFirstEpisode: $isFirstEpisode, settings: $settings)
                    }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                buttonsReady = true
                            }
                            loadLastWatchedEpisode()  // Carica l'episodio e la posizione quando la vista appare
                        }
                }

                if settings {
                                Form {
                                                HStack {
                                                    Toggle(isOn: $skipFiller) {
                                                    }.toggleStyle(.switch).controlSize(.small)
                                                        .accentColor(Color.red)
                                                        .onChange(of: $skipFiller.wrappedValue) { newValue in
                                                            UserDefaults.standard.set(newValue, forKey: "skipFiller")
                                                        }
                                                        .onChange(of: skipFiller) { value in
                                                            if value {
                                                                skipMixed = true
                                                            }
                                                        }
                                                    Text("Consenti gli episodi ")
                                                    + Text("Filler").bold()
                                                    
                                                    
                                                    
                                                }
                                                HStack {
                                                    Toggle(isOn: $skipMixed) {
                                                    }.toggleStyle(.switch).controlSize(.small)
                                                        .accentColor(Color.orange)
                                                        .disabled(skipFiller)  // Disabilitato se skipFiller è attivato
                                                        .onChange(of: $skipMixed.wrappedValue) { newValue in
                                                            UserDefaults.standard.set(newValue, forKey: "skipMixed")
                                                        }
                                                    Text("Consenti episodi ")
                                                        + Text("mixed").bold()
                                                        + Text(" Canon/Filler")
                                                    
                                                }
                                }.padding(.top, 30)
                    
                }
                HStack {
                        Button(action: {
                            decrementEpisode()
                        }) {
                                Image(systemName: "arrow.backward.circle.fill")
                        }
                        .help("Vai all'episodio precedente.")
                        .buttonStyle(.borderless)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 80))
                        .opacity(buttonsReady ? 0.6 : 0.15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    //EP Attuale
                    VStack {
                        
                        Text("\(episode)").font(.system(size: 55)).foregroundColor(
                            mixedFillerEpisodes.contains(episode)
                            ? Color.orange
                            : fillerEpisodes.contains(episode)
                            ? Color.red : Color.gray)
                        if fillerEpisodes.contains(episode) {
                            Text("Filler!").fontWeight(.heavy).foregroundColor(Color.red)
                        }
                        if mixedFillerEpisodes.contains(episode) {
                            Text("Mixed Filler").fontWeight(.heavy).foregroundColor(Color.orange)
                        }
                        
                    }.padding()
                        .help("Questo è l'episodio attuale.")

                    Divider().frame(maxHeight: 25)
                    
                    //Impostazioni
                    Button(action: {
                        settings.toggle()
                    }) {
 
                            Image(systemName: settings ? "chevron.down" : "gear").opacity(0.6)
                    }.buttonStyle(.borderless).font(.system(size: 45)).padding(.horizontal)
                        .help("Apri le impostazioni.")
                    Divider().frame(maxHeight: 25)
                    
                    //Salvataggio
                    Button(action: {
                        saveLastWatchedEpisode()
                    }) {
 
                            Image(systemName: "square.and.arrow.down.badge.clock").opacity(0.6)
                    }.buttonStyle(.borderless).font(.system(size: 45)).padding(.horizontal)
                        .help("Salva l'episodio corrente e la sua posizione.")

                    Divider().frame(maxHeight: 25)
                    
                    //Search button
                    Button(action: {
                        searchExpand.toggle()
                    }) {
                        Image(systemName: isInputFocused ? "chevron.backward" : "1.magnifyingglass").opacity(0.6)
                        
                    }.buttonStyle(.borderless).font(.system(size: 45)).padding(.horizontal)
                        .help("Cerca un episodio.")


                    //Barra ricerca
                    if searchExpand {
                        VStack {
                            TextField("Cerca...", text: $inputEpisode)
                                .focused($isInputFocused)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 25, weight: .ultraLight)).frame(maxWidth: 150)
                                .onSubmit {
                                    if let episodeInt = Int(inputEpisode) {
                                        episode = episodeInt
                                    }
                                    searchExpand.toggle()
                                }.onAppear {
                                    isInputFocused = true
                                }.onChange(of: searchExpand) { value in
                                    if value {
                                        isInputFocused = true
                                    } else {
                                        isInputFocused = false
                                    }
                                }
                            Text("Scrivi il numero dell'episodio e premi invio").font(.caption)
                        }
                    }
                    
                        //Prossimo episodio
                        Button(action: {
                            incrementEpisode()
                        }) {
                            Image(systemName: "arrow.forward.circle.fill")
                        }
                        .help("Va al prossimo episodio.")

                        .buttonStyle(.borderless)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 80))
                        .opacity(buttonsReady ? 0.6 : 0.15)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()

                }
            }
    }
    
    // Funzione per decrementare l'episodio, saltando gli episodi filler o mixed filler
    func decrementEpisode() {
        if !skipFiller && !skipMixed {
            // Salta gli episodi filler e mixed filler quando si va avanti
            repeat {
                episode -= 1
            } while fillerEpisodes.contains(episode) || mixedFillerEpisodes.contains(episode)
        } else if !skipFiller {
            // Salta solo gli episodi filler
            repeat {
                episode -= 1
            } while fillerEpisodes.contains(episode)
        } else if !skipMixed {
            // Salta solo gli episodi mixed filler
            repeat {
                episode -= 1
            } while mixedFillerEpisodes.contains(episode)
        } else {
            // Incrementa normalmente se non si devono saltare episodi
            episode -= 1
        }
    }
    
    // Funzione per incrementare l'episodio, saltando gli episodi filler o mixed filler
    func incrementEpisode() {
        if !skipFiller && !skipMixed {
            // Salta gli episodi filler e mixed filler quando si va avanti
            repeat {
                episode += 1
            } while fillerEpisodes.contains(episode) || mixedFillerEpisodes.contains(episode)
        } else if !skipFiller {
            // Salta solo gli episodi filler
            repeat {
                episode += 1
            } while fillerEpisodes.contains(episode)
        } else if !skipMixed {
            // Salta solo gli episodi mixed filler
            repeat {
                episode += 1
            } while mixedFillerEpisodes.contains(episode)
        } else {
            // Incrementa normalmente se non si devono saltare episodi
            episode += 1
        }
    }

    
}
