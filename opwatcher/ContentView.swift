import AVKit
import SwiftUI

struct ContentView: View {
    @Binding var episode: Int
    @Binding var playbackPosition: Double
    @State var inputEpisode: String = ""
    @Binding var fillerEpisodes: [Int]
    @Binding var isFirstEpisode : Bool
    @Binding var mixedFillerEpisodes: [Int]
    @State private var searchExpand = false
    @State var settings = false
    @State private var showPlayer = true
    @State var skipFiller: Bool = UserDefaults.standard.bool(forKey: "skipFiller")
    @State var skipMixed: Bool = UserDefaults.standard.bool(forKey: "skipMixed")
    @FocusState private var isInputFocused: Bool
    @State private var isSynced: Bool = false
    @Binding var cinema: Bool
    @State private var openDownloads = false

    var body: some View {
        VStack {
            ZStack {
                if !cinema {
                    //EP Attuale
                    HStack {
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
                        
                    }
                    
                    .help("Questo è l'episodio attuale.")
                    .padding(1)
                }
            }
            if showPlayer {
                ZStack {
                    
                    EpisodePlayerView(
                        episode: $episode, playbackPosition: $playbackPosition,
                        fillerEpisodes: $fillerEpisodes,
                        mixedFillerEpisodes: $mixedFillerEpisodes,
                        skipFiller: $skipFiller,
                        skipMixed: $skipMixed,
                        isFirstEpisode: $isFirstEpisode, settings: $settings, cinema: $cinema)
                }
                .padding(.bottom, 30)
                
                
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
            if !cinema {
                HStack {
                    //EP precedente
                    Button(action: {
                        decrementEpisode()
                    }) {
                        Image(systemName: "arrow.backward.circle.fill")
                    }
                    .help("Vai all'episodio precedente.")
                    .buttonStyle(.borderless)
                    .foregroundColor(Color.gray)
                    .font(.system(size: 80))
                    .opacity(0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    //Impostazioni
                    if !searchExpand {
                        Button(action: {
                            settings.toggle()
                        }) {
                            
                            Image(systemName: settings ? "chevron.down" : "gear").opacity(0.6)
                        }.buttonStyle(.borderless).font(.system(size: 45)).padding(.horizontal)
                            .help("Apri le impostazioni.")
                        //Download
                        Button(action: {
                            openDownloads = true
                        }) {
                            Image(systemName: "arrow.down.circle").opacity(0.6)
                        }
                        .buttonStyle(.borderless)
                        .font(.system(size: 45))
                        .padding(.horizontal)
                        .help("Apri i download.")
                        .sheet(isPresented: $openDownloads) {
                            DownloadManagerView(openDownloads: $openDownloads, episode: $episode)
                            
                        }
                    }
                        //Search button
                        Button(action: {
                            searchExpand.toggle()
                        }) {
                            Image(systemName: searchExpand ? "chevron.backward.circle" : "1.magnifyingglass").opacity(0.6)
                            
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
                        .opacity(0.6)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                        
                    }
                .onAppear {
                    let state = EpisodeStateManager.load()
                    episode = state.episode > 0 ? state.episode : episode // evita 0 se mai salvato
                    playbackPosition = state.playbackPosition
                    skipFiller = state.skipFiller
                    skipMixed = state.skipMixed
                    isFirstEpisode = state.isFirstEpisode
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
        func lockWindowAspectRatio(for window: NSWindow) {
            let aspectWidth: CGFloat = 600
            let aspectHeight: CGFloat = 580
            let aspectRatio = NSSize(width: aspectWidth, height: aspectHeight)
            
            window.setContentSize(aspectRatio)
            window.aspectRatio = aspectRatio
            
            // (Opzionale) Limiti di resizing coerenti con l'aspect ratio
            //window.minSize = NSSize(width: 300, height: 290)
            //window.maxSize = NSSize(width: 1200, height: 1160)
        }
        
        
    }

