//
//  MovieListItemViewModel.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import Foundation

protocol MovieListItemViewModelType: AnyObject {
    func fetchImage(_ path: String) async throws -> Data
    func cancelImageDownload()
}

final class MovieListItemViewModel: MovieListItemViewModelType {
    
    private let searchMoviesUseCase: SearchMoviesUseCaseType
    private var imageDownloadTask: Task<Data, Error>?
    private let lock = NSLock()
    
    init(searchMoviesUseCase: SearchMoviesUseCaseType) {
        self.searchMoviesUseCase = searchMoviesUseCase
    }
    
    func fetchImage(_ path: String) async throws -> Data {
        // Cancel any ongoing image download.
        cancelImageDownload()
        
        let task = Task {
            try await searchMoviesUseCase.getPosterImage(path: path)
        }
        
        lock.withLock {
            imageDownloadTask = task
        }
        
        defer {
            // Clear the task reference when the download completes.
            lock.withLock {
                imageDownloadTask = nil
            }
        }
        
        // Await the image data and propagate errors naturally.
        return try await task.value
    }
    
    func cancelImageDownload() {
        lock.withLock {
            imageDownloadTask?.cancel()
            imageDownloadTask = nil
        }
    }
    
    deinit {
        cancelImageDownload()
    }
}

extension NSLock {
    /// Executes the provided closure while holding the lock.
    func withLock<T>(_ block: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}
