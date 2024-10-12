//
//  ConnectivityStatusModifier.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//

import SwiftUI
import Combine

struct ConnectivityStatusModifier: ViewModifier {
    @StateObject var reachability = NetworkReachability.shared
    var onConnected: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: reachability.isConnected) { isConnected in
                if isConnected {
                    // Execute the provided action when the connection is available
                    onConnected()
                }
            }
    }
}

// Extension to apply the modifier easily
public extension View {
    func onConnectivityRestored(perform: @escaping () -> Void) -> some View {
        self.modifier(ConnectivityStatusModifier(onConnected: perform))
    }
}
