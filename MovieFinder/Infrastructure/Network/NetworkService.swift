//
//  NetworkService.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

protocol NetworkServiceType: AnyObject {
    func load<T: Decodable>(_ resource: Endpoint<T>) async throws -> T
    func loadData(_ endpoint: Endpoint<Data>) async throws -> Data
}

final class NetworkService: NetworkServiceType {
    private let session: URLSession
    private let networkMonitor: NetworkMonitorType

    init(session: URLSession = URLSession(configuration: .default),
         networkMonitor: NetworkMonitorType = NetworkMonitor.shared) {
        self.session = session
        self.networkMonitor = networkMonitor
    }

    func load<T: Decodable>(_ endpoint: Endpoint<T>) async throws -> T {
        // Use the injected network monitor.
        try networkMonitor.checkInternetConnection()
        
        // Validate the endpoint to get a proper URLRequest.
        guard let request = endpoint.request else {
            throw NetworkError.invalidRequest
        }
        // Perform the network request.
        let (data, response) = try await session.data(for: request)
        // Ensure that the response is an HTTPURLResponse.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        // Check for a valid HTTP status code.
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.dataLoadingError(statusCode: httpResponse.statusCode, data: data)
        }
        // Decode the JSON data.
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.jsonDecodingError(error: error)
        }
    }

    func loadData(_ endpoint: Endpoint<Data>) async throws -> Data {
        // Use the injected network monitor.
        try networkMonitor.checkInternetConnection()
        guard let request = endpoint.request else {
            throw NetworkError.invalidRequest
        }
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.dataLoadingError(statusCode: httpResponse.statusCode, data: data)
        }
        return data
    }
}
