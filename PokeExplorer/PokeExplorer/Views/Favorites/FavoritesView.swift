import SwiftUI
import SwiftData

// Passo 1: Criamos uma nova View auxiliar para representar um único item da grade.
// Isso simplifica drasticamente a View principal.
struct FavoriteGridItemView: View {
    let favorite: FavoritePokemon

    var body: some View {
        VStack {
            // Usamos os Design Tokens para manter a consistência
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
    
    init(user: User) {
        let userID = user.username
        _favorites = Query(filter: #Predicate { $0.user?.username == userID }, sort: \.favoritedDate, order: .reverse)
    }
    
    let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        // O ScrollView e o navigationTitle continuam aqui
        ScrollView {
            // A lógica do if/else para o caso de a lista estar vazia
            if favorites.isEmpty {
                Text("Você ainda não tem Pokémon favoritos.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // A LazyVGrid agora chama a nossa View auxiliar.
                // O compilador consegue analisar isso facilmente.
                LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                    ForEach(favorites) { favorite in
                        FavoriteGridItemView(favorite: favorite)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Meus Favoritos")
    }
}
