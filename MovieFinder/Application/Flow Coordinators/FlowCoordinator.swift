//
//  FlowCoordinator.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

// A simple FlowCoordinator protocol that starts a flow.
@MainActor
protocol FlowCoordinator: AnyObject {
    func start()
}
