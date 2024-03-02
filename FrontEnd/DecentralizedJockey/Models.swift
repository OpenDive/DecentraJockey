//
//  Models.swift
//  DecentralizedJockey
//
//  Created by Marcus Arnett on 2/27/24.
//

import Foundation

struct PlaylistItem: Identifiable {
    let id: String = UUID().uuidString
    let playlistTitle: String
    let playlistDescription: String
    let playlist: [SongItem]
    let albumCover: String
}

struct SongItem: Identifiable {
    let id: String = UUID().uuidString
    let songTitle: String
    let artist: String
    let song: String  // TODO: Change over to [UInt8] when using binary data.
    let duration: SongTimestamp
    let albumCover: String = "0"  // TODO: Change over to be dynamically assigned.
}

struct SongTimestamp {
    let hours: Int
    let minutes: Int
    let seconds: Int
    
    init(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    init(seconds: Int) {
        var secondsSoFar = seconds
        if secondsSoFar >= 3600 {
            self.hours = Int(floor(Double(seconds / 3600)))
            secondsSoFar = secondsSoFar % 3600
        } else {
            self.hours = 0
        }
        
        if secondsSoFar >= 60 {
            self.minutes = Int(floor(Double(seconds / 60)))
            secondsSoFar = secondsSoFar % 60
        } else {
            self.minutes = 0
        }
        
        self.seconds = secondsSoFar
    }
    
    func totalSeconds() -> Double {
        return Double((hours * 3600) + (minutes * 60) + seconds)
    }
    
    func getTimecode() -> String {
        if hours != 0 {
            return "\(hours):\(minutes):\(seconds)"
        } else {
            return "\(minutes):\(seconds)"
        }
    }
}

struct SongVoteItem: Identifiable {
    let id: String = UUID().uuidString
    let song: SongItem
    let amount: Double
}

struct VoteItem {
    let contenders: [SongVoteItem]
    let totalVotes: Double
}

let mockVoteItem: VoteItem = VoteItem(
    contenders: [
        SongVoteItem(song: SongItem(songTitle: "Virtual Love", artist: "The Netizens", song: "song1", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 45)), amount: 300),
        SongVoteItem(song: SongItem(songTitle: "Social Media Blues", artist: "Profile Pics", song: "song5", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 5)), amount: 260),
        SongVoteItem(song: SongItem(songTitle: "Popup Dreams", artist: "Ad Blockers", song: "song4", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 40)), amount: 100)
    ],
    totalVotes: 660
)

