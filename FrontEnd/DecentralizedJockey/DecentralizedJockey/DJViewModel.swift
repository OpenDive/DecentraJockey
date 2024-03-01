//
//  DJViewModel.swift
//  DecentralizedJockey
//
//  Created by Marcus Arnett on 2/28/24.
//

import SwiftUI

class DJViewModel: ObservableObject {
    @Published var currentSongPointer: Int? = nil
    @Published var currentSong: SongItem? = nil
    @Published var currentPlaylist: [SongItem]? = nil
    @Published var playlists: [PlaylistItem]
    @Published var isPlaying = false
    @Published var currentTimestamp: Double = 0
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var vote: VoteItem? = nil

    init() {
        self.playlists = Self.initializePlaylist()
    }

    public func nextSong() {
        if 
            self.currentPlaylist != nil &&
            currentSongPointer != nil &&
            currentSongPointer! + 1 < self.currentPlaylist!.count
        {
            currentSongPointer! += 1
            currentSong = currentPlaylist![currentSongPointer!]
        }
    }

    public func previousSong() {
        if
            self.currentPlaylist != nil &&
            currentSongPointer != nil &&
            currentSongPointer! - 1 >= 0
        {
            currentSongPointer! -= 1
            currentSong = currentPlaylist![currentSongPointer!]
        }
    }
    
    public func addPlaylistToQueue(playlist: PlaylistItem) {
        currentPlaylist?.append(contentsOf: playlist.playlist)
    }
    
    public func addPlaylistToUpcoming(playlist: PlaylistItem) {
        if
            self.currentPlaylist != nil &&
            self.currentSongPointer != nil
        {
            let playlistCount = self.currentPlaylist!.count
            self.currentPlaylist!.removeSubrange(ClosedRange(uncheckedBounds: (lower: (self.currentSongPointer! + 1), upper: (playlistCount - 1))))
            self.currentPlaylist!.append(contentsOf: playlist.playlist)
        }
    }

    public func overridePlaylist(playlist: PlaylistItem) {
        self.currentPlaylist = playlist.playlist
        self.currentSong = playlist.playlist[0]
        self.currentSongPointer = 0
    }
    
    public func initializeVote() {
        self.vote = mockVoteItem
    }

    private static func initializePlaylist() -> [PlaylistItem] {
        return mockPlaylist
    }
}
