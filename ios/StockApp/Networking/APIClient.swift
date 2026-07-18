import Foundation

enum APIError: Error {
    case invalidResponse
    case server(Int)
}

final class APIClient {
    static let shared = APIClient()

    var baseURL = URL(string: "http://127.0.0.1:8000")!

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query
        }
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.server(http.statusCode) }
        return try decoder.decode(T.self, from: data)
    }

    func search(query: String) async throws -> [StockSummary] {
        let response: SearchResponse = try await get("/stocks/search", query: [URLQueryItem(name: "q", value: query)])
        return response.results
    }

    func quote(code: String) async throws -> Quote {
        try await get("/stocks/\(code)/quote")
    }

    func history(code: String, range: String = "6mo", interval: String = "1d") async throws -> HistoryResponse {
        try await get("/stocks/\(code)/history", query: [
            URLQueryItem(name: "range", value: range),
            URLQueryItem(name: "interval", value: interval),
        ])
    }

    func technical(code: String, range: String = "6mo") async throws -> TechnicalResponse {
        try await get("/stocks/\(code)/technical", query: [URLQueryItem(name: "range", value: range)])
    }

    func fundamentals(code: String) async throws -> Fundamentals {
        try await get("/stocks/\(code)/fundamentals")
    }

    func signal(code: String) async throws -> StockSignal {
        try await get("/stocks/\(code)/signal")
    }

    func crossScreener() async throws -> CrossScreenerResponse {
        try await get("/screener/crosses")
    }
}
