//
//  MovieDetailsUseCaseTests.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//


import XCTest
@testable import MovieFinder

final class MovieDetailsUseCaseTests: XCTestCase {
    
    // MARK: - Mocks
    
    class MockSearchMoviesRepository: SearchMoviesRepoitory {
        
        var fetchMovieDetailsHandler: ((Int) async throws -> Movie)?
        var fetchMoviesHandler: ((String) async throws -> [Movie])?
        var fetchPopularMoviesHandler: (() async throws -> [Movie])?
        
        func fetchMovies(name: String) async throws -> [Movie] {
            if let handler = fetchMoviesHandler {
                return try await handler(name)
            }
            return []
        }
        
        func fetchPopularMovies() async throws -> [Movie] {
            if let handler = fetchPopularMoviesHandler {
                return try await handler()
            }
            return []
        }
        
        func fetchMovieDetails(id: Int) async throws -> Movie {
            if let handler = fetchMovieDetailsHandler {
                return try await handler(id)
            }
            fatalError("fetchMovieDetailsHandler not implemented")
        }
    }
    
    class MockMoviesCacheRepository: MoviesCacheRepository {
        var getMovieHandler: ((Int) async throws -> Movie?)?
        var getCachedMoviesHandler: (() async throws -> [Movie])?
        var getMoviePosterDataHandler: ((String) async throws -> Data?)?
        var saveMovieHandler: ((Movie) async throws -> Void)?
        
        func getCachedMovies() async throws -> [Movie] {
            if let handler = getCachedMoviesHandler {
                return try await handler()
            }
            return []
        }
        
        func getMovie(id: Int) async throws -> Movie? {
            if let handler = getMovieHandler {
                return try await handler(id)
            }
            return nil
        }
        
        func getMoviePosterData(path: String) async throws -> Data? {
            if let handler = getMoviePosterDataHandler {
                return try await handler(path)
            }
            return nil
        }
        
        func save(movie: Movie) async throws {
            if let handler = saveMovieHandler {
                try await handler(movie)
            }
        }
    }
    
    class MockPosterImagesRepository: PosterImagesRepository {
        var fetchImageHandler: ((String, ImageSize) async throws -> Data)?
        var fetchImageCalled = false
        
        func fetchImage(with imagePath: String, size: ImageSize) async throws -> Data {
            fetchImageCalled = true
            if let handler = fetchImageHandler {
                return try await handler(imagePath, size)
            }
            return Data()
        }
    }
    
    // MARK: - Test Properties
    
