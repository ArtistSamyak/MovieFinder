//
//  APIEndpoints.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

struct APIEndpoints {
    
    struct Constants {
        static let apiKey = "REPLACE_WITH_YOUR_TMDB_API_KEY"
        static let baseUrl = URL(string: "https://api.themoviedb.org/3")!
        static let originalImageUrl = URL(string: "https://image.tmdb.org/t/p/original")!
        static let smallImageUrl = URL(string: "https://image.tmdb.org/t/p/w342")!
    }
    
    static func movies(query: String) -> Endpoint<MovieList> {
        let url = Constants.baseUrl.appendingPathComponent("/search/movie")
        let parameters: [String : CustomStringConvertible] = [
            "api_key": Constants.apiKey,
            "query": query,
            "language": Locale.preferredLanguages[0]
            ]
        return Endpoint<MovieList>(url: url, parameters: parameters)
    }
    
    static func popularMovies() -> Endpoint<MovieList> {
        let url = Constants.baseUrl.appendingPathComponent("/movie/popular")
        let parameters: [String : CustomStringConvertible] = [
            "api_key": Constants.apiKey,
            "language": Locale.preferredLanguages[0]
            ]
        return Endpoint<MovieList>(url: url, parameters: parameters)
    }
    
    static func details(movieId: Int) -> Endpoint<Movie> {
        let url = Constants.baseUrl.appendingPathComponent("/movie/\(movieId)")
        let parameters: [String : CustomStringConvertible] = [
            "api_key": Constants.apiKey,
            "language": Locale.preferredLanguages[0]
            ]
        return Endpoint<Movie>(url: url, parameters: parameters)
    }
    
    static func images(path: String, size: ImageSize) -> Endpoint<Data> {
        let baseURL = size == .original
            ? Constants.originalImageUrl
            : Constants.smallImageUrl
        let url = baseURL.appendingPathComponent(path)
        return Endpoint<Data>(url: url)
    }
}
