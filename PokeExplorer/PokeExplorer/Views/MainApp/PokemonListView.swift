import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @Namespace private var animationNamespace
    let user: User
    
    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                ForEach(viewModel.pokemons) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemonURL: pokemon.url, user: user, namespace: animationNamespace)) {
                        PokemonGridItemView(pokemon: pokemon, animationNamespace: animationNamespace)
                            // Este .onAppear continua aqui para a paginação
                            .onAppear {
                                viewModel.loadMorePokemonsIfNeeded(currentPokemon: pokemon)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .animation(.default, value: viewModel.pokemons)

            if viewModel.isLoading {
                ProgressView().padding()
            }
        }
        .navigationTitle("PokéExplorer")
        // ADICIONE ESTE MODIFICADOR:
        // Dispara a busca de dados assim que a tela aparece.
        .onAppear {
            viewModel.fetchInitialPokemons()
        }
    }
}