import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @Namespace private var animationNamespace
    let user: User

    private let columns = [ GridItem(.adaptive(minimum: 120), spacing: 16) ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.pokemons) { pokemon in
                        NavigationLink(
                            destination: PokemonDetailView(
                                pokemonURL: pokemon.url,
                                user: user,
                                namespace: animationNamespace
                            )
                        ) {
                            VStack {
                                // se você tiver uma imagem de sprite pequena,
                                // pode trocar por AsyncImage aqui
                                Text(pokemon.name.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                        .onAppear {
                            // paginação: quando chegar no último item, carrega mais
                            if pokemon == viewModel.pokemons.last {
                                Task { await viewModel.loadMorePokemons() }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Explorar")
            .toolbar {
                Button("Tudo") {
                    Task { await viewModel.fetchAllPokemons() }
                }
            }
            .task {
                await viewModel.fetchInitialPokemons()
            }
        }
    }
}

struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        // use um usuário fictício aqui apenas para preview
        PokemonListView(user: User(username: "preview", email: "x@x.com", passwordHash: "hash"))
    }
}
