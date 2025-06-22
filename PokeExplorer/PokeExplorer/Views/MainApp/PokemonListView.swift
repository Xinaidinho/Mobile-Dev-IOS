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
                        // 1) Use a forma com closures para destino e label
                        NavigationLink {
                            // 2) Quebre em sub-expressões
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
                            VStack {
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
