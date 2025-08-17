//
//  MovieSearchNavigator.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

@MainActor
protocol MovieSearchNavigator: AnyObject {
    // Presents the movies details screen
    func showDetails(forMovie movieId: Int)
}
