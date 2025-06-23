import Foundation

@MainActor
// Serviço responsável por acessar a API da PokéAPI e buscar dados de Pokémon
class APIService: APIServiceProtocol {
    // Instância singleton para uso global
    static let shared = APIService()

    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    private let decoder: JSONDecoder
    private let session: URLSession

    // Inicializador privado para garantir singleton
    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        session = .shared
    }

    /// Busca lista paginada de Pokémons
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

    /// Busca detalhes de um Pokémon a partir de uma URL completa
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
