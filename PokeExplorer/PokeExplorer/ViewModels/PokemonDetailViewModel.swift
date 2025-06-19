import Foundation
import SwiftData

@MainActor
class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokemonDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorited = false

    private let api = APIService.shared
    private let urlString: String

    init(pokemonURL: String) {
        self.urlString = pokemonURL
        fetchDetail()
    }

    private func fetchDetail() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                detail = try await api.fetchPokemonDetail(from: urlString)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Alterna o estado de favorito e persiste
    func toggleFavorite(for detail: PokemonDetail, user: User, in context: ModelContext) async {
        let service = PersistenceService(modelContext: context)
        do {
            if service.isFavorite(pokemonID: detail.id, for: user) {
                try service.removeFavorite(pokemonID: detail.id, from: user)
                isFavorited = false
            } else {
                try service.addFavorite(pokemonDetail: detail, for: user)
                isFavorited = true
            }
        } catch {
            print("Erro ao alterar favorito: \(error.localizedDescription)")
        }
    }

    /// Checa no início se já está favoritado
    func checkIfFavorited(by user: User, in context: ModelContext) async {
        guard let detail = detail else { return }
        let service = PersistenceService(modelContext: context)
        isFavorited = service.isFavorite(pokemonID: detail.id, for: user)
    }
}
