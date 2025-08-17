//
//  MovieDetailsViewModel.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

enum MovieDetailsState {
    case idle
    case loading
    case success(Movie)
    case failure(Error)
}

protocol MovieDetailsViewModelType {
    var delegate: MovieDetailsViewModelDelegate? { get set }
    func getMovieDetails()
}

protocol MovieDetailsViewModelDelegate: AnyObject {
    func didUpdateState(_ state: MovieDetailsState)
}

@MainActor
final class MovieDetailsViewModel: @preconcurrency MovieDetailsViewModelType {
    
    weak var delegate: MovieDetailsViewModelDelegate?
    
    private let movieId: Int
    private let movieDetailsUseCase: MovieDetailsUseCaseType
    
    init(movieId: Int, movieDetailsUseCase: MovieDetailsUseCaseType) {
        self.movieId = movieId
        self.movieDetailsUseCase = movieDetailsUseCase
    }
    
    func getMovieDetails() {
        delegate?.didUpdateState(.loading)
        Task { [weak self] in
            guard let self else { return }
            do {
                let movie = try await movieDetailsUseCase.movieDetails(id: movieId)
                delegate?.didUpdateState(.success(movie))
            } catch {
                delegate?.didUpdateState(.failure(error))
            }
        }
    }
}
