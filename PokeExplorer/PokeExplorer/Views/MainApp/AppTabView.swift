// Importa o framework SwiftUI para construção da interface
import SwiftUI

// View responsável por exibir as abas principais do aplicativo
struct AppTabView: View {
    // Usuário logado, passado como parâmetro
    let user: User
    
    var body: some View {
        TabView {
            // Aba 1: Lista de Pokémon para explorar
            NavigationStack {
                PokemonListView(user: user)
            }
            .tabItem {
                Label("Explorar", systemImage: "magnifyingglass")
            }
            
            // Aba 2: Lista de favoritos do usuário
            NavigationStack {
                FavoritesView(user: user)
            }
            .tabItem {
                Label("Favoritos", systemImage: "star.fill")
            }
        }
    }
}
