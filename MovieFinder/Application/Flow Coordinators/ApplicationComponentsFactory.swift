//
//  ApplicationComponentsFactory.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

// The dependency provider that creates and holds shared dependencies.
final class ApplicationComponentsFactory {
    
    let sharedNetworkService = NetworkService()
    
    lazy var sharedSearchMoviesRepository: SearchMoviesRepoitory = {
        return TMDbSearchMoviesRepository(networkService: sharedNetworkService)
    }()
    
    lazy var sharedMoviesCacheRepository: MoviesCacheRepository = {
        return CoreDataMoviesCacheRepository()
    }()
    
    lazy var sharedPosterImagesRepository: PosterImagesRepository = {
        return MoviePosterImagesRepository(networkService: sharedNetworkService)
    }()
    
    lazy var searchMoviesUseCase: SearchMoviesUseCaseType = {
        return SearchMoviesUseCase(
            searchMoviesRepository: sharedSearchMoviesRepository,
            movieCacheRepository: sharedMoviesCacheRepository,
            posterImagesRepository: sharedPosterImagesRepository
        )
    }()
    
    lazy var movieDetailsUseCase: MovieDetailsUseCaseType = {
        return MovieDetailsUseCase(
            searchMoviesRepository: sharedSearchMoviesRepository,
            movieCacheRepository: sharedMoviesCacheRepository,
            posterImagesRepository: sharedPosterImagesRepository
        )
    }()
}

extension ApplicationComponentsFactory: ApplicationFlowCoordinatorDependencyProvider {
    
    // Creates the navigation controller for the movies search flow.
    func moviesSearchNavigationController(navigator: MovieSearchNavigator) -> UINavigationController {
        let viewModel = MoviesListViewModel(searchMoviesUseCase: searchMoviesUseCase, navigator: navigator)
        let moviesSearchVC = MoviesListViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: moviesSearchVC)
    }
    
    // Creates the details view controller.
    func movieDetailsController(_ movieId: Int) -> UIViewController {
        let viewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsUseCase: movieDetailsUseCase)
        return MovieDetailsViewController(viewModel: viewModel)
    }
}
