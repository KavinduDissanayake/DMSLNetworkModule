//
//  NetworkStatusModifier.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//
import SwiftUI

// MARK: - NetworkStatusModifier
struct NetworkStatusModifier: ViewModifier {
    // Using @StateObject to observe the shared NetworkReachability instance
    @StateObject var reachability = NetworkReachability.shared

    func body(content: Content) -> some View {
        content
            .onAppear {
                // Start network monitoring when the view appears
                reachability.startListening()
            }
            .onDisappear {
                // Stop network monitoring when the view disappears
                reachability.stopListening()
            }
    }
}

public extension View {
    func applyNetworkStatus() -> some View {
        self.modifier(NetworkStatusModifier())
    }
}
