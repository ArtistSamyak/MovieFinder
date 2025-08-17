//
//  TMDbSearchMoviesRepositoryTests.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//


import XCTest
@testable import MovieFinder

/// A fake network service that loads fixture JSON data from the test bundle.
final class FakeNetworkService: NetworkServiceType {
    func load<T: Decodable>(_ resource: Endpoint<T>) async throws -> T {
        // Get the test bundle.
        let bundle = Bundle(for: Self.self)
        
        // Determine which fixture to load based on the URL.
        if resource.url.absoluteString.contains("search/movie") || resource.url.absoluteString.contains("movie/popular") {
            // Load the MovieList fixture.
            guard let url = bundle.url(forResource: "MovieList", withExtension: "json") else {
                throw NSError(domain: "FakeNetworkService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing MovieList.json fixture"])
            }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } else if resource.url.absoluteString.contains("/movie/") {
            // Load the MovieDetails fixture.
            guard let url = bundle.url(forResource: "MovieDetails", withExtension: "json") else {
                throw NSError(domain: "FakeNetworkService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing MovieDetails.json fixture"])
            }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            fatalError("Unhandled endpoint: \(resource.url)")
        }
    }
    
    func loadData(_ endpoint: Endpoint<Data>) async throws -> Data {
        // Not used in these tests.
        return Data()
    }
}

final class TMDbSearchMoviesRepositoryTests: XCTestCase {
    
    var fakeNetworkService: FakeNetworkService!
    var repository: TMDbSearchMoviesRepository!
    
    override func setUp() {
        super.setUp()
        fakeNetworkService = FakeNetworkService()
        repository = TMDbSearchMoviesRepository(networkService: fakeNetworkService)
    }
    
    override func tearDown() {
        fakeNetworkService = nil
        repository = nil
        super.tearDown()
    }
    
    func testFetchMovies_ReturnsMovieList() async throws {
        // When calling fetchMovies with a query (e.g. "FightClub"), we expect the fixture to be decoded.
        let movies = try await repository.fetchMovies(name: "Fight Club")
        
        // Assert that the returned movie list is not empty.
        XCTAssertFalse(movies.isEmpty, "Expected non-empty movie list")
        
        // Optionally verify that at least one movie's title contains "FightClub".
        let containsFightClub = movies.contains { $0.title.lowercased().contains("fight") }
        XCTAssertTrue(containsFightClub, "Expected movie list to contain a movie with title 'FightClub'")
    }
    
    func testFetchPopularMovies_ReturnsMovieList() async throws {
        let movies = try await repository.fetchPopularMovies()
        
        // Assert that the returned movie list is not empty.
        XCTAssertFalse(movies.isEmpty, "Expected non-empty movie list")
        
        // Optionally verify that at least one movie's title contains "FightClub".
        let containsFightClub = movies.contains { $0.title.lowercased().contains("fight") }
        XCTAssertTrue(containsFightClub, "Expected movie list to contain a movie with title 'FightClub'")
    }
    
    func testFetchMovieDetails_ReturnsMovieDetails() async throws {
        // When calling fetchMovieDetails for a given id, the fixture should be decoded.
        let movie = try await repository.fetchMovieDetails(id: 550)
        
        // Assert that the decoded movie matches the expected details from the MovieDetails.json fixture.
        // For example, if your MovieDetails fixture represents the movie "FightClub":
        XCTAssertEqual(movie.title, "Fight Club", "Expected movie title to be 'FightClub'")
        XCTAssertNotNil(movie.overview, "Expected overview to be present")
        XCTAssertNotNil(movie.poster, "Expected poster path to be present")
    }
}
