import SwiftUI

@MainActor
class PokemonListViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var apiService = APIService()
    private var currentPage = 0
    private let limit = 20
    private var canLoadMore = true
    
    // NOVA FUNÇÃO: Dispara a carga inicial dos dados.
    func fetchInitialPokemons() {
        // Garante que a chamada inicial não seja feita múltiplas vezes.
        guard pokemons.isEmpty else { return }
        loadMorePokemons()
    }
    
    // Função para paginação, chamada quando o usuário rola a tela.
    func loadMorePokemonsIfNeeded(currentPokemon: Pokemon?) {
        guard let currentPokemon = currentPokemon else { return }
        
        let thresholdIndex = pokemons.index(pokemons.endIndex, offsetBy: -5)
        if pokemons.firstIndex(where: { $0.id == currentPokemon.id }) == thresholdIndex {
            loadMorePokemons()
        }
    }
    
    private func loadMorePokemons() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        
        Task {
            do {
                let offset = currentPage * limit
                let response = try await apiService.fetchPokemonList(limit: limit, offset: offset)
                
                pokemons.append(contentsOf: response.results)
                currentPage += 1
                canLoadMore = !response.results.isEmpty
                
            } catch {
                self.errorMessage = "Falha ao carregar Pokémon: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}