let mockPlaylist: [PlaylistItem] = [
    PlaylistItem(playlistTitle: "2000s Internet Hits", playlistDescription: "Iconic songs that defined the internet culture in the 2000s", playlist: [
        SongItem(songTitle: "Virtual Love", artist: "The Netizens", song: "song1", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 45)),
        SongItem(songTitle: "Click Refresh", artist: "Cache Clear", song: "song2", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 20)),
        SongItem(songTitle: "Eternal Loading", artist: "Buffering Hearts", song: "song3", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 55)),
        SongItem(songTitle: "Popup Dreams", artist: "Ad Blockers", song: "song4", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 40)),
        SongItem(songTitle: "Social Media Blues", artist: "Profile Pics", song: "song5", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 5))
    ], albumCover: "0"),
    PlaylistItem(playlistTitle: "Punk Rock Tops", playlistDescription: "The top punk rock tracks of all time", playlist: [
        SongItem(songTitle: "Anarchy Melody", artist: "The Rebels", song: "song1", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 30)),
        SongItem(songTitle: "Mohawk Spirit", artist: "Punk's Not Dead", song: "song2", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 50)),
        SongItem(songTitle: "Underground Sound", artist: "The Alley", song: "song3", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 15)),
        SongItem(songTitle: "Riot Harmony", artist: "The Clashers", song: "song4", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 10)),
        SongItem(songTitle: "Skate or Die", artist: "Halfpipe", song: "song5", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 45))
    ], albumCover: "1"),
    PlaylistItem(playlistTitle: "Best of Frank Ocean", playlistDescription: "The greatest hits by Frank Ocean", playlist: [
        SongItem(songTitle: "Ocean Waves", artist: "Frank Ocean", song: "song1", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 30)),
        SongItem(songTitle: "Nostalgic Ultra", artist: "Frank Ocean", song: "song2", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 20)),
        SongItem(songTitle: "Channel Orange Sky", artist: "Frank Ocean", song: "song3", duration: SongTimestamp(hours: 0, minutes: 5, seconds: 15)),
        SongItem(songTitle: "Blonde on Blonde", artist: "Frank Ocean", song: "song4", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 45)),
        SongItem(songTitle: "Endless Love", artist: "Frank Ocean", song: "song5", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 55))
    ], albumCover: "2"),
    PlaylistItem(playlistTitle: "Swiftie Favorites", playlistDescription: "Favorite tracks among Taylor Swift fans", playlist: [
        SongItem(songTitle: "Heartstrings", artist: "Taylor Swift", song: "song1", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 10)),
        SongItem(songTitle: "Red Memories", artist: "Taylor Swift", song: "song2", duration: SongTimestamp(hours: 0, minutes: 5, seconds: 0)),
        SongItem(songTitle: "Blank Space Fillers", artist: "Taylor Swift", song: "song3", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 45)),
        SongItem(songTitle: "Swift Winds", artist: "Taylor Swift", song: "song4", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 25)),
        SongItem(songTitle: "Lover's Tale", artist: "Taylor Swift", song: "song5", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 50))
    ], albumCover: "3"),
    PlaylistItem(playlistTitle: "My Chemical Romance Top Hits", playlistDescription: "Top hits from My Chemical Romance", playlist: [
        SongItem(songTitle: "Black Parade March", artist: "My Chemical Romance", song: "song1", duration: SongTimestamp(hours: 0, minutes: 5, seconds: 11)),
        SongItem(songTitle: "Helena's Heartbeat", artist: "My Chemical Romance", song: "song2", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 22)),
        SongItem(songTitle: "Teenagers Scare", artist: "My Chemical Romance", song: "song3", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 59)),
        SongItem(songTitle: "Ghost of You", artist: "My Chemical Romance", song: "song4", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 9)),
        SongItem(songTitle: "Famous Last Notes", artist: "My Chemical Romance", song: "song5", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 18))
    ], albumCover: "4"),
    PlaylistItem(playlistTitle: "2010s Favorites", playlistDescription: "The most beloved songs of the 2010s", playlist: [
        SongItem(songTitle: "Digital Heartbeat", artist: "The Screenagers", song: "song1", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 25)),
        SongItem(songTitle: "Viral Sensation", artist: "Flash Mob", song: "song2", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 10)),
        SongItem(songTitle: "Cloud Nine", artist: "Sky Surfers", song: "song3", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 50)),
        SongItem(songTitle: "Streaming Love", artist: "Playlist Playas", song: "song4", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 5)),
        SongItem(songTitle: "Touchscreen", artist: "Gesture", song: "song5", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 45))
    ], albumCover: "5"),
    PlaylistItem(playlistTitle: "Top of Pop", playlistDescription: "Pop music at its finest across the decades", playlist: [
        SongItem(songTitle: "Bubblegum Beats", artist: "Candy Hearts", song: "song1", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 30)),
        SongItem(songTitle: "Electric Harmony", artist: "Pop Icons", song: "song2", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 15)),
        SongItem(songTitle: "Melodic Waves", artist: "Chart Toppers", song: "song3", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 55)),
        SongItem(songTitle: "Dance Floor Anthem", artist: "Groove Giants", song: "song4", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 0)),
        SongItem(songTitle: "Love Pop", artist: "Heartthrob", song: "song5", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 20))
    ], albumCover: "6"),
    PlaylistItem(playlistTitle: "Daft Punk Memories", playlistDescription: "Remembering the iconic tracks of Daft Punk", playlist: [
        SongItem(songTitle: "Robot Rock Revival", artist: "Daft Punk", song: "song1", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 45)),
        SongItem(songTitle: "Digital Love Reimagined", artist: "Daft Punk", song: "song2", duration: SongTimestamp(hours: 0, minutes: 5, seconds: 0)),
        SongItem(songTitle: "One More Time Celebration", artist: "Daft Punk", song: "song3", duration: SongTimestamp(hours: 0, minutes: 5, seconds: 20)),
        SongItem(songTitle: "Harder Better Faster Stronger Evolution", artist: "Daft Punk", song: "song4", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 45)),
        SongItem(songTitle: "Around the World Trip", artist: "Daft Punk", song: "song5", duration: SongTimestamp(hours: 0, minutes: 7, seconds: 10))
    ], albumCover: "7"),
    PlaylistItem(playlistTitle: "Mid 2000s Faves", playlistDescription: "Favorite hits from the mid-2000s", playlist: [
        SongItem(songTitle: "Flip Phone Anthems", artist: "Dial Tones", song: "song1", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 20)),
        SongItem(songTitle: "MP3 Shuffle", artist: "The Playlist", song: "song2", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 55)),
        SongItem(songTitle: "Ringtone Melodies", artist: "Signal Strength", song: "song3", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 5)),
        SongItem(songTitle: "Social Network Serenade", artist: "Friend Request", song: "song4", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 50)),
        SongItem(songTitle: "Blog Love", artist: "The Posters", song: "song5", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 30))
    ], albumCover: "8"),
    PlaylistItem(playlistTitle: "Late 2010s Hits", playlistDescription: "The defining hits of the late 2010s", playlist: [
        SongItem(songTitle: "Streaming Stars", artist: "The Influencers", song: "song1", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 40)),
        SongItem(songTitle: "Like and Share", artist: "Viral Voices", song: "song2", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 55)),
        SongItem(songTitle: "Hashtag Heart", artist: "Trend Setters", song: "song3", duration: SongTimestamp(hours: 0, minutes: 4, seconds: 5)),
        SongItem(songTitle: "Swipe Right", artist: "Connection", song: "song4", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 30)),
        SongItem(songTitle: "Digital Detox", artist: "The Unplugged", song: "song5", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 15))
    ], albumCover: "9"),
    PlaylistItem(playlistTitle: "Best of Blink-182", playlistDescription: "The best tracks from Blink-182", playlist: [
        SongItem(songTitle: "All The Small Things Revisited", artist: "Blink-182", song: "song1", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 48)),
        SongItem(songTitle: "What's My Age Again? Now", artist: "Blink-182", song: "song2", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 29)),
        SongItem(songTitle: "I Miss You More", artist: "Blink-182", song: "song3", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 47)),
        SongItem(songTitle: "Feeling This Feeling", artist: "Blink-182", song: "song4", duration: SongTimestamp(hours: 0, minutes: 2, seconds: 53)),
        SongItem(songTitle: "The Rock Show Continues", artist: "Blink-182", song: "song5", duration: SongTimestamp(hours: 0, minutes: 3, seconds: 8))
    ], albumCover: "10")
]
