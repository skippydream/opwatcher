import SwiftUI
import AVKit
import Combine

struct DownloadItem: Identifiable {
    let id = UUID()
    let episode: Int
    var isDownloading: Bool = false
    var progress: Double = 0.0
    var localFileURL: URL? = nil
}

class DownloadManager: ObservableObject {
    @Published var downloads: [DownloadItem] = []
    private var totalDuration: Double?
    
    init() {
        loadExistingDownloads()
    }
    
    private func getBaseFolder() -> URL {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupportDir.appendingPathComponent("OnePieceDownloads")
        return folder
    }
    
    func loadExistingDownloads() {
        let fileManager = FileManager.default
        let baseFolder = getBaseFolder()
        
        guard fileManager.fileExists(atPath: baseFolder.path) else {
            print("Cartella download non trovata")
            return
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: baseFolder, includingPropertiesForKeys: nil)
            var loadedDownloads: [DownloadItem] = []
            
            for fileURL in files {
                let filename = fileURL.lastPathComponent
                // Assumiamo il formato "OnePiece_Episode_X.mp4"
                if filename.hasPrefix("OnePiece_Episode_"), filename.hasSuffix(".mp4") {
                    let start = filename.index(filename.startIndex, offsetBy: 17)
                    let end = filename.index(filename.endIndex, offsetBy: -4)
                    let episodeString = filename[start..<end]
                    if let episode = Int(episodeString) {
                        let item = DownloadItem(episode: episode, isDownloading: false, progress: 1.0, localFileURL: fileURL)
                        loadedDownloads.append(item)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.downloads = loadedDownloads.sorted(by: { $0.episode < $1.episode })
            }
        } catch {
            print("Errore nel caricamento dei file: \(error.localizedDescription)")
        }
    }
    
    func prepareOutputURL(for episodeName: String) -> URL? {
        let baseFolder = getBaseFolder()
        
        if !FileManager.default.fileExists(atPath: baseFolder.path) {
            do {
                try FileManager.default.createDirectory(at: baseFolder, withIntermediateDirectories: true)
                print("Cartella creata: \(baseFolder.path)")
            } catch {
                print("Errore nella creazione della cartella: \(error.localizedDescription)")
                return nil
            }
        }
        
        return baseFolder.appendingPathComponent("\(episodeName).mp4")
    }
    
    func startDownload(for episode: Int, from url: URL) {
        if downloads.contains(where: { $0.episode == episode && $0.isDownloading }) { return }
        
        let item = DownloadItem(episode: episode, isDownloading: true)
        
        DispatchQueue.main.async {
            self.downloads.append(item)
        }
        
        let episodeName = "OnePiece_Episode_\(episode)"
        guard let outputURL = prepareOutputURL(for: episodeName) else {
            print("Errore: impossibile creare la cartella di destinazione.")
            return
        }
        
        print("Path file output: \(outputURL.path)")
        
        DispatchQueue.global(qos: .background).async {
            let process = Process()
            
            guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
                print("❌ ffmpeg non trovato nel bundle!")
                DispatchQueue.main.async {
                    if let index = self.downloads.firstIndex(where: { $0.episode == episode }) {
                        self.downloads.remove(at: index)
                    }
                }
                return
            }
            
            try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: ffmpegPath)
            
            process.executableURL = URL(fileURLWithPath: ffmpegPath)
            process.arguments = ["-y", "-i", url.absoluteString, "-c", "copy", outputURL.path]
            
            let pipe = Pipe()
            process.standardError = pipe
            process.standardOutput = pipe
            
            pipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if data.count > 0 {
                    if let outputString = String(data: data, encoding: .utf8) {
                        // print("[ffmpeg] " + outputString)
                        
                        if let duration = self.extractDuration(from: outputString) {
                            DispatchQueue.main.async {
                                self.totalDuration = duration
                            }
                        }
                        
                        if let currentTime = self.extractCurrentTime(from: outputString),
                           let totalDuration = self.totalDuration, totalDuration > 0 {
                            let progress = currentTime / totalDuration
                            DispatchQueue.main.async {
                                if let index = self.downloads.firstIndex(where: { $0.episode == episode }) {
                                    self.downloads[index].progress = progress
                                }
                            }
                        }
                    }
                } else {
                    pipe.fileHandleForReading.readabilityHandler = nil
                }
            }
            
