//
//  MoviesCacheRepository.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

protocol MoviesCacheRepository {
    func getCachedMovies() async throws -> [Movie]
    func getMovie(id: Int) async throws -> Movie?
    func getMoviePosterData(path: String) async throws -> Data?
    func save(movie: Movie) async throws -> Void
}
