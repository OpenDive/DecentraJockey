//
//  DecentraJockeyVoterApp.swift
//  DecentraJockeyVoter
//
//  Created by Marcus Arnett on 2/29/24.
//

import SwiftUI

@main
struct DecentraJockeyVoterApp: App {
    @State var voteViewModel: VoteViewModel = VoteViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(voteViewModel)
        }
    }
}

struct MainView: View {
    @EnvironmentObject var voteViewModel: VoteViewModel
    
    var body: some View {
        Group {
            if voteViewModel.walletAddress == nil {
                ContentView()
            } else {
                NavigationStack {
                    MainVotingView()
                }
            }
        }
    }
}
