// Importa os frameworks necessários para manipulação de dados e concorrência
import Foundation
import SwiftData

// ViewModel responsável pela lógica da tela de detalhes do Pokémon
@MainActor
class PokemonDetailViewModel: ObservableObject {
    // Detalhes do Pokémon buscados na API
    @Published private(set) var detail: PokemonDetail?
    // Indica se está carregando dados
    @Published private(set) var isLoading = false
    // Mensagem de erro, se houver
    @Published private(set) var errorMessage: String?
    // Indica se o Pokémon está favoritado pelo usuário
    @Published private(set) var isFavorited = false

    // Serviços injetados via protocolo para facilitar testes e desacoplamento
    private let api: APIServiceProtocol
    private let service: PersistenceServiceProtocol
    // Usuário logado
    private let user: User
    // URL do Pokémon a ser detalhado
    private let urlString: String

    // Inicializador principal para injeção de dependências (usado em testes)
    init(
        pokemonURL: String,
        user: User,
        api: APIServiceProtocol,
        service: PersistenceServiceProtocol
    ) {
        self.urlString = pokemonURL
        self.user = user
        self.api = api
        self.service = service
        fetchDetail()
    }
    
    // Inicializador de conveniência para uso no app
    convenience init(pokemonURL: String, user: User, modelContainer: ModelContainer) {
        let apiService = APIService.shared
        let persistenceService = PersistenceService(modelContainer: modelContainer)
        self.init(
            pokemonURL: pokemonURL,
            user: user,
            api: apiService,
            service: persistenceService
        )
    }
    
    // Busca os detalhes do Pokémon na API e verifica se está favoritado
    private func fetchDetail() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                detail = try await api.fetchPokemonDetail(from: urlString)
                await checkIfFavorited()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // Alterna o status de favorito do Pokémon (adiciona ou remove dos favoritos)
    func toggleFavorite() {
        guard let detail = detail else { return }

        Task { [weak self] in
            guard let self = self else { return }
            // Verifica se já está favoritado
            let isCurrentlyFavorited = await self.service.isFavorite(pokemonID: detail.id, for: self.user)
            do {
                if isCurrentlyFavorited {
                    // Remove dos favoritos
                    try await self.service.removeFavorite(pokemonID: detail.id, from: self.user)
                    await MainActor.run { self.isFavorited = false }
                } else {
                    // Adiciona aos favoritos
                    try await self.service.addFavorite(pokemonDetail: detail, for: self.user)
                    await MainActor.run { self.isFavorited = true }
                }
            } catch {
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }
    
    // Verifica se o Pokémon já está favoritado pelo usuário
    private func checkIfFavorited() async {
        guard let detail = detail else { return }
        self.isFavorited = await service.isFavorite(pokemonID: detail.id, for: user)
    }
}
