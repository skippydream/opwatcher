import AVKit
import SwiftUI

struct ContentView: View {
     @Binding var episode: Int
     @State var showPlayer = true
     @State var commands = true
     @State var inputEpisode: String = ""
     @State var isFullscreen = false
     @Binding var fillerEpisodes: [Int]
     @Binding var mixedFillerEpisodes: [Int]
     @Binding var lastWatchedEpisode: Int
     @State private var fillerAlert = false
     @State private var mixedFillerAlert = false
     @State private var errorMessage: String?
     @State private var mixedFillerAlertMessage: String = ""
     @State private var searchExpand = false
     @FocusState private var isInputFocused: Bool
     var loadLastWatchedEpisode: () -> Void
     var saveLastWatchedEpisode: () -> Void
     
    var body: some View {
          VStack {
              
               if showPlayer {
                    ZStack {
                         EpisodePlayerView(
                              episode: $episode, isFullscreen: $isFullscreen,
                              fillerEpisodes: $fillerEpisodes,
                              mixedFillerEpisodes: $mixedFillerEpisodes,
                              lastWatchedEpisode: lastWatchedEpisode, showPlayer: $showPlayer,
                              commands: $commands, saveLastWatchedEpisode: saveLastWatchedEpisode)
                    }.background(Color.black)
                   
                    if searchExpand {
                         TextField("Cerca un episodio (es. 37)", text: $inputEpisode).focused(
                              $isInputFocused
                         ).textFieldStyle(PlainTextFieldStyle()).padding(
                              EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 15)
                         ).background(
                              RoundedRectangle(cornerRadius: 100).strokeBorder(
                                   Color.gray, lineWidth: 0.5)
                         ).font(.system(size: 24, weight: .ultraLight)).frame(maxWidth: .infinity)
                              .onSubmit {
                                   if let episodeInt = Int(inputEpisode) {
                                        if fillerEpisodes.contains(episodeInt) {
                                             fillerAlert = true
                                        } else if mixedFillerEpisodes.contains(episodeInt) {
                                             mixedFillerAlert = true
                                        } else {
                                             episode = episodeInt
                                             showPlayer = true
                                        }
                                   } else {
                                        mixedFillerAlert = true
                                   }
                              }.alert(
                                   "L'episodio \(inputEpisode) è Filler", isPresented: $fillerAlert
                              ) { Button("OK", role: .cancel) {} }.alert(
                                   isPresented: $mixedFillerAlert
                              ) {
                                   Alert(
                                        title: Text("Episodio mixed Canon/Filler"),
                                        message: Text("Vuoi guardarlo lo stesso?"),
                                        primaryButton: .default(Text("Procedi")) {
                                             episode = Int(inputEpisode) ?? episode
                                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                  showPlayer = true
                                             }
                                        }, secondaryButton: .cancel {})
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
              
               if commands {
                    HStack {
                         //Precedente episodio
                         Button(action: { episode -= 1 }) {
                              Image(systemName: "arrow.backward.circle.fill")
                         }.buttonStyle(.borderless).font(.system(size: 65)).padding(.horizontal, 30)
                              .padding().frame(maxWidth: .infinity, alignment: .leading)
                         //Cerca
                         Button(action: {
                              searchExpand.toggle()  // Carica l'ultimo episodio
                         }) {
                              Image(systemName: "magnifyingglass.circle.fill").opacity(0.4)

                         }.buttonStyle(.borderless).font(.system(size: 50)).padding()

                         Divider().frame(height: 30)
                        
                         //TextField
                         Button(action: {}) {
                              Image(systemName: "film.fill").font(.system(size: 55))
                              VStack {
                                   Text("Ep. attuale:").font(.caption)
                                   Text("\(episode)").font(.system(size: 30)).foregroundColor(
                                        mixedFillerEpisodes.contains(episode)
                                             ? Color.orange
                                             : fillerEpisodes.contains(episode)
                                                  ? Color.red : Color.gray)
                              }
                         }.buttonStyle(.borderless).disabled(true).font(.system(size: 50)).padding()
                              .opacity(0.8)

                         //Prossimo episodio
                         Button(action: { episode += 1 }) {
                              Image(systemName: "arrow.forward.circle.fill")
                         }.frame(maxWidth: .infinity, alignment: .trailing)
                              .buttonStyle(.borderless).font(.system(size: 65)).padding().padding(
                                   .horizontal, 30)
                    }.offset(y: -5)
               }
          }
     }
}
