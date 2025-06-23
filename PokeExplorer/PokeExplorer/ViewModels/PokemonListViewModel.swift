// Importa o framework Foundation para recursos básicos
import Foundation

// ViewModel responsável pela lógica da lista de Pokémons
@MainActor
class PokemonListViewModel: ObservableObject {
    // Lista de Pokémons exibida na tela
    @Published private(set) var pokemons: [Pokemon] = []
    // Indica se está carregando dados
    @Published private(set) var isLoading = false
    // Mensagem de erro, se houver
    @Published private(set) var errorMessage: String?

    // Serviço de API para buscar os Pokémons
    // MUDANÇA 1: A propriedade agora é do tipo do protocolo, não da classe concreta.
    private let api: APIServiceProtocol
    // Quantidade de Pokémons por página
    private let limit: Int
    // Offset para paginação
    private var offset = 0
    // Indica se ainda pode carregar mais Pokémons
    private var canLoadMore = true

    // Inicializador permite injeção de dependência para facilitar testes
    // MUDANÇA 2: O inicializador agora recebe a dependência da API.
    // Usamos um valor padrão para o `api` para que o código existente do app não quebre.
    // O app continuará usando `APIService.shared`, mas os testes poderão injetar um mock.
    init(api: APIServiceProtocol = APIService.shared, limit: Int = 20) {
        self.api = api
        self.limit = limit
    }

    // Busca inicial dos Pokémons (primeira página)
    func fetchInitialPokemons() async {
        offset = 0
        canLoadMore = true
        pokemons = []
        errorMessage = nil
        await loadMorePokemons()
    }

    // Carrega mais Pokémons para a lista (paginação)
    func loadMorePokemons() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            // Busca lista de Pokémons usando o serviço de API
            let resp = try await api.fetchPokemonList(limit: limit, offset: offset)
            pokemons.append(contentsOf: resp.results)
            offset += resp.results.count
            canLoadMore = !resp.results.isEmpty
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Busca todos os Pokémons de uma vez (sem paginação)
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
