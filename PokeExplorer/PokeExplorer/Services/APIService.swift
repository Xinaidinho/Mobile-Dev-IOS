import Foundation

@MainActor
class APIService {
    static let shared = APIService()

    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    private let decoder: JSONDecoder
    private let session: URLSession

    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        session = .shared
    }

    /// Lista paginada
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonResponse {
        var comps = URLComponents(url: baseURL.appendingPathComponent("pokemon"),
                                  resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "limit", value: "\(limit)"),
            .init(name: "offset", value: "\(offset)")
        ]
        let url = comps.url!
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode)
        else { throw URLError(.badServerResponse) }

        return try decoder.decode(PokemonResponse.self, from: data)
    }

    /// Detalhes a partir de qualquer URL completa
    func fetchPokemonDetail(from urlString: String) async throws -> PokemonDetail {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode)
        else { throw URLError(.badServerResponse) }

        return try decoder.decode(PokemonDetail.self, from: data)
    }
}
