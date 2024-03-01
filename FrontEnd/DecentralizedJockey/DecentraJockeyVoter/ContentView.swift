//
//  ContentView.swift
//  DecentraJockeyVoter
//
//  Created by Marcus Arnett on 2/29/24.
//

import SwiftUI
import WalletConnectModal

struct ContentView: View {
    @ObservedObject var viewModel: WalletConnectViewModel = WalletConnectViewModel()
    
    var body: some View {
        VStack {
            Text("Sign In")
                .font(.title)
                .bold()
            
            Button {
                self.viewModel.presentWalletConnectModal()
            } label: {
                Image("wallet-connect-logo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .background(Color(uiColor: UIColor.systemGray3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
        }
        .padding()
        .frame(width: 250)
    }
}

#Preview {
    ContentView()
}
