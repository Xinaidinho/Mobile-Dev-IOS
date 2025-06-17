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
    private var persistenceService: PersistenceService? // Agora é opcional, inicializado no setup
    private var apiService = APIService()
    
    // Init simplificado, não precisa mais do modelContext
    init(pokemonURL: String, user: User) {
        self.pokemonURL = pokemonURL
        self.loggedInUser = user
    }
    
    // Função para configurar o serviço de persistência
    func setup(modelContext: ModelContext) {
        if self.persistenceService == nil {
            self.persistenceService = PersistenceService(modelContext: modelContext)
        }
    }
    
    func fetchData() {
        print("[DETAIL] ==> 1. Função fetchData() FOI CHAMADA para a URL: \(pokemonURL)")
        isLoading = true
        
        Task {
            do {
                let detail = try await apiService.fetchPokemonDetails(from: pokemonURL)
                pokemonDetail = detail
                checkIfFavorite()
                print("[DETAIL] ==> 2. SUCESSO! Detalhes do Pokémon '\(detail.name)' carregados.")
            } catch is CancellationError {
                // Este erro acontece se o usuário navegar para trás antes de a tarefa terminar. É normal.
                print("[DETAIL] ==> X. TAREFA CANCELADA. Isso é normal se a navegação foi rápida.")
            } catch {
                // Se qualquer outro erro ocorrer, ele será impresso aqui.
                print("[DETAIL] ==> X. ERRO INESPERADO ao buscar detalhes: \(error)")
                self.errorMessage = "Não foi possível carregar os detalhes."
            }
            
            isLoading = false
        }
    }
    
    func toggleFavorite() {
        guard let persistenceService = persistenceService, let detail = pokemonDetail else {
            print("[DETAIL] ==> ERRO: PersistenceService não foi inicializado para favoritar.")
            return
        }
        
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
        guard let persistenceService = persistenceService, let pokemonDetail = pokemonDetail else { return }
        self.isFavorite = persistenceService.isFavorite(pokemonID: pokemonDetail.id, for: loggedInUser)
    }
}