//
//  MoviePosterImagesRepositoryTests.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//


import XCTest
@testable import MovieFinder

// Fake network service that returns FightClub.jpg data when loadData is called.
final class FakeNetworkServiceForPosterImages: NetworkServiceType {
    func load<T: Decodable>(_ resource: Endpoint<T>) async throws -> T {
        fatalError("Not implemented for poster image test")
    }
    
    func loadData(_ endpoint: Endpoint<Data>) async throws -> Data {
        let bundle = Bundle(for: FakeNetworkServiceForPosterImages.self)
        guard let url = bundle.url(forResource: "FightClub", withExtension: "jpg") else {
            throw NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing FightClub.jpg fixture"])
        }
        return try Data(contentsOf: url)
    }
}

final class MoviePosterImagesRepositoryTests: XCTestCase {
    
    var repository: MoviePosterImagesRepository!
    var fakeNetworkService: FakeNetworkServiceForPosterImages!
    
    override func setUp() {
        super.setUp()
        fakeNetworkService = FakeNetworkServiceForPosterImages()
        repository = MoviePosterImagesRepository(networkService: fakeNetworkService)
    }
    
    override func tearDown() {
        repository = nil
        fakeNetworkService = nil
        super.tearDown()
    }
    
    /// Helper to load FightClub.jpg fixture data.
    func loadFightClubImageData() throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "FightClub", withExtension: "jpg") else {
            throw NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing FightClub.jpg fixture"])
        }
        return try Data(contentsOf: url)
    }
    
    func testFetchImage_ReturnsFightClubImageData() async throws {
        // Act: Call fetchImage. The repository will use our FakeNetworkService.
        let imageData = try await repository.fetchImage(with: "FightClub", size: .original)
        
        // Assert: Verify that the returned data matches the FightClub.jpg fixture.
        let expectedData = try loadFightClubImageData()
        XCTAssertEqual(imageData, expectedData, "Fetched image data should match FightClub.jpg fixture data")
    }
}
