import SwiftUI
import SwiftData

// A View auxiliar 'FavoriteGridItemView' não precisa de alterações.
struct FavoriteGridItemView: View {
    let favorite: FavoritePokemon

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: favorite.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
                    .tint(AppColors.primaryRed)
            }
            .frame(width: 100, height: 100)
            
            Text(favorite.name.capitalized)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.primaryText)
        }
        .padding(AppSpacing.small)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


struct FavoritesView: View {
    @Query private var favorites: [FavoritePokemon]
    let user: User
    
    // 1. Obtenha o ModelContainer do ambiente para poder passá-lo para o ViewModel de detalhes.
    @Environment(\.modelContext.container) private var modelContainer
    
    // 2. Adicione um Namespace para a animação de transição, assim como na outra tela.
    @Namespace private var animationNamespace
    
    init(user: User) {
        self.user = user
        let userID = user.username
        _favorites = Query(filter: #Predicate { $0.user?.username == userID }, sort: \.favoritedDate, order: .reverse)
    }
    
    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        ScrollView {
            if favorites.isEmpty {
                Text("Você ainda não tem Pokémon favoritos.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                    ForEach(favorites) { favorite in
                        // 3. Envolva o item do grid em um NavigationLink.
                        NavigationLink(destination:
                            // A tela de destino é a mesma PokemonDetailView.
                            PokemonDetailView(
                                viewModel: PokemonDetailViewModel(
                                    // 4. Construímos a URL necessária a partir do ID salvo no favorito.
                                    pokemonURL: "https://pokeapi.co/api/v2/pokemon/\(favorite.pokemonID)/",
                                    user: user,
                                    modelContainer: modelContainer
                                ),
                                namespace: animationNamespace
                            )
                        ) {
                            FavoriteGridItemView(favorite: favorite)
                        }
                        // Estilo para garantir que o link não mude a cor do texto dentro do card.
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Meus Favoritos")
    }
}