    var searchMoviesRepository: MockSearchMoviesRepository!
    var movieCacheRepository: MockMoviesCacheRepository!
    var posterImagesRepository: MockPosterImagesRepository!
    var useCase: MovieDetailsUseCase!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        searchMoviesRepository = MockSearchMoviesRepository()
        movieCacheRepository = MockMoviesCacheRepository()
        posterImagesRepository = MockPosterImagesRepository()
        useCase = MovieDetailsUseCase(
            searchMoviesRepository: searchMoviesRepository,
            movieCacheRepository: movieCacheRepository,
            posterImagesRepository: posterImagesRepository
        )
    }
    
    override func tearDown() {
        searchMoviesRepository = nil
        movieCacheRepository = nil
        posterImagesRepository = nil
        useCase = nil
        super.tearDown()
    }
    
    // MARK: - Fixture Helpers
    
    /// Loads the MovieDetails.json fixture from the test bundle.
    func loadMovieDetailsFixture() throws -> Movie {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "MovieDetails", withExtension: "json") else {
            throw NSError(domain: "TestError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Missing MovieDetails.json fixture"])
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Movie.self, from: data)
    }
    
    // MARK: - Tests
    
    // Test when the movie exists in the cache.
    func testMovieDetails_ReturnsCachedMovie() async throws {
        // Arrange: Use the fixture to simulate a cached movie (with id 550, Fight Club).
        let cachedMovie = try loadMovieDetailsFixture()
        movieCacheRepository.getMovieHandler = { id in
            XCTAssertEqual(id, cachedMovie.id)
            return cachedMovie
        }
        
        // We do not expect fetchMovieDetails to be called.
        searchMoviesRepository.fetchMovieDetailsHandler = { id in
            XCTFail("fetchMovieDetails should not be called when movie is cached")
            return cachedMovie
        }
        
        // Act
        let result = try await useCase.movieDetails(id: cachedMovie.id)
        
        // Assert
        XCTAssertEqual(result, cachedMovie)
        XCTAssertFalse(posterImagesRepository.fetchImageCalled, "PosterImagesRepository.fetchImage should not be called for cached movie")
    }
    
    // Test when no cached movie exists and the fetched movie has a poster.
    func testMovieDetails_FetchesAndCachesMovie_WithPoster() async throws {
        // Arrange: No cached movie.
        movieCacheRepository.getMovieHandler = { id in
            return nil
        }
        
        // Load the fixture representing Fight Club.
        let fetchedMovie = try loadMovieDetailsFixture()
        // Assume the fixture has a valid poster path (e.g., "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg").
        XCTAssertNotNil(fetchedMovie.poster, "Fixture should contain a poster path")
        
        // Simulate fetching movie details from the remote repository.
        searchMoviesRepository.fetchMovieDetailsHandler = { id in
            XCTAssertEqual(id, fetchedMovie.id)
            return fetchedMovie
        }
        
        // Simulate fetching poster image data.
        let dummyPosterData = Data([10, 20, 30])
        posterImagesRepository.fetchImageHandler = { imagePath, size in
            XCTAssertEqual(imagePath, fetchedMovie.poster)
            XCTAssertEqual(size, .original)
            return dummyPosterData
        }
        
        var savedMovie: Movie?
        movieCacheRepository.saveMovieHandler = { movie in
            savedMovie = movie
        }
        
        // Act
        let result = try await useCase.movieDetails(id: fetchedMovie.id)
        
        // Assert: The returned movie should have its posterImageData set.
        XCTAssertEqual(result.id, fetchedMovie.id)
        XCTAssertEqual(result.title, fetchedMovie.title)
        XCTAssertNotNil(result.posterImageData)
        XCTAssertEqual(result.posterImageData, dummyPosterData)
        
        // Verify that the movie was saved to the cache.
        XCTAssertNotNil(savedMovie)
        XCTAssertEqual(savedMovie?.id, fetchedMovie.id)
        XCTAssertEqual(savedMovie?.posterImageData, dummyPosterData)
        XCTAssertTrue(posterImagesRepository.fetchImageCalled, "PosterImagesRepository.fetchImage should have been called")
    }
    
    // Test when no cached movie exists and the fetched movie has no poster.
    func testMovieDetails_FetchesAndCachesMovie_WithoutPoster() async throws {
        // Arrange: No cached movie.
        movieCacheRepository.getMovieHandler = { id in
            return nil
        }
        
        // Load the fixture and simulate no poster by creating a new instance with poster set to nil.
        let originalMovie = try loadMovieDetailsFixture()
        let fetchedMovie = Movie(
            id: originalMovie.id,
            title: originalMovie.title,
            overview: originalMovie.overview,
            poster: nil,  // Simulate absence of poster.
            voteAverage: originalMovie.voteAverage,
            releaseDate: originalMovie.releaseDate,
            genreIds: originalMovie.genreIds,
            genres: originalMovie.genres,
            posterImageData: nil
        )
        
        // Simulate fetching movie details.
        searchMoviesRepository.fetchMovieDetailsHandler = { id in
            XCTAssertEqual(id, fetchedMovie.id)
            return fetchedMovie
        }
        
        // The posterImagesRepository should not be called since there is no poster.
        posterImagesRepository.fetchImageHandler = { imagePath, size in
            XCTFail("fetchImage should not be called when poster is nil")
            return Data()
        }
        
        var savedMovie: Movie?
        movieCacheRepository.saveMovieHandler = { movie in
            savedMovie = movie
        }
        
        // Act
        let result = try await useCase.movieDetails(id: fetchedMovie.id)
        
        // Assert
        XCTAssertEqual(result.id, fetchedMovie.id)
        XCTAssertEqual(result.title, fetchedMovie.title)
        XCTAssertNil(result.posterImageData, "posterImageData should be nil when no poster is provided")
        
        XCTAssertNotNil(savedMovie)
        XCTAssertEqual(savedMovie?.id, fetchedMovie.id)
        XCTAssertNil(savedMovie?.posterImageData)
        XCTAssertFalse(posterImagesRepository.fetchImageCalled, "PosterImagesRepository.fetchImage should not be called when poster is nil")
    }
}