            process.terminationHandler = { proc in
                if proc.terminationStatus == 0 {
                    DispatchQueue.main.async {
                        if let index = self.downloads.firstIndex(where: { $0.episode == episode }) {
                            self.downloads[index].isDownloading = false
                            self.downloads[index].localFileURL = outputURL
                            self.downloads[index].progress = 1.0
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if let index = self.downloads.firstIndex(where: { $0.episode == episode }) {
                            self.downloads.remove(at: index)
                        }
                    }
                }
            }
            
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Errore avvio ffmpeg: \(error)")
                DispatchQueue.main.async {
                    if let index = self.downloads.firstIndex(where: { $0.episode == episode }) {
                        self.downloads.remove(at: index)
                    }
                }
            }
        }
    }
    
    private func extractDuration(from ffmpegOutput: String) -> Double? {
        guard let range = ffmpegOutput.range(of: "Duration: ") else { return nil }
        let durationString = ffmpegOutput[range.upperBound...].prefix(11)
        let parts = durationString.split(separator: ":")
        if parts.count == 3,
           let hours = Double(parts[0]),
           let minutes = Double(parts[1]),
           let seconds = Double(parts[2].replacingOccurrences(of: ",", with: "")) {
            return hours * 3600 + minutes * 60 + seconds
        }
        return nil
    }
    
    private func extractCurrentTime(from ffmpegOutput: String) -> Double? {
        guard let range = ffmpegOutput.range(of: "time=") else { return nil }
        let timeString = ffmpegOutput[range.upperBound...].prefix(11)
        let parts = timeString.split(separator: ":")
        if parts.count == 3,
           let hours = Double(parts[0]),
           let minutes = Double(parts[1]),
           let seconds = Double(parts[2].replacingOccurrences(of: " ", with: "")) {
            return hours * 3600 + minutes * 60 + seconds
        }
        return nil
    }
}

struct DownloadManagerView: View {
    @StateObject private var downloadManager = DownloadManager()
    @State var selectedEpisodeToPlay: Int? = nil
    @State private var showPlayer = false
    @Binding var openDownloads: Bool
    @Binding var episode: Int
    
    // Ora mostra tutti gli episodi scaricati (o scaricabili) dinamicamente
    var episodesToShow: [Int] {
        // Unisci episodi scaricati + 10 episodi recenti da scaricare
        let maxDownloaded = downloadManager.downloads.map { $0.episode }.max() ?? 0
        let maxEpisode = episode + 25

        return Array(episode...maxEpisode)
    }

    var body: some View {
        VStack {
            List(episodesToShow, id: \.self) { episode in
                HStack {
                    Text("Episodio \(episode)")
                    Spacer()
                    if let download = downloadManager.downloads.first(where: { $0.episode == episode }) {
                        if download.isDownloading {
                            ProgressView(value: download.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 150)
                        } else if let localURL = download.localFileURL {
                            Button("Play") {
                                selectedEpisodeToPlay = episode
                                showPlayer = true
                            }
                            .buttonStyle(.borderless)
                        } else {
                            downloadButton(for: episode)
                        }
                    } else {
                        downloadButton(for: episode)
                    }
                }
                .padding(.vertical, 6)
            }
            .listStyle(PlainListStyle())
            
            HStack {
                // Torna indietro
                Button(action: {
                    openDownloads = false
                }) {
                    Image(systemName: "chevron.backward.circle")
                        .font(.system(size: 33))
                        .foregroundColor(.gray)
                        .opacity(0.6)
                }
                .help("Chiudi la vista dei download.")
                .buttonStyle(.borderless)
                .padding(.top, 12)
                                
                Spacer()
                
                // Cartella
                Button(action: {
                    if let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                        let folderURL = appSupportURL.appendingPathComponent("OnePieceDownloads")
                        
                        if FileManager.default.fileExists(atPath: folderURL.path) {
                            NSWorkspace.shared.open(folderURL)
                        } else {
                            print("Cartella non trovata")
                        }
                    } else {
                        print("Impossibile trovare la directory Application Support")
                    }
                }) {
                    Image(systemName: "folder.circle")
                        .font(.system(size: 33))
                        .foregroundColor(.gray)
                        .opacity(0.6)
                }
                .help("Apri directory di download.")
                .buttonStyle(.borderless)
                .padding(.top, 12)
            }
            .padding(.bottom, 20)

        }
        .frame(minWidth: 400, minHeight: 400)
        .padding()
        .sheet(isPresented: $showPlayer, onDismiss: {
            selectedEpisodeToPlay = nil
        }) {
            if let episode = selectedEpisodeToPlay,
               let download = downloadManager.downloads.first(where: { $0.episode == episode }),
               let url = download.localFileURL {
                VideoPlayerView(url: url)
            } else {
                Text("Riprova")
            }
        }
    }

    @ViewBuilder
        private func downloadButton(for episode: Int) -> some View {
            Button(action: {
                let url = getVideoURL(for: episode)
                downloadManager.startDownload(for: episode, from: url)
            }) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.borderless)
            .help("Scarica episodio \(episode).")
        }


    func getVideoURL(for episode: Int) -> URL {
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
        default: baseURL = "https://srv37.nezumi.streampeaker.org/DDL/ANIME/OnePiece/"
        }
        let episodeString = String(format: "%04d", episode)
        return URL(string: "\(baseURL)\(episodeString)/playlist.m3u8")!
    }
}

struct VideoPlayerView: View {
    let url: URL
    var body: some View {
        CustomVideoPlayerView(url: url, showsFullScreenToggleButton: true)
                  .frame(minWidth: 640, minHeight: 360)
    }
}
