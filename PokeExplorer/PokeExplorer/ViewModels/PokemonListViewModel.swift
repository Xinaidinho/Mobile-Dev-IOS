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
    
    func loadMorePokemonsIfNeeded(currentPokemon: Pokemon?) {
        // Lógica para carregar mais itens quando o usuário se aproxima do final da lista
        guard let currentPokemon = currentPokemon else {
            loadMorePokemons()
            return
        }
        
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
                
                self.pokemons.append(contentsOf: response.results)
                self.currentPage += 1
                self.canLoadMore = response.next != nil
                
            } catch {
                self.errorMessage = "Falha ao carregar Pokémon: \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
}
