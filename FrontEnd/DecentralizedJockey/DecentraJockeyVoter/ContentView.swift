//
//  ContentView.swift
//  DecentraJockeyVoter
//
//  Created by Marcus Arnett on 2/29/24.
//

import SwiftUI
import WalletConnectModal
import Base58Swift
import TweetNacl
import SwiftyJSON

typealias x25519Keypair = (publicKey: Data, secretKey: Data)

struct VotingItemView: View {
    @EnvironmentObject var voteViewModel: VoteViewModel
    
    var song: SongVoteItem
    var totalVotes: Double
    
    var body: some View {
        HStack {
            Image("0")
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 85)
                .clipShape(RoundedRectangle(cornerRadius: 4.0))

            VStack(alignment: .leading, spacing: 5) {
                Text(song.song.songTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(voteViewModel.hasVoted! ? "\(Int(song.amount)) Votes" : song.song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 14)
        }
    }
}

struct MainVotingView: View {
    @EnvironmentObject var voteViewModel: VoteViewModel
    
    var body: some View {
        List {
            if voteViewModel.hasVoted != nil {
                if voteViewModel.hasVoted! {
                    ForEach(voteViewModel.vote!.contenders) { vote in
                        VotingItemView(song: vote, totalVotes: voteViewModel.vote!.totalVotes)
                    }
                } else {
                    ForEach(voteViewModel.vote!.contenders) { vote in
                        Button {
                            self.voteViewModel.hasVoted = true
                        } label: {
                            VotingItemView(song: vote, totalVotes: voteViewModel.vote!.totalVotes)
                        }
                        .tint(Color("TextColor"))
                    }
                }
            } else {
                Text("Voting hasn't begun yet!")
                    .bold()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Text(voteViewModel.walletAddress!.shortenToFirstThreeAndLastThree())
                    .bold()
                    .padding()
                    .background(Color(uiColor: UIColor.systemGray3))
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
            }
        }
        .scrollDisabled(true)
        .navigationTitle("Vote Below!")
    }
}

struct ContentView: View {
    @EnvironmentObject var voteViewModel: VoteViewModel

    var body: some View {
        VStack {
            Text("Sign In")
                .font(.title)
                .bold()
            
            Button {
                UIApplication
                    .shared
                    .open(URL(string: "https://phantom.app/ul/v1/connect?app_url=https%3A%2F%2Fphantom.app&dapp_encryption_public_key=\(Base58.base58Encode([UInt8](self.voteViewModel.keypair!.publicKey)))&redirect_link=djvote%3A%2F%2FonConnect")!)
            } label: {
                Image("phantom-logo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .background(Color(uiColor: UIColor.systemGray3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
        }
        .onAppear {
            do {
                let keypair = try NaclBox.keyPair()
                self.voteViewModel.keypair = keypair
            } catch {
                print(error)
            }
        }
        .padding()
        .frame(width: 250)
        .onOpenURL { incomingURL in
            handleIncomingURLConnect(incomingURL)
        }
    }

    /// Handles the incoming URL and performs validations before acknowledging.
    private func handleIncomingURLConnect(_ url: URL) {
        guard url.scheme == "djvote" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        guard let action = components.host, action == "onConnect" else {
            print("Unknown URL, we can't handle this one!")
            return
        }
        
        guard let phantomPublicKey = components.queryItems?.first(where: { $0.name == "phantom_encryption_public_key" })?.value else {
            print("Phantom PK not found")
            return
        }
        
        guard let nonce = components.queryItems?.first(where: { $0.name == "nonce" })?.value else {
            print("Nonce not found")
            return
        }
        
        guard let encryptedData = components.queryItems?.first(where: { $0.name == "data" })?.value else {
            print("Data not found")
            return
        }
        
        let decodedData = Base58.base58Decode(encryptedData)
        let decodedNonce = Base58.base58Decode(nonce)
        let decodedPhantomPublicKey = Base58.base58Decode(phantomPublicKey)

        let result = try! NaclBox.open(
            message: Data(decodedData!),
            nonce: Data(decodedNonce!),
            publicKey: Data(decodedPhantomPublicKey!),
            secretKey: self.voteViewModel.keypair!.secretKey
        )
        
        self.voteViewModel.initializeVote()
        self.voteViewModel.hasVoted = false
        self.voteViewModel.walletAddress = JSON(result)["public_key"].stringValue
    }
}

struct PreviewContentView: View {
    @StateObject var voteViewModel: VoteViewModel = VoteViewModel()
    
    var body: some View {
        ContentView()
            .environmentObject(voteViewModel)
    }
}

struct PreviewMainVotingView: View {
    @StateObject var voteViewModel: VoteViewModel = VoteViewModel()
    
    var body: some View {
        NavigationStack {
            MainVotingView()
                .environmentObject(voteViewModel)
        }
    }
}

extension String {
    func shortenToFirstThreeAndLastThree() -> String {
        // Check if the string needs to be shortened
        if self.count <= 6 {
            return self
        }
        
        let firstThree = self.prefix(3)
        let lastThree = self.suffix(3)
        
        return "\(firstThree)...\(lastThree)"
    }
}

#Preview {
    PreviewContentView()
//    PreviewMainVotingView()
//    VotingItemView(song: mockVoteItem.contenders[0], totalVotes: mockVoteItem.totalVotes)
}
