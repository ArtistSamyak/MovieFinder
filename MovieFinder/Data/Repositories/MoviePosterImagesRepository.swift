//
//  MoviePosterImagesRepository.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

final class MoviePosterImagesRepository {
    private let networkService: NetworkServiceType
    
    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }
}

extension MoviePosterImagesRepository: PosterImagesRepository {
    
    func fetchImage(with imagePath: String, size: ImageSize) async throws -> Data {
        do {
            return try await networkService.loadData(APIEndpoints.images(path: imagePath, size: size))
        } catch {
            throw error
        }
    }
}
