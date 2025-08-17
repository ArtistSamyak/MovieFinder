//
//  SceneDelegate.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // Create your dependency provider (factory).
        let dependencyProvider = ApplicationComponentsFactory()
        
        // Create and start the flow coordinator.
        let searchFlowCoordinator = MoviesSearchFlowCoordinator(window: window, dependencyProvider: dependencyProvider)
        searchFlowCoordinator.start()
        
        window.makeKeyAndVisible()
        self.window = window
    }
}

