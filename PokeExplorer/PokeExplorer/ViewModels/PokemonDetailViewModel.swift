import Foundation
import SwiftData

@MainActor
class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokemonDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorited = false

    private let api = APIService.shared
    private let service: PersistenceService
    private let user: User
    private let urlString: String

    // O init agora precisa do ModelContainer para criar o PersistenceService
    init(pokemonURL: String, user: User, modelContainer: ModelContainer) {
        self.urlString = pokemonURL
        self.user = user
        self.service = PersistenceService(modelContainer: modelContainer)
        fetchDetail()
    }
    
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
    
    // A chamada do botão dispara esta função.
    func toggleFavorite() {
        guard let detail = detail else { return }

        Task { [weak self] in
            guard let self = self else { return }
            
            // Primeiro, checamos o status atual de forma assíncrona
            let isCurrentlyFavorited = await self.service.isFavorite(pokemonID: detail.id, for: self.user)
            
            do {
                if isCurrentlyFavorited {
                    try await self.service.removeFavorite(pokemonID: detail.id, from: self.user)
                    // Atualiza a UI na thread principal
                    await MainActor.run { self.isFavorited = false }
                } else {
                    try await self.service.addFavorite(pokemonDetail: detail, for: self.user)
                    // Atualiza a UI na thread principal
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
