//
//  ContentView.swift
//  DecentralizedJockey
//
//  Created by Marcus Arnett on 2/27/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

//struct ContentView: View {
//
//    @State var enlarge = false
//
//    var body: some View {
//        VStack {
//            RealityView { content in
//                // Add the initial RealityKit content
//                if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
//                    content.add(scene)
//                }
//            } update: { content in
//                // Update the RealityKit content when SwiftUI state changes
//                if let scene = content.entities.first {
//                    let uniformScale: Float = enlarge ? 1.4 : 1.0
//                    scene.transform.scale = [uniformScale, uniformScale, uniformScale]
//                }
//            }
//            .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
//                enlarge.toggle()
//            })
//
//            VStack {
//                Toggle("Enlarge RealityView Content", isOn: $enlarge)
//                    .toggleStyle(.button)
//            }.padding().glassBackgroundEffect()
//        }
//    }
//}

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject var djViewModel: DJViewModel
    
    var body: some View {
        List {
            ForEach(djViewModel.playlists) { idx in
                NavigationLink {
                    DetailedPlaylistView(
                        playlistItem: idx
                    )
                    .environmentObject(djViewModel)
                } label: {
                    PlaylistItemView(
                        playlistItem: idx
                    )
                }

            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openWindow(id: "currently-playing")
                } label: {
                    Image(systemName: "opticaldisc.fill")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openWindow(id: "current-votes")
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Playlists")
    }
}

struct DetailedPlaylistView: View {
    @State private var isPlaying: Bool = false

    var playlistItem: PlaylistItem

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(playlistItem.albumCover)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 190, height: 190)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(playlistItem.playlistTitle)
                            .font(.system(size: 36))
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                        
                        Text("\(playlistItem.playlist.count) Songs")
                            .font(.system(size: 24))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(playlistItem.playlistDescription)
                            .font(.system(size: 20))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    .padding(.leading, 36)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                .padding(.leading, 28)
                
                List {
                    ForEach(playlistItem.playlist) { idx in
                        SongItemView(song: idx)
                    }
                }
                .navigationTitle("Song List")
            }
            .ornament(
                visibility: .visible,
                attachmentAnchor: .scene(.bottom)
            ) {
                PlaylistModifierOrnamentView(currentPlaylist: playlistItem)
            }
        }
    }
}

struct PlaylistModifierOrnamentView: View {
    var currentPlaylist: PlaylistItem
    @EnvironmentObject var djViewModel: DJViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 17) {
                Button {
                    self.djViewModel.addPlaylistToUpcoming(playlist: currentPlaylist)
                } label: {
                    Label("Next", systemImage: "plus")
                        .bold()
                        .help("Add Next")
                }
                
                Button {
                    self.djViewModel.addPlaylistToQueue(playlist: currentPlaylist)
                } label: {
                    Label("Upcoming", systemImage: "rectangle.grid.1x2")
                        .bold()
                        .help("Add Upcoming")
                }
                
                Button {
                    self.djViewModel.overridePlaylist(playlist: currentPlaylist)
                } label: {
                    Label("Play", systemImage: "play.fill")
                        .help("Start Playlist")
                }
            }
        }
    }
}

struct PlaylistControlOrnamentView: View {
    @EnvironmentObject var djViewModel: DJViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 17) {
                Button {
                    self.djViewModel.previousSong()
                } label: {
                    Label("Previous", systemImage: "backward.fill")
                        .help("Previous Track")
                }
                
                Toggle(isOn: $djViewModel.isPlaying) {
                    if djViewModel.isPlaying {
                        Label("Pause", systemImage: "pause")
                            .help("Pause Music")
                    } else {
                        Label("Play", systemImage: "play.fill")
                            .help("Play Music")
                    }
                }
                
                Button {
                    self.djViewModel.nextSong()
                } label: {
                    Label("Next", systemImage: "forward.fill")
                        .help("Next Track")
                }
            }
            .toggleStyle(.button)
            .buttonStyle(.borderless)
            .labelStyle(.iconOnly)
            .padding(12)
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))
        }
        .onChange(of: djViewModel.isPlaying) { oldValue, newValue in
            if newValue {
                if djViewModel.currentSong == nil {
                    djViewModel.isPlaying = false
                }
            }
        }
    }
}

struct SongItemView: View {
    var song: SongItem
    
    var body: some View {
        HStack {
            Image(song.albumCover)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 4.0))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(song.songTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            Text(song.duration.getTimecode())
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct PlaylistItemView: View {
    var playlistItem: PlaylistItem
    
    var body: some View {
        HStack {
            Image(playlistItem.albumCover)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(playlistItem.playlistTitle)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text("\(playlistItem.playlist.count) Songs")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 16)
            
            Spacer()
        }
    }
}

struct CurrentPlayingSongView: View {
    @EnvironmentObject var djViewModel: DJViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("0")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
                    .reverseMask {
                        Circle()
                            .frame(width: 50, height: 50)
                    }
                    .rotationEffect(Angle.degrees(djViewModel.isPlaying ? 360 : 0))
                    .animation(.linear(duration: djViewModel.isPlaying ? 10 : 0).repeatForever(autoreverses: false), value: djViewModel.isPlaying)
                    .padding(.bottom, 30)
                
