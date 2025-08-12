import Foundation

struct EpisodeStateManager {
    static let episodeKey = "currentEpisode"
    static let playbackPositionKey = "playbackPosition"
    static let skipFillerKey = "skipFiller"
    static let skipMixedKey = "skipMixed"
    static let isFirstEpisodeKey = "isFirstEpisode"
    
    static func savePlaybackPosition(for episode: Int, position: Double, duration: Double) {
        let defaults = UserDefaults.standard
        defaults.set(position, forKey: "playbackPosition_\(episode)")
    }
    
    static func loadPlaybackPosition(for episode: Int) -> Double {
        return UserDefaults.standard.double(forKey: "playbackPosition_\(episode)")
    }
    
    
    static func save(
        episode: Int,
        playbackPosition: Double,
        skipFiller: Bool,
        skipMixed: Bool,
        isFirstEpisode: Bool
    ) {
        let defaults = UserDefaults.standard
        defaults.set(episode, forKey: episodeKey)
        defaults.set(playbackPosition, forKey: playbackPositionKey)
        defaults.set(skipFiller, forKey: skipFillerKey)
        defaults.set(skipMixed, forKey: skipMixedKey)
        defaults.set(isFirstEpisode, forKey: isFirstEpisodeKey)
    }
    
    static func load() -> (
        episode: Int,
        playbackPosition: Double,
        skipFiller: Bool,
        skipMixed: Bool,
        isFirstEpisode: Bool
    ) {
        let defaults = UserDefaults.standard
        let episode = defaults.integer(forKey: episodeKey)
        let playbackPosition = defaults.double(forKey: playbackPositionKey)
        let skipFiller = defaults.bool(forKey: skipFillerKey)
        let skipMixed = defaults.bool(forKey: skipMixedKey)
        let isFirstEpisode = defaults.bool(forKey: isFirstEpisodeKey)
        
        return (episode, playbackPosition, skipFiller, skipMixed, isFirstEpisode)
    }
}
