//
//  TMDbSearchMoviesRepository.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

final class TMDbSearchMoviesRepository {

    private let networkService: NetworkServiceType
    
    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }
}

extension TMDbSearchMoviesRepository: SearchMoviesRepoitory {

    func fetchMovies(name: String) async throws -> [Movie] {
        do {
            let movieList = try await networkService.load(APIEndpoints.movies(query: name))
            return movieList.results
        } catch {
            throw error
        }
    }
    
    func fetchPopularMovies() async throws -> [Movie] {
        do {
            let movieList = try await networkService.load(APIEndpoints.popularMovies())
            return movieList.results
        } catch {
            throw error
        }
    }
    
    func fetchMovieDetails(id: Int) async throws -> Movie {
        do {
            return try await networkService.load(APIEndpoints.details(movieId: id))
        } catch {
            throw error
        }
    }
}
