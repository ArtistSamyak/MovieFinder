//
//  NetworkServiceTests.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//


import XCTest
@testable import MovieFinder

// Fake network monitor that never throws no internet error.
final class FakeNetworkMonitor: NetworkMonitorType {
    func checkInternetConnection() throws { }
}

// Fake network monitor that always throws no internet error.
final class FakeNetworkMonitorThrowsNoInternet: NetworkMonitorType {
    func checkInternetConnection() throws {
        throw NetworkError.noInternet
    }
}

final class NetworkServiceTests: XCTestCase {
    
    var networkService: NetworkService!
    var session: URLSession!
    var networkMonitor: NetworkMonitorType!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
        networkMonitor = FakeNetworkMonitor()
        networkService = NetworkService(session: session, networkMonitor: networkMonitor)
    }
    
    override func tearDown() {
        networkService = nil
        session = nil
        networkMonitor = nil
        URLProtocolMock.requestHandler = nil
        super.tearDown()
    }
    
    struct TestModel: Decodable, Equatable {
        let id: Int
        let name: String
    }
    
    // Test for a successful JSON response.
    func testLoad_SuccessfulResponse() async throws {
        // Prepare sample JSON data.
        let jsonString = """
        { "id": 1, "name": "Test" }
        """
        let expectedData = Data(jsonString.utf8)
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                               statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        // Set the request handler to return our expected data.
        URLProtocolMock.requestHandler = { request in
            return (expectedData, expectedResponse)
        }
        
        let endpoint = Endpoint<TestModel>(url: URL(string: "https://example.com")!)
        let result = try await networkService.load(endpoint)
        
        let expectedModel = TestModel(id: 1, name: "Test")
        XCTAssertEqual(result, expectedModel)
    }
    
    // Test for a non-200 HTTP status code.
    func testLoad_Non200Response() async {
        let jsonString = """
        { "id": 1, "name": "Test" }
        """
        let data = Data(jsonString.utf8)
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                       statusCode: 404, httpVersion: nil, headerFields: nil)!
        URLProtocolMock.requestHandler = { request in
            return (data, response)
        }
        
        let endpoint = Endpoint<TestModel>(url: URL(string: "https://example.com")!)
        do {
            _ = try await networkService.load(endpoint)
            XCTFail("Expected to throw dataLoadingError")
        } catch let error as NetworkError {
            if case .dataLoadingError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("Expected dataLoadingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // Test for a JSON decoding error.
    func testLoad_JSONDecodingError() async {
        // Return data that doesn't match the expected JSON structure.
        let invalidJSON = Data("{}".utf8)
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                       statusCode: 200, httpVersion: nil, headerFields: nil)!
        URLProtocolMock.requestHandler = { request in
            return (invalidJSON, response)
        }
        
        let endpoint = Endpoint<TestModel>(url: URL(string: "https://example.com")!)
        do {
            _ = try await networkService.load(endpoint)
            XCTFail("Expected to throw jsonDecodingError")
        } catch let error as NetworkError {
            if case .jsonDecodingError = error {
                // Expected error
            } else {
                XCTFail("Expected jsonDecodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // Test for no internet connection error.
    func testLoad_NoInternetConnection() async {
        let fakeMonitor = FakeNetworkMonitorThrowsNoInternet()
        networkService = NetworkService(session: session, networkMonitor: fakeMonitor)
        
        let endpoint = Endpoint<TestModel>(url: URL(string: "https://example.com")!)
        
        do {
            _ = try await networkService.load(endpoint)
            XCTFail("Expected to throw noInternet error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noInternet)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
