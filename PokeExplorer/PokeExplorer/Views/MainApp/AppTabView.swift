import SwiftUI

struct AppTabView: View {
    let user: User
    
    var body: some View {
        TabView {
            // Aba 1: Lista de Pokémon
            NavigationStack {
                PokemonListView(user: user)
            }
            .tabItem {
                Label("Explorar", systemImage: "magnifyingglass")
            }
            
            // Aba 2: Favoritos
            NavigationStack {
                FavoritesView(user: user)
            }
            .tabItem {
                Label("Favoritos", systemImage: "star.fill")
            }
        }
    }
}
