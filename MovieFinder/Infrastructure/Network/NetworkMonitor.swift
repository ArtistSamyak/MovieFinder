//
//  NetworkMonitor.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//


import Network

protocol NetworkMonitorType {
    func checkInternetConnection() throws
}

final class NetworkMonitor: NetworkMonitorType {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    func checkInternetConnection() throws {
        if !isConnected {
            throw NetworkError.noInternet
        }
    }
}
