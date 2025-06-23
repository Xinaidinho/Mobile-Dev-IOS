// Importa frameworks necessários
import SwiftUI
import SwiftData

// View para exibir um card individual de Pokémon favorito
struct FavoriteGridItemView: View {
    // Pokémon favorito a ser exibido
    let favorite: FavoritePokemon
    
    // Estado para armazenar a imagem carregada
    @State private var image: Image?

    // URL do sprite do Pokémon favorito
    private var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(favorite.pokemonID).png")
    }

    var body: some View {
        VStack {
            // Exibe a imagem do favorito, se carregada
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } else {
                // Placeholder enquanto a imagem carrega
                ProgressView()
                    .tint(AppColors.primaryRed)
                    .frame(width: 100, height: 100)
            }

            // Nome do Pokémon favorito
            Text(favorite.name.capitalized)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.primaryText)
        }
        .padding(AppSpacing.small)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        // Carrega a imagem ao exibir o card
        .task {
            await loadImage()
        }
    }
    
    // Função assíncrona para buscar a imagem do favorito
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

// View responsável por exibir a lista de Pokémons favoritos do usuário
struct FavoritesView: View {
    // Query para buscar os favoritos do usuário
    @Query private var favorites: [FavoritePokemon]
    // Usuário logado
    let user: User
    
    // Acesso ao container de dados do SwiftData
    @Environment(\.modelContext.container) private var modelContainer
    // Namespace para animações
    @Namespace private var animationNamespace
    
    // Inicializador que filtra os favoritos pelo usuário
    init(user: User) {
        self.user = user
        let userID = user.username
        _favorites = Query(filter: #Predicate { $0.user?.username == userID }, sort: \.favoritedDate, order: .reverse)
    }
    
    // Layout das colunas do grid
    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        ScrollView {
            if favorites.isEmpty {
                // Mensagem caso não haja favoritos
                Text("Você ainda não tem Pokémon favoritos.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Grid de favoritos
                LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                    ForEach(favorites) { favorite in
                        // Cada card é um NavigationLink para a tela de detalhes
                        NavigationLink {
                            // Tela de detalhes do favorito
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
                            // Card do favorito
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
