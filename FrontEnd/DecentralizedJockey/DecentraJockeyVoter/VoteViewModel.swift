//
//  VoteViewModel.swift
//  DecentraJockeyVoter
//
//  Created by Marcus Arnett on 3/1/24.
//

import SwiftUI

class VoteViewModel: ObservableObject {
    @Published var walletAddress: String? = nil
    @Published var votedItem: SongVoteItem? = nil
    @Published var keypair: x25519Keypair? = nil
    @Published var vote: VoteItem? = nil
    @Published var hasVoted: Bool? = nil
    
//    init() {
//        self.vote = mockVoteItem
//        self.walletAddress = "000000000000000000000"
//        self.hasVoted = false
//    }

    public func initializeVote() {
        self.vote = mockVoteItem
    }
}
