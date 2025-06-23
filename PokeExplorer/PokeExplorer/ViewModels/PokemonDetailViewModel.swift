import Foundation
import SwiftData

@MainActor
class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokemonDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorited = false

    // MUDANÇA 1: As propriedades agora são dos tipos de protocolo.
    private let api: APIServiceProtocol
    private let service: PersistenceServiceProtocol
    private let user: User
    private let urlString: String

    // MUDANÇA 2: Um novo inicializador "designado" que recebe os protocolos.
    // Este será o inicializador que usaremos nos nossos testes.
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
    
    // MUDANÇA 3: O init antigo se torna um `convenience init`.
    // Ele cria as dependências e chama o novo init. O código do app não precisa mudar.
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
    
    private func fetchDetail() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                // A chamada da API agora usa o protocolo
                detail = try await api.fetchPokemonDetail(from: urlString)
                await checkIfFavorited()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // A chamada do botão dispara esta função.
    func toggleFavorite() {
        guard let detail = detail else { return }

        Task { [weak self] in
            guard let self = self else { return }
            
            // A lógica aqui já usa `service` (o protocolo), então não precisa de mudanças.
            let isCurrentlyFavorited = await self.service.isFavorite(pokemonID: detail.id, for: self.user)
            
            do {
                if isCurrentlyFavorited {
                    try await self.service.removeFavorite(pokemonID: detail.id, from: self.user)
                    await MainActor.run { self.isFavorited = false }
                } else {
                    try await self.service.addFavorite(pokemonDetail: detail, for: self.user)
                    await MainActor.run { self.isFavorited = true }
                }
            } catch {
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }
    
    private func checkIfFavorited() async {
        guard let detail = detail else { return }
        self.isFavorited = await service.isFavorite(pokemonID: detail.id, for: user)
    }
}
