//
//  SpotifyController.swift
//  Magnify
//

import Foundation

class SpotifyController {

    class func task(command: String) -> String? {
        let task = NSTask()
        let prefix = "tell application \"Spotify\" to"
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "\(prefix) \(command)"]
        let outPipe = NSPipe()
        task.standardOutput = outPipe
        task.launch()
        task.waitUntilExit()
        let outHandle = outPipe.fileHandleForReading
        let output = NSString(data: outHandle.availableData, encoding: NSASCIIStringEncoding)
        return output
    }

    class func trackInfoTask(command: String) -> String? {
        return task("\(command) of current track")
    }

// MARK: Application Info

// MARK: Track Info
    /// The URL of the track.
    class func currentTrackURL() -> String? { return trackInfoTask("spotify url") }

    /// The name of the track.
    class func currentTrackName() -> String? { return trackInfoTask("name") }

    /// The artist of the track.
    class func currentTrackArtist() -> String? { return trackInfoTask("artist") }

    /// The album artist of the track.
    class func currentTrackAlbumArtist() -> String? { return trackInfoTask("album artist") }

    /// The number of times this track has been played.
    class func currentTrackPlayCount() -> Int? { return trackInfoTask("played countk")?.toInt() }

    /// How popular is this track? 0-100
    class func currentTrackPopularity() -> Int? { return trackInfoTask("popularity")?.toInt() }

// MARK: Commands
    /// Pause playback.
    class func pause() { task("pause") }

    /// Resume playback.
    class func play() { task("play") }

    /// Play the given spotify URL.
    class func play(spotifyURL: String) { task("play track \(spotifyURL)") }

    /// Skip to the next track.
    class func nextTrack() { task("next track") }

    /// Skip to the previous track.
    class func previousTrack() { task("previous track") }

// MARK: Standard app commands
    class func quit() { task("quit") }

    class func version() -> String? { return task("version") }

    class func frontmost() -> Bool? { return task("frontmost")?.rangeOfString("true") != nil }

}
