//
//  NetworkReachability.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//
import Alamofire
import SwiftUI

final public class NetworkReachability: ObservableObject {
    
    public  static let shared = NetworkReachability()
    
    private let reachability = NetworkReachabilityManager(host: "www.apple.com")!
    
    // Observable properties
    @Published public var isConnected: Bool = true
    @Published var isConnectedViaWiFi: Bool = false
    @Published var isConnectedViaCellular: Bool = false
    
    private init() {
        startListening()
    }
    
    /// Start observing reachability changes
    func startListening() {
        reachability.startListening { [weak self] status in
            self?.updateReachabilityStatus(status)
        }
    }
    
    /// Stop observing reachability changes
    func stopListening() {
        reachability.stopListening()
    }
    
    /// Update status based on connectivity
    private func updateReachabilityStatus(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch status {
        case .notReachable:
            DispatchQueue.main.async {
                self.isConnected = false
                self.isConnectedViaWiFi = false
                self.isConnectedViaCellular = false
            }
        case .reachable(let connection):
            DispatchQueue.main.async {
                self.isConnected = true
                switch connection {
                case .ethernetOrWiFi:
                    self.isConnectedViaWiFi = true
                    self.isConnectedViaCellular = false
                case .cellular:
                    self.isConnectedViaCellular = true
                    self.isConnectedViaWiFi = false
                @unknown default:
                    break
                }
                
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    /// returns if the current network status is reachable
    var isReachable: Bool {
        return reachability.isReachable
    }
     
     var isNotReachable: Bool {
         return !reachability.isReachable
     }
    
    deinit {
        stopListening()
    }
}
