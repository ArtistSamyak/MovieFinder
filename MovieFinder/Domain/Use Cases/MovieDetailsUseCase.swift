//
//  MovieDetailsUseCase.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

protocol MovieDetailsUseCaseType {
    func movieDetails(id: Int) async throws -> Movie
}

final class MovieDetailsUseCase: MovieDetailsUseCaseType {
    
    private let searchMoviesRepository: SearchMoviesRepoitory
    private let movieCacheRepository: MoviesCacheRepository
    private let posterImagesRepository: PosterImagesRepository
    
    init(searchMoviesRepository: SearchMoviesRepoitory,
         movieCacheRepository: MoviesCacheRepository,
         posterImagesRepository: PosterImagesRepository) {
        self.searchMoviesRepository = searchMoviesRepository
        self.movieCacheRepository = movieCacheRepository
        self.posterImagesRepository = posterImagesRepository
    }
    
    func movieDetails(id: Int) async throws -> Movie {
        // Try to retrieve the movie directly by id from the cache.
        if let cachedMovie = try await movieCacheRepository.getMovie(id: id) {
            return cachedMovie
        }

        // Fetch movie details if not found in cache.
        var movie = try await searchMoviesRepository.fetchMovieDetails(id: id)
        
        // If a poster path exists, fetch the poster image data.
        if let posterPath = movie.poster {
            let posterImageData = try await posterImagesRepository.fetchImage(with: posterPath, size: .original)
            movie.posterImageData = posterImageData
        }
        
        // Save the fetched (and updated) movie in the cache.
        try await movieCacheRepository.save(movie: movie)
        
        return movie
    }
}
