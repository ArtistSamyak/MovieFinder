//
//  MoviesSearchFlowCoordinator.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

// The flow coordinator for the movies search flow.
@MainActor
class MoviesSearchFlowCoordinator: FlowCoordinator {
    private let window: UIWindow
    private let dependencyProvider: MoviesSearchFlowCoordinatorDependencyProvider
    private var navigationController: UINavigationController?
    
    init(window: UIWindow, dependencyProvider: MoviesSearchFlowCoordinatorDependencyProvider) {
        self.window = window
        self.dependencyProvider = dependencyProvider
    }
    
    func start() {
        // Create the initial navigation controller via the dependency provider.
        let navController = dependencyProvider.moviesSearchNavigationController(navigator: self)
        window.rootViewController = navController
        navigationController = navController
    }
}

extension MoviesSearchFlowCoordinator: MovieSearchNavigator {
    func showDetails(forMovie movieId: Int) {
        let detailsVC = dependencyProvider.movieDetailsController(movieId)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
