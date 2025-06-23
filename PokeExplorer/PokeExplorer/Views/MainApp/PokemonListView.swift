import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @Namespace private var animationNamespace
    @Environment(\.modelContext.container) private var modelContainer
    let user: User

    private let columns = [ GridItem(.adaptive(minimum: 120), spacing: 16) ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.pokemons) { pokemon in
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
                        .onAppear {
                            if pokemon == viewModel.pokemons.last {
                                Task { await viewModel.loadMorePokemons() }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                if viewModel.isLoading {
                    ProgressView().padding()
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).padding()
                }
            }
            .navigationTitle("Explorar")
            // MUDANÇA: O bloco .toolbar foi removido daqui.
            .task {
                await viewModel.fetchInitialPokemons()
            }
        }
    }
}
