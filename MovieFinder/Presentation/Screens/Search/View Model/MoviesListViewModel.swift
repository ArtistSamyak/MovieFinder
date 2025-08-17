//
//  SearchViewModel.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

enum MoviesListState {
    case idle
    case loading
    case success([Movie])
    case noResults
    case failure(Error)
}

@MainActor
protocol MoviesListViewModelDelegate: AnyObject {
    func didUpdateState(_ state: MoviesListState)
}

@MainActor
protocol MoviesListViewModelType {
    var delegate: MoviesListViewModelDelegate? { get set }
    
    func searchMovies(with name: String)
    func getPopularMovies()
    func getMovieListItemViewModel() -> MovieListItemViewModelType
    func showDetails(forMovie movieId: Int)
}

@MainActor
final class MoviesListViewModel: MoviesListViewModelType {
    
    weak var delegate: MoviesListViewModelDelegate?
    
    private let searchMoviesUseCase: SearchMoviesUseCaseType
    private let navigator: MovieSearchNavigator
    
    // Hold a reference to the current search task to cancel if needed
    private var searchTask: Task<Void, Never>?
    
    init(searchMoviesUseCase: SearchMoviesUseCaseType, navigator: MovieSearchNavigator) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.navigator = navigator
    }
    
    func searchMovies(with name: String) {
        // Cancel any ongoing search task
        searchTask?.cancel()
        
        // If the search string is empty, update state to idle
        guard !name.isEmpty else {
            delegate?.didUpdateState(.idle)
            return
        }
        
        // Immediately update UI state to loading
        delegate?.didUpdateState(.loading)
        
        // Create a new task for the search operation, ensuring UI updates on the main actor.
        searchTask = Task { [unowned self] in
            // Debounce: wait for 0.5 seconds
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                // If the task is cancelled during sleep, exit early
                return
            }
            
            if Task.isCancelled { return }
            
            do {
                let movies = try await self.searchMoviesUseCase.searchMovies(name: name)
                // Ensure UI updates happen on the main actor
                await MainActor.run {
                    if movies.isEmpty {
                        self.delegate?.didUpdateState(.noResults)
                    } else {
                        self.delegate?.didUpdateState(.success(movies))
                    }
                }
            } catch {
                // For network errors, update UI state accordingly.
                await MainActor.run {
                    if let networkError = error as? NetworkError {
                        self.delegate?.didUpdateState(.failure(networkError))
                    }
                }
            }
        }
    }
    
    func getPopularMovies() {
        delegate?.didUpdateState(.loading)
        
        Task { [unowned self] in
            do {
                let popularMovies = try await self.searchMoviesUseCase.getPopularMovies()
                await MainActor.run {
                    self.delegate?.didUpdateState(.success(popularMovies))
                }
            } catch {
                await MainActor.run {
                    self.delegate?.didUpdateState(.failure(error))
                }
            }
        }
    }
    
    func getMovieListItemViewModel() -> MovieListItemViewModelType {
        MovieListItemViewModel(searchMoviesUseCase: searchMoviesUseCase)
    }
    
    func showDetails(forMovie movieId: Int) {
        navigator.showDetails(forMovie: movieId)
    }
}
