import Foundation

@MainActor
class PokemonListViewModel: ObservableObject {
    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let api = APIService.shared
    private let limit: Int
    private var offset = 0
    private var canLoadMore = true

    init(limit: Int = 20) {
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
