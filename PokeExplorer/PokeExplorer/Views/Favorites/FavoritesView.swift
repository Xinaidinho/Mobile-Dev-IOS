import SwiftUI
import SwiftData

struct FavoriteGridItemView: View {
    let favorite: FavoritePokemon
    
    @State private var image: Image?

    private var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(favorite.pokemonID).png")
    }

    var body: some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } else {
                ProgressView()
                    .tint(AppColors.primaryRed)
                    .frame(width: 100, height: 100)
            }

            Text(favorite.name.capitalized)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.primaryText)
        }
        .padding(AppSpacing.small)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = spriteURL, image == nil else { return }
        
        var request = URLRequest(url: url)
        request.setValue("PokeExplorerApp", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        } catch {
            print("Falha ao carregar a imagem do favorito \(favorite.name): \(error.localizedDescription)")
        }
    }
}



struct FavoritesView: View {
    @Query private var favorites: [FavoritePokemon]
    let user: User
    
    @Environment(\.modelContext.container) private var modelContainer
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
                        // MUDANÇA AQUI: Reescrevemos o NavigationLink para uma sintaxe
                        // que é mais fácil para o compilador interpretar.
                        NavigationLink {
                            // Destination View
                            PokemonDetailView(
                                viewModel: PokemonDetailViewModel(
                                    pokemonURL: "https://pokeapi.co/api/v2/pokemon/\(favorite.pokemonID)/",
                                    user: user,
                                    modelContainer: modelContainer
                                ),
                                namespace: animationNamespace,
                                pokemon: Pokemon(
                                    name: favorite.name,
                                    url: "https://pokeapi.co/api/v2/pokemon/\(favorite.pokemonID)/"
                                )
                            )
                        } label: {
                            // Label View
                            FavoriteGridItemView(favorite: favorite)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Meus Favoritos")
    }
}
