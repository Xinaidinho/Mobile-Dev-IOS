// Importa o framework SwiftUI para construção da interface
import SwiftUI

// View responsável por exibir a lista de Pokémons em formato de grid
struct PokemonListView: View {
    // ViewModel responsável pela lógica de negócios e dados da lista
    @StateObject private var viewModel = PokemonListViewModel()
    // Namespace para animações entre telas
    @Namespace private var animationNamespace
    // Acesso ao container de dados do SwiftData
    @Environment(\.modelContext.container) private var modelContainer
    // Usuário logado, passado como parâmetro
    let user: User

    // Define o layout das colunas do grid
    private let columns = [ GridItem(.adaptive(minimum: 120), spacing: 16) ]

    var body: some View {
        NavigationStack {
            ScrollView {
                // Grid adaptativo para exibir os cards dos Pokémons
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.pokemons) { pokemon in
                        // Cada card é um NavigationLink para a tela de detalhes
                        NavigationLink {
                            let detailVM = PokemonDetailViewModel(
                                pokemonURL: pokemon.url,
                                user: user,
                                modelContainer: modelContainer
                            )
                            PokemonDetailView(
                                viewModel: detailVM,
                                namespace: animationNamespace,
                                pokemon: pokemon
                            )
                        } label: {
                            PokemonGridItemView(
                                pokemon: pokemon,
                                animationNamespace: animationNamespace
                            )
                        }
                        .buttonStyle(.plain)
                        // Carrega mais Pokémons ao chegar no final da lista
                        .onAppear {
                            if pokemon == viewModel.pokemons.last {
                                Task { await viewModel.loadMorePokemons() }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                // Exibe indicador de carregamento se necessário
                if viewModel.isLoading {
                    ProgressView().padding()
                }
                // Exibe mensagem de erro, se houver
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).padding()
                }
            }
            .navigationTitle("Explorar")
            // Carrega os Pokémons ao abrir a tela
            .task {
                await viewModel.fetchInitialPokemons()
            }
        }
    }
}
