//
//  DecentralizedJockeyApp.swift
//  DecentralizedJockey
//
//  Created by Marcus Arnett on 2/27/24.
//

import SwiftUI

@main
struct DecentralizedJockeyApp: App {
    @StateObject var djViewModel: DJViewModel = DJViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(djViewModel)
            }
        }
        .defaultSize(CGSize(width: 640, height: 480))
        
        WindowGroup("Currently Playing", id: "currently-playing") {
            CurrentPlayingSongView()
                .environmentObject(djViewModel)
        }
        .defaultSize(CGSize(width: 400, height: 600))
        
        WindowGroup("Current Votes", id: "current-votes") {
            MainVotingView()
                .environmentObject(djViewModel)
        }
        .defaultSize(CGSize(width: 640, height: 480))
    }
}
