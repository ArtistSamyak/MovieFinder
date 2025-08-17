//
//  PosterImagesRepository.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

protocol PosterImagesRepository {
    func fetchImage(
        with imagePath: String,
        size: ImageSize) async throws -> Data
}
