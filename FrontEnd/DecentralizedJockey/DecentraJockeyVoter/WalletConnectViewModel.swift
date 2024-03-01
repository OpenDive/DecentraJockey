//
//  WalletConnectViewModel.swift
//  WalletConnectTest
//
//  Created by Marcus Arnett on 9/18/23.
//

import WalletConnectSign
import WalletConnectModal
import WalletConnectNotify
import SwiftUI
import Combine
import Starscream

struct AccountDetails {
    let chain: String
    let methods: [String]
    let account: String
}

class WalletConnectViewModel: ObservableObject {
    @Published var session: Session? = nil
    @Published var accountDetails: [AccountDetails] = []

    let infuraKey = "f7c4f86c263940ce96b77757f9266602"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let metadata = AppMetadata(
            name: "WalletConnectTest",
            description: "Wallet Connect Test App",
            url: "wallet.connect",
            icons: ["https://avatars.githubusercontent.com/u/37784886"]
        )
        
        Networking.configure(projectId: "2467db657131d94236a5104f687862ca", socketFactory: DefaultSocketFactory())
        WalletConnectModal.configure(projectId: "2467db657131d94236a5104f687862ca", metadata: metadata)
        
        self.addSubscribers()
        
        if let session = Sign.instance.getSessions().first {
            self.session = session
        }
    }
    
//    let permissions = Session.Permissions(blockchains: ["solana:4"], methods: ["solana_signTransaction"], notifications: [])
//            let proposal = Session.Proposal(permissions: permissions)
    
    public func presentWalletConnectModal() {
        print("[PROPOSER] Connecting to a pairing...")
        let namespaces: [String: ProposalNamespace] = [
            "solana": ProposalNamespace(
                chains: [
                    Blockchain("solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ")!
                ],
                methods: [
                    "solana_signMessage",
                    "solana_signTransaction"
                ], 
                events: []
            )
        ]
        let optionalNamespace: [String: ProposalNamespace] = [
            "eip155": ProposalNamespace(
                chains: [Blockchain("eip155:137")!],
                methods: [
                    "eth_sendTransaction",
                    "eth_signTransaction",
                    "personal_sign",
                    "eth_signTypedData",
                    "eth_requestAccounts"
                ],
                events: ["chainChanged", "accountsChanged"]
            )
        ]
        let sessionProperties: [String: String] = [
            "caip154-mandatory": "true"
        ]
        
        Task {
            WalletConnectModal.set(sessionParams: .init(
                requiredNamespaces: namespaces,
                optionalNamespaces: optionalNamespace,
                sessionProperties: sessionProperties
            ))
        }
        WalletConnectModal.present()
    }
    
    private func addSubscribers() {
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (returnedSession) in
                guard let self = self else { return }
                self.session = returnedSession
            }
            .store(in: &cancellables)
    }
}

extension WebSocket: WebSocketConnecting { }

struct DefaultSocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        return WebSocket(url: url)
    }
}
