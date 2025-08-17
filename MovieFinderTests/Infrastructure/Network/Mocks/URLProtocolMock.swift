//
//  URLProtocolMock.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//


import Foundation
import XCTest

class URLProtocolMock: URLProtocol {
    /// A handler to return custom data, response, and error for a given request.
    static var requestHandler: ((URLRequest) throws -> (Data, HTTPURLResponse))?
    
    // Always handle all requests.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            XCTFail("Handler is not set.")
            return
        }
        do {
            let (data, response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
