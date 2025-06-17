import SwiftUI
import SwiftData

@MainActor
class PokemonDetailViewModel: ObservableObject {
    @Published var pokemonDetail: PokemonDetail?
    @Published var isFavorite = false
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let pokemonURL: String
    private let loggedInUser: User
    private var persistenceService: PersistenceService // Não é mais private
    private var apiService = APIService()
    
    // init limpo e direto
    init(pokemonURL: String, user: User, modelContext: ModelContext) {
        self.pokemonURL = pokemonURL
        self.loggedInUser = user
        self.persistenceService = PersistenceService(modelContext: modelContext)
    }
    
    func fetchData() {
        isLoading = true
        Task {
            do {
                let detail = try await apiService.fetchPokemonDetails(from: pokemonURL)
                pokemonDetail = detail
                checkIfFavorite()
            } catch {
                errorMessage = "Não foi possível carregar os detalhes."
            }
            isLoading = false
        }
    }
    
    func toggleFavorite() {
        guard let detail = pokemonDetail else { return }
        isFavorite.toggle()
        
        Task {
            do {
                if isFavorite {
                    try persistenceService.addFavorite(pokemonDetail: detail, for: loggedInUser)
                } else {
                    try persistenceService.removeFavorite(pokemonID: detail.id, from: loggedInUser)
                }
            } catch {
                isFavorite.toggle()
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Erro ao atualizar favoritos."
            }
        }
    }
    
    private func checkIfFavorite() {
        guard let pokemonDetail = pokemonDetail else { return }
        isFavorite = persistenceService.isFavorite(pokemonID: pokemonDetail.id, for: loggedInUser)
    }
}
