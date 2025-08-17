//
//  CoreDataMoviesCacheRepositoryTests.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//


import XCTest
import CoreData
@testable import MovieFinder

final class CoreDataMoviesCacheRepositoryTests: XCTestCase {

    var inMemoryContext: NSManagedObjectContext!
    var repository: CoreDataMoviesCacheRepository!

    override func setUp() {
        super.setUp()
        inMemoryContext = setUpInMemoryManagedObjectContext()
        // Use a small cache size (e.g., 2) to test eviction.
        repository = CoreDataMoviesCacheRepository(context: inMemoryContext, maxCacheSize: 2)
    }

    override func tearDown() {
        inMemoryContext = nil
        repository = nil
        super.tearDown()
    }
    
    // MARK: - In-Memory Core Data Setup
    
    /// Creates an in-memory NSManagedObjectContext using the merged model.
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        // This will load all models available in all bundles.
        guard let model = NSManagedObjectModel.mergedModel(from: nil) else {
            fatalError("Failed to load merged model from bundles.")
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(
                ofType: NSInMemoryStoreType,
                configurationName: nil,
                at: nil,
                options: nil
            )
        } catch {
            fatalError("Failed to add in-memory store: \(error)")
        }
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
    
    // MARK: - Fixture Helpers
    
    /// Loads fixture data from the test bundle.
    func loadFixtureData(named name: String, withExtension ext: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw NSError(domain: "TestError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Missing fixture \(name).\(ext)"])
        }
        return try Data(contentsOf: url)
    }
    
    /// Loads a Movie from the ModelDetails.json fixture.
    func loadMovieDetailFixture() throws -> Movie {
        let data = try loadFixtureData(named: "MovieDetails", withExtension: "json")
        return try JSONDecoder().decode(Movie.self, from: data)
    }
    
    /// Loads image data from FightClub.jpg.
    func loadFightClubImageData() throws -> Data {
        return try loadFixtureData(named: "FightClub", withExtension: "jpg")
    }
    
    // MARK: - Tests
    
    func testSaveAndRetrieveMovieDetail() async throws {
        // Load a movie detail from fixture and attach poster image data.
        var movie = try loadMovieDetailFixture()
        movie.posterImageData = try loadFightClubImageData()
        
        // Save the movie detail.
        try await repository.save(movie: movie)
        
        // Retrieve the movie by its id.
        let fetchedMovie = try await repository.getMovie(id: movie.id)
        XCTAssertNotNil(fetchedMovie, "Expected to retrieve the saved movie detail")
        XCTAssertEqual(fetchedMovie?.id, movie.id)
        XCTAssertEqual(fetchedMovie?.title, movie.title)
        if let expectedData = movie.posterImageData {
            XCTAssertEqual(fetchedMovie?.posterImageData, expectedData)
        }
    }
    
    func testSaveMovieDetail_DoesNotDuplicate() async throws {
        // Save the same movie detail twice.
        let movie = try loadMovieDetailFixture()
        try await repository.save(movie: movie)
        try await repository.save(movie: movie)
        
        let movies = try await repository.getCachedMovies()
        XCTAssertEqual(movies.count, 1, "Expected no duplicate entries in cache")
    }
    
    func testCacheEviction_RemovesOldestMovieDetail() async throws {
        // For eviction testing, our maxCacheSize is 2.
        // Save first movie from fixture.
        let movie1 = try loadMovieDetailFixture()
        try await repository.save(movie: movie1)
        
        // Create a second movie with a unique id.
        let movie2 = try loadMovieDetailFixture()
        let movie2Modified = Movie(
            id: movie1.id + 1,
            title: movie2.title,
            overview: movie2.overview,
            poster: movie2.poster,
            voteAverage: movie2.voteAverage,
            releaseDate: movie2.releaseDate,
            genreIds: movie2.genreIds,
            genres: movie2.genres,
            posterImageData: movie2.posterImageData
        )
        // Wait a moment to ensure a different insertionDate.
        sleep(1)
        try await repository.save(movie: movie2Modified)
        
        // Save a third movie that should trigger eviction.
        let movie3 = try loadMovieDetailFixture()
        let movie3Modified = Movie(
            id: movie1.id + 2,
            title: movie3.title,
            overview: movie3.overview,
            poster: movie3.poster,
            voteAverage: movie3.voteAverage,
            releaseDate: movie3.releaseDate,
            genreIds: movie3.genreIds,
            genres: movie3.genres,
            posterImageData: movie3.posterImageData
        )
        try await repository.save(movie: movie3Modified)
        
        let cachedMovies = try await repository.getCachedMovies()
        XCTAssertEqual(cachedMovies.count, 2, "Cache should not exceed maxCacheSize")
        let cachedIds = cachedMovies.map { $0.id }
        XCTAssertFalse(cachedIds.contains(movie1.id), "Oldest movie detail should be evicted from cache")
        XCTAssertTrue(cachedIds.contains(movie2Modified.id), "Second movie should remain in cache")
        XCTAssertTrue(cachedIds.contains(movie3Modified.id), "Newest movie should be in cache")
    }
    
    func testGetMoviePosterData() async throws {
        let expectedImageData = try loadFightClubImageData()
        
        // Insert a CDMovie directly into the context with posterPath "FightClub".
        let cdMovie = CDMovie(context: inMemoryContext)
        cdMovie.id = 123
        cdMovie.title = "FightClub"
        cdMovie.overview = "A gritty take on the iconic villain."
        cdMovie.posterPath = "FightClub"
        cdMovie.posterData = expectedImageData
        cdMovie.voteAverage = 8.5
        cdMovie.releaseDate = "2025-01-01"
        cdMovie.insertionDate = Date()
        try inMemoryContext.save()
        
        let posterData = try await repository.getMoviePosterData(path: "FightClub")
        XCTAssertNotNil(posterData, "Expected to retrieve poster data")
        XCTAssertEqual(posterData, expectedImageData)
    }
}
