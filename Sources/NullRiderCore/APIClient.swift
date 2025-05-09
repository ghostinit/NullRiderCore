import Foundation

///Here are a few power moves you could do next, depending on your goals:
//1.    Add a no-payload overload for sendRequest to clean up future GET calls
//2.    Handle error decoding for nicer 401/403/500 messages
//3.    Log all requests and responses during development (easy with your Logger)
//4.    Wire up token storage/retrieval with KeychainHelper
//5.    Create an APIService.swift in the app layer to group endpoints
///

public struct EmptyPayload: Codable {}

public struct APIClient {
    public let baseURL: URL
    public var defaultHeaders: [String: String] = ["Content-Type": "application/json"]
    public var urlSession: URLSession = .shared
    public var authToken: String?
    public var includeAuthToken: Bool = false

    public init(
        baseURL: URL,
        defaultHeaders: [String: String] = [:],
        authToken: String? = nil,
        includeAuthToken: Bool = false,
        urlSession: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.authToken = authToken
        self.includeAuthToken = includeAuthToken
        self.urlSession = urlSession
        self.defaultHeaders.merge(defaultHeaders) { current, _ in current }
    }

    public func sendRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: String = "POST",
        payload: T? = nil,
        headers: [String: String] = [:],
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        // Merge headers
        var combinedHeaders = defaultHeaders.merging(headers) { current, _ in current }
        if includeAuthToken, let token = authToken {
            combinedHeaders["Authorization"] = "Bearer \(token)"
        }
        combinedHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        // Encode payload if present
        if let payload = payload {
            request.httpBody = try JSONEncoder().encode(payload)
        }

        // Perform request
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200..<300).contains(httpResponse.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorBody)"
            ])
        }
        return try JSONDecoder().decode(U.self, from: data)
    }
}

// Example usage in app layer:
// let client = APIClient(baseURL: URL(string: "https://api.myapp.com")!, authToken: "abc123")
// let result: MyResponseModel = try await client.sendRequest(endpoint: "/some-path", payload: myPayload, responseType: MyResponseModel.self)
