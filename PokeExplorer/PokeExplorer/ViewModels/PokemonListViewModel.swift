import Foundation

@MainActor
class PokemonListViewModel: ObservableObject {
    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MUDANÇA 1: A propriedade agora é do tipo do protocolo, não da classe concreta.
    private let api: APIServiceProtocol
    private let limit: Int
    private var offset = 0
    private var canLoadMore = true

    // MUDANÇA 2: O inicializador agora recebe a dependência da API.
    // Usamos um valor padrão para o `api` para que o código existente do app não quebre.
    // O app continuará usando `APIService.shared`, mas os testes poderão injetar um mock.
    init(api: APIServiceProtocol = APIService.shared, limit: Int = 20) {
        self.api = api
        self.limit = limit
    }

    func fetchInitialPokemons() async {
        offset = 0
        canLoadMore = true
        pokemons = []
        errorMessage = nil
        await loadMorePokemons()
    }

    func loadMorePokemons() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            // Nenhuma alteração aqui, o método continua chamando a função do protocolo.
            let resp = try await api.fetchPokemonList(limit: limit, offset: offset)
            pokemons.append(contentsOf: resp.results)
            offset += resp.results.count
            canLoadMore = !resp.results.isEmpty
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchAllPokemons() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let resp = try await api.fetchPokemonList(limit: 100_000, offset: 0)
            pokemons = resp.results
            canLoadMore = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
