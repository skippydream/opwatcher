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
    @State private var settings = false
    @State private var showPlayer = true
    @State var progressi: Bool = UserDefaults.standard.bool(forKey: "progressi")
    @State var skipFiller: Bool = UserDefaults.standard.bool(forKey: "skipFiller")
    @State var skipMixed: Bool = UserDefaults.standard.bool(forKey: "skipMixed")
    @FocusState private var isInputFocused: Bool
    var loadLastWatchedEpisode: () -> Void

    var body: some View {
        
            VStack {
                if showPlayer {
                    ZStack {
                        EpisodePlayerView(
                            episode: $episode, playbackPosition: $playbackPosition,
                            fillerEpisodes: $fillerEpisodes,
                            mixedFillerEpisodes: $mixedFillerEpisodes,
                            progressi: $progressi,
                            skipFiller: $skipFiller,
                            skipMixed: $skipMixed,
                            isFirstEpisode: $isFirstEpisode, incrementEpisode: incrementEpisode,
                            decrementEpisode: decrementEpisode)
                    }.background(VisualEffect().ignoresSafeArea())
                        .onAppear {
                            loadLastWatchedEpisode()  // Carica l'episodio e la posizione quando la vista appare
                        }
                }
                if !settings {
                    if searchExpand {
                        TextField("Cerca un episodio (es. 37)", text: $inputEpisode).focused(
                            $isInputFocused
                        ).textFieldStyle(PlainTextFieldStyle()).padding(
                            EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 15)
                        ).background(
                            RoundedRectangle(cornerRadius: 50).strokeBorder(
                                Color.gray, lineWidth: 0.5)
                        ).font(.system(size: 24, weight: .ultraLight)).frame(maxWidth: .infinity)
                            .onSubmit {
                                if let episodeInt = Int(inputEpisode) {
                                    episode = episodeInt
                                }
                                searchExpand.toggle()
                            }.padding(.horizontal, 80).padding(.top, 10).onAppear {
                                isInputFocused = true
                            }.onChange(of: searchExpand) { value in
                                if value {
                                    isInputFocused = true
                                } else {
                                    isInputFocused = false
                                }
                            }
                    }
                }
                if settings {
                                List {
                                    Section(header: Text("Salvataggio").padding(.vertical)) {
                                        HStack {
                                            Toggle(isOn: $progressi) {
                                            }.toggleStyle(.switch).controlSize(.small)
                                                .onChange(of: $progressi.wrappedValue) { newValue in
                                                    UserDefaults.standard.set(newValue, forKey: "progressi")
                                                }
                                            Text("Salvataggio automatico dei progressi")
                                            
                                        }
                                    }
                                            Section(header: Text("Filler").padding(.vertical)) {
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
                                                    Text("Consenti gli episodi Filler")
                                                    
                                                    
                                                    
                                                }
                                                HStack {
                                                    Toggle(isOn: $skipMixed) {
                                                    }.toggleStyle(.switch).controlSize(.small)
                                                        .accentColor(Color.orange)
                                                        .disabled(skipFiller)  // Disabilitato se skipFiller è attivato
                                                        .onChange(of: $skipMixed.wrappedValue) { newValue in
                                                            UserDefaults.standard.set(newValue, forKey: "skipMixed")
                                                        }
                                                    Text("Consenti episodi mixed Canon/Filler")
                                                }
                                            }
                                    }
                                .padding(.leading, 40)
                                .frame(maxHeight: 160)
                                .listStyle(SidebarListStyle())

                    
                }
                    HStack {
                      
                        
                        //Impostazioni
                        Button(action: {
                            settings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill").opacity(0.45)
                            
                        }.buttonStyle(.borderless).font(.system(size: 30)).padding()
                        
                        Divider().frame(height: 40)
                        
                        //TextField
                        Button(action: {
                            searchExpand.toggle()  // Carica l'ultimo episodio
                            
                        }) {
                            VStack {
                                Text("Ep. attuale:").font(.caption2)
                                Text("\(episode)").font(.system(size: 30)).foregroundColor(
                                    mixedFillerEpisodes.contains(episode)
                                    ? Color.orange
                                    : fillerEpisodes.contains(episode)
                                    ? Color.red : Color.gray)
                            }
                        }.buttonStyle(.borderless).font(.system(size: 30)).padding()
                            .opacity(0.8)

                    }.offset(y: -5)

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
