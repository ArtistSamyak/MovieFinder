//
//  CoreDataMovieCacheRepository.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import CoreData

final class CoreDataMoviesCacheRepository {
    private let context: NSManagedObjectContext
    private let maxCacheSize: Int
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext, maxCacheSize: Int = 10) {
        self.context = context
        self.maxCacheSize = maxCacheSize
    }
}

extension CoreDataMoviesCacheRepository: MoviesCacheRepository {
    
    func getCachedMovies() async throws -> [Movie] {
        try await context.perform {
            let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertionDate", ascending: false)]
            let cdMovies = try self.context.fetch(fetchRequest)
            return cdMovies.map { $0.toMovie() }
        }
    }
    
    func getMovie(id: Int) async throws -> Movie? {
        try await context.perform {
            let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", Int64(id))
            fetchRequest.fetchLimit = 1
            let cdMovies = try self.context.fetch(fetchRequest)
            return cdMovies.first?.toMovie()
        }
    }
    
    func getMoviePosterData(path: String) async throws -> Data? {
        try await context.perform {
            let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "posterPath == %@", path)
            fetchRequest.fetchLimit = 1
            let cdMovies = try self.context.fetch(fetchRequest)
            return cdMovies.first?.posterData
        }
    }
    
    func save(movie: Movie) async throws {
        try await context.perform {
            // Fetch existing movies sorted by insertionDate (newest first)
            let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertionDate", ascending: false)]
            let movies = try self.context.fetch(fetchRequest)
            
            // Avoid duplicating movies: check if the movie already exists in the cache.
            if movies.contains(where: { $0.id == Int64(movie.id) }) {
                return
            }
            
            // If the cache is full, remove the oldest movie (last in the sorted list)
            if movies.count >= self.maxCacheSize, let oldestMovie = movies.last {
                self.context.delete(oldestMovie)
            }
            
            // Create and configure a new CDMovie instance based on the provided movie model.
            _ = CDMovie(from: movie, in: self.context)
            try self.context.save()
        }
    }
}
