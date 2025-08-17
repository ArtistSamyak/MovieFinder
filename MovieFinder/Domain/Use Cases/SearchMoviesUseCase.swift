//
//  SearchMoviesUseCase.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

protocol SearchMoviesUseCaseType {
    func searchMovies(name: String) async throws -> [Movie]
    func getPopularMovies() async throws -> [Movie]
    func getSavedMovies() async throws -> [Movie]
    func getPosterImage(path: String) async throws -> Data
}

final class SearchMoviesUseCase: SearchMoviesUseCaseType {
    
    private let searchMoviesRepository: SearchMoviesRepoitory
    private let movieCacheRepository: MoviesCacheRepository
    private let posterImagesRepository: PosterImagesRepository
    
    init(searchMoviesRepository: SearchMoviesRepoitory,
         movieCacheRepository: MoviesCacheRepository,
         posterImagesRepository: PosterImagesRepository) {
        self.searchMoviesRepository = searchMoviesRepository
        self.movieCacheRepository = movieCacheRepository
        self.posterImagesRepository = posterImagesRepository
    }
    
    func searchMovies(name: String) async throws -> [Movie] {
        do {
            return try await searchMoviesRepository.fetchMovies(name: name)
        } catch {
            // Fallback to cached movies if the network call fails.
            let cachedMovies = try await movieCacheRepository.getCachedMovies()
            let filteredMovies = cachedMovies.filter { $0.title.lowercased().contains(name.lowercased()) }
            if filteredMovies.isEmpty {
                throw error
            } else {
                return filteredMovies
            }
        }
    }
    
    func getPopularMovies() async throws -> [Movie] {
        do {
            return try await searchMoviesRepository.fetchPopularMovies()
        } catch {
            // Fallback to cached movies if the network call fails.
            let cachedMovies = try await movieCacheRepository.getCachedMovies()
            if cachedMovies.isEmpty {
                throw error
            } else {
                return cachedMovies
            }
        }
    }

    func getSavedMovies() async throws -> [Movie] {
        return try await movieCacheRepository.getCachedMovies()
    }
    
    func getPosterImage(path: String) async throws -> Data {
        if let imageData = try await movieCacheRepository.getMoviePosterData(path: path) {
            return imageData
        }
        return try await posterImagesRepository.fetchImage(with: path, size: .small)
    }
}
