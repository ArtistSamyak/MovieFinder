//
//  NetworkError.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

// Defines the Network service errors.
enum NetworkError: LocalizedError, Equatable {
    case invalidRequest
    case invalidResponse
    case noInternet
    case requestTimedOut
    case dataLoadingError(statusCode: Int, data: Data)
    case jsonDecodingError(error: Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "The request is invalid. Please try again."
        case .invalidResponse:
            return "Received an invalid response from the server. Please try again."
        case .noInternet:
            return "No internet connection. Please check your network and try again."
        case .requestTimedOut:
            return "The request timed out. Please try again."
        case .dataLoadingError(let statusCode, _):
            return "Failed to load data (Status Code: \(statusCode)). Please check your internet connection and try again."
        case .jsonDecodingError(let error):
            return "Failed to decode the response. \(error.localizedDescription)"
        case .unknown(let error):
            return "An unknown network error occurred: \(error.localizedDescription)"
        }
    }
    
    // Conformance for Equatable so tests can compare errors.
    static func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRequest, .invalidRequest):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.noInternet, .noInternet):
            return true
        case (.requestTimedOut, .requestTimedOut):
            return true
        case (.dataLoadingError(let lStatus, _), .dataLoadingError(let rStatus, _)):
            return lStatus == rStatus
        case (.jsonDecodingError, .jsonDecodingError):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
