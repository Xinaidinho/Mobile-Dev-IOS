import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @Namespace private var animationNamespace // Namespace para a animação
    let user: User
    
    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                ForEach(viewModel.pokemons) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemonURL: pokemon.url, user: user, namespace: animationNamespace)) {
                        PokemonGridItemView(pokemon: pokemon, animationNamespace: animationNamespace)
                            .onAppear {
                                viewModel.loadMorePokemonsIfNeeded(currentPokemon: pokemon)
                            }
                    }
                    .buttonStyle(.plain) // Essencial para a animação funcionar bem
                }
            }
            .padding()
            .animation(.default, value: viewModel.pokemons) // Anima a chegada de novos pokémons

            if viewModel.isLoading {
                ProgressView().padding()
            }
        }
        .navigationTitle("PokéExplorer")
    }
}