                Text(
                    djViewModel.currentSong != nil ?
                    djViewModel.currentSong!.songTitle :
                    "Not Playing"
                )
                    .fontWeight(.semibold)
                    .font(.system(size: 40))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(
                    djViewModel.currentSong != nil ?
                    djViewModel.currentSong!.artist :
                    "Unknown"
                )
                    .font(.system(size: 26))
                    .foregroundStyle(.secondary)

                if let currentSong = djViewModel.currentSong {
                    Slider(value: $djViewModel.currentTimestamp, in: 0...currentSong.duration.totalSeconds()) {
                            Text(SongTimestamp(seconds: Int(djViewModel.currentTimestamp)).getTimecode())
                        } onEditingChanged: { editing in
                            // Implement what should happen when the value changes
                            // For example, seek to the new time in the song
                            if editing {
                                // User started dragging
                            } else {
                                // User ended dragging
                            }
                        }
                        .frame(width: 300, height: 20)
                        .tint(.white)
                        .padding()
                }
            }
            .onReceive(djViewModel.timer) { time in
                if let currentSong = djViewModel.currentSong {
                    if djViewModel.isPlaying && djViewModel.currentTimestamp < currentSong.duration.totalSeconds() {
                        djViewModel.currentTimestamp += 1
                    }
                }
            }
            .ornament(
                visibility: .visible,
                attachmentAnchor: .scene(.bottom)
            ) {
                PlaylistControlOrnamentView()
            }
        }
    }
}

struct MainVotingView: View {
    @EnvironmentObject var djViewModel: DJViewModel
    
    var body: some View {
        HStack {
            if let vote = djViewModel.vote {
                NavigationStack {
                    List {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .frame(width: 60, height: 60, alignment: .trailing)

                            VotingItemView(songVoteItem: vote.contenders[0], votes: $djViewModel.vote)
                        }
                        
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .frame(width: 60, height: 60, alignment: .trailing)

                            VotingItemView(songVoteItem: vote.contenders[1], votes: $djViewModel.vote)
                        }
                        
                        HStack {
                            Image(systemName: "3.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .frame(width: 60, height: 60, alignment: .trailing)

                            VotingItemView(songVoteItem: vote.contenders[2], votes: $djViewModel.vote)
                        }
                    }
                    .scrollDisabled(true)
                    .padding(.horizontal, 20)
                    .navigationTitle("Total Votes - \(Int(vote.totalVotes))")
                    .padding(.top)
                }
            } else {
                Text("No Voting Running")
                    .bold()
            }
        }
        .ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.bottom)
        ) {
            HStack(spacing: 17) {
                Button {
                    self.djViewModel.initializeVote()
                } label: {
                    Label("Start", systemImage: "hand.raised")
                        .help("Start Poll")
                }
            }
            .toggleStyle(.button)
            .buttonStyle(.borderless)
            .labelStyle(.iconOnly)
            .padding(12)
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))
        }
    }
}

struct VotingItemView: View {
    var songVoteItem: SongVoteItem
    @Binding var votes: VoteItem?
    
    var body: some View {
        HStack {
            Image("0")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                .padding(.leading)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(songVoteItem.song.songTitle)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text("\(Int(songVoteItem.amount)) Votes")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            ProgressView(
                value: songVoteItem.amount,
                total: votes!.totalVotes
            )
            .frame(width: 300)
            .scaleEffect(x: 1, y: 4, anchor: .center)
            .progressViewStyle(LinearProgressViewStyle())
            .tint(.white)
            .padding(.trailing)
        }
        .padding(.vertical)
    }
}

extension View {
  @inlinable
  public func reverseMask<Mask: View>(
    alignment: Alignment = .center,
    @ViewBuilder _ mask: () -> Mask
  ) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
  }
}

struct PlaylistPreview: View {
    @StateObject var djViewModel: DJViewModel = DJViewModel()
    
    var body: some View {
        ContentView()
            .environmentObject(djViewModel)
    }
}

struct CurrentPlayingPreview: View {
    @StateObject var djViewModel: DJViewModel = DJViewModel()
    
    var body: some View {
        CurrentPlayingSongView()
            .environmentObject(djViewModel)
    }
}

struct MainVotingPreview: View {
    @StateObject var djViewModel: DJViewModel = DJViewModel()
    
    var body: some View {
        MainVotingView()
            .environmentObject(djViewModel)
    }
}

#Preview(windowStyle: .automatic) {
//    NavigationStack {
//        PlaylistPreview()
//    }
//    CurrentPlayingPreview()
    MainVotingPreview()
}
