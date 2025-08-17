//
//  SearchMoviesRepoitory.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

protocol SearchMoviesRepoitory {
    func fetchMovies(name: String) async throws -> [Movie]
    func fetchPopularMovies() async throws -> [Movie]
    func fetchMovieDetails(id: Int) async throws -> Movie
}
