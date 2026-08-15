import Foundation
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
import Resting
import Testing
@testable import OpenWeatherMapSwift

@Suite(.serialized)
struct OpenWeatherClientTests {
    init() {
        StubURLProtocol.reset()
    }
}

extension OpenWeatherClientTests {
    func makeClient(apiKey: String = "test-key") -> OpenWeatherClient {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [StubURLProtocol.self]
        return OpenWeatherClient(
            apiKey: apiKey,
            configuration: RestClientConfiguration(sessionConfiguration: sessionConfiguration)
        )
    }

    func fixture(_ name: String) throws -> Data {
        let url = Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures")!
        return try Data(contentsOf: url)
    }

    func queryValues(in request: URLRequest, named name: String) -> [String] {
        URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems?
            .filter { $0.name == name }
            .compactMap(\.value) ?? []
    }
}

final class StubURLProtocol: URLProtocol {
    struct Stub {
        let response: URLResponse?
        let data: Data
        let error: Error?
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var handler: ((URLRequest) throws -> Stub)?
    nonisolated(unsafe) private(set) static var requests: [URLRequest] = []

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        do {
            Self.lock.lock()
            Self.requests.append(request)
            let handler = Self.handler
            Self.lock.unlock()
            let stub = try handler?(request) ?? .init(response: nil, data: Data(), error: URLError(.unknown))
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if !stub.data.isEmpty {
                client?.urlProtocol(self, didLoad: stub.data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func respond(statusCode: Int = 200, with data: Data) {
        setHandler { request in
            .init(
                response: HTTPURLResponse(
                    url: request.url!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                ),
                data: data,
                error: nil
            )
        }
    }

    static func fail(with error: Error) {
        setHandler { _ in .init(response: nil, data: Data(), error: error) }
    }

    static func reset() {
        lock.lock()
        handler = nil
        requests = []
        lock.unlock()
    }

    private static func setHandler(_ newHandler: @escaping (URLRequest) throws -> Stub) {
        lock.lock()
        handler = newHandler
        requests = []
        lock.unlock()
    }
}
