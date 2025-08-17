//
//  SearchMoviesUseCaseTests.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import XCTest
@testable import MovieFinder

final class SearchMoviesUseCaseTests: XCTestCase {
    
    // MARK: - Mock Implementations
    
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
        var getCachedMoviesHandler: (() async throws -> [Movie])?
        var getMovieHandler: ((Int) async throws -> Movie?)?
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
    var useCase: SearchMoviesUseCase!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        searchMoviesRepository = MockSearchMoviesRepository()
        movieCacheRepository = MockMoviesCacheRepository()
        posterImagesRepository = MockPosterImagesRepository()
        useCase = SearchMoviesUseCase(
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
    
    /// Loads and decodes the MovieList.json fixture.
    func loadMovieListFixture() throws -> [Movie] {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "MovieList", withExtension: "json") else {
            throw NSError(domain: "TestError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Missing MovieList.json fixture"])
        }
        let data = try Data(contentsOf: url)
        let movieList = try JSONDecoder().decode(MovieList.self, from: data)
        return movieList.results
    }
    
    /// Loads the FightClub.jpg image data.
    func loadFightClubImageData() throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "FightClub", withExtension: "jpg") else {
            throw NSError(domain: "TestError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Missing FightClub.jpg fixture"])
        }
        return try Data(contentsOf: url)
    }
    
    // MARK: - searchMovies(name:) Tests
    
    func testSearchMovies_SuccessfulNetworkCall() async throws {
        // Arrange: Load movies from fixture.
        let fixtureMovies = try loadMovieListFixture()
        // Return movies that contain the search term (case-insensitive).
        searchMoviesRepository.fetchMoviesHandler = { name in
            return fixtureMovies.filter { $0.title.lowercased().contains(name.lowercased()) }
        }
        
        // Act: Search for "Fight" which should match the Fight Club item.
        let result = try await useCase.searchMovies(name: "Fight")
        
        // Assert: Verify that the result includes a movie with title "Fight Club".
        let containsFightClub = result.contains { $0.title == "Fight Club" }
        XCTAssertTrue(containsFightClub, "Expected result to include 'Fight Club'")
    }
    
    func testSearchMovies_FallbackToCache_Success() async throws {
        // Arrange: Simulate network failure.
        let networkError = NSError(domain: "TestError", code: 1)
        searchMoviesRepository.fetchMoviesHandler = { name in
            throw networkError
        }
        
        // Use fixture movies as cached movies.
        let fixtureMovies = try loadMovieListFixture()
        movieCacheRepository.getCachedMoviesHandler = {
            return fixtureMovies
        }
        
        // Act: Searching for "Fight" should return the Fight Club movie from cache.
        let result = try await useCase.searchMovies(name: "Fight")
        
        // Assert: Verify that Fight Club is included.
        let containsFightClub = result.contains { $0.title == "Fight Club" }
        XCTAssertTrue(containsFightClub, "Expected cached movies to contain 'Fight Club'")
    }
    
    func testSearchMovies_FallbackToCache_Failure() async {
        // Arrange: Simulate network failure.
        let networkError = NSError(domain: "TestError", code: 1)
        searchMoviesRepository.fetchMoviesHandler = { name in
            throw networkError
        }
        
        // Cached movies that do not match the query.
        let nonMatchingMovies = [
            Movie(id: 999,
                  title: "Non-Matching Movie",
                  overview: "Overview",
                  poster: nil,
                  voteAverage: 7.0,
                  releaseDate: "2025-01-01",
                  genreIds: nil,
                  genres: nil)
        ]
        movieCacheRepository.getCachedMoviesHandler = {
            return nonMatchingMovies
        }
        
        // Act & Assert: Expect the use case to throw the network error.
        do {
            _ = try await useCase.searchMovies(name: "Fight")
            XCTFail("Expected to throw error because no cached movie matches the query.")
        } catch {
            XCTAssertEqual((error as NSError).domain, networkError.domain)
            XCTAssertEqual((error as NSError).code, networkError.code)
        }
    }
    
    // MARK: - getPopularMovies() Test
    
    func testPopularMovies_SuccessfulNetworkCall() async throws {
        // Arrange: Load movies from fixture.
        let fixtureMovies = try loadMovieListFixture()
        searchMoviesRepository.fetchPopularMoviesHandler = {
            return fixtureMovies
        }
        
        // Act
        let result = try await useCase.getPopularMovies()
        
        // Assert
        XCTAssertEqual(fixtureMovies, result)
    }
    
    func testPopularMovies_FallbackToCache_Success() async throws {
        // Arrange: Simulate network failure.
        let networkError = NSError(domain: "TestError", code: 1)
        searchMoviesRepository.fetchPopularMoviesHandler = {
            throw networkError
        }
        
        // Use fixture movies as cached movies.
        let fixtureMovies = try loadMovieListFixture()
        movieCacheRepository.getCachedMoviesHandler = {
            return fixtureMovies
        }
        
        // Act: Searching for "Fight" should return the Fight Club movie from cache.
        let result = try await useCase.getPopularMovies()
        
        // Assert
        XCTAssertEqual(fixtureMovies, result)
    }
    
    // MARK: - getSavedMovies() Test
    
    func testGetSavedMovies() async throws {
        // Arrange: Use fixture movies.
        let fixtureMovies = try loadMovieListFixture()
        movieCacheRepository.getCachedMoviesHandler = {
            return fixtureMovies
        }
        
        // Act
        let result = try await useCase.getSavedMovies()
        
        // Assert
        XCTAssertEqual(result, fixtureMovies)
    }
    
    // MARK: - getPosterImage(path:) Tests
    
    func testGetPosterImage_ReturnsCachedImage() async throws {
        // Arrange: Return cached image data from FightClub.jpg.
        let fightClubData = try loadFightClubImageData()
        movieCacheRepository.getMoviePosterDataHandler = { path in
            return fightClubData
        }
        
        // Act
        let result = try await useCase.getPosterImage(path: "FightClub")
        
        // Assert
        XCTAssertEqual(result, fightClubData)
        XCTAssertFalse(posterImagesRepository.fetchImageCalled, "PosterImagesRepository.fetchImage should not be called when cached data exists.")
    }
    
    func testGetPosterImage_FetchesFromPosterImagesRepository() async throws {
        // Arrange: Simulate no cached image data.
        movieCacheRepository.getMoviePosterDataHandler = { path in
            return nil
        }
        let fightClubData = try loadFightClubImageData()
        posterImagesRepository.fetchImageHandler = { path, size in
            XCTAssertEqual(path, "FightClub")
            XCTAssertEqual(size, .small)
            return fightClubData
        }
        
        // Act
        let result = try await useCase.getPosterImage(path: "FightClub")
        
        // Assert
        XCTAssertEqual(result, fightClubData)
        XCTAssertTrue(posterImagesRepository.fetchImageCalled, "PosterImagesRepository.fetchImage should be called when no cached data exists.")
    }
}
