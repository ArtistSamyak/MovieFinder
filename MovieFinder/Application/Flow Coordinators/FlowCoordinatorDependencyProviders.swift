//
//  FlowCoordinatorDependencyProviders.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

@MainActor
protocol ApplicationFlowCoordinatorDependencyProvider: MoviesSearchFlowCoordinatorDependencyProvider {}

@MainActor
protocol MoviesSearchFlowCoordinatorDependencyProvider: AnyObject {
    // Creates UIViewController to search for a movie
    func moviesSearchNavigationController(navigator: MovieSearchNavigator) -> UINavigationController

    // Creates UIViewController to show the details of the movie with specified identifier
    func movieDetailsController(_ movieId: Int) -> UIViewController
}
