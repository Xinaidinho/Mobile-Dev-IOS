import SwiftUI
import SwiftData

@main
struct PokeExplorerApp: App {
    // Cria o ViewModel principal uma única vez aqui
    @StateObject private var loginViewModel: LoginViewModel
    
    init() {
        // Configura o container de dados
        let container = try! ModelContainer(for: User.self, FavoritePokemon.self)
        // Cria uma instância do contexto para injetar no ViewModel
        let modelContext = ModelContext(container)
        // Inicializa o StateObject com suas dependências
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(modelContext: modelContext))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Disponibiliza o ViewModel para todas as Views filhas
                .environmentObject(loginViewModel)
        }
        // Disponibiliza o ModelContainer para o @Query funcionar nas Views
        .modelContainer(for: [User.self, FavoritePokemon.self])
    }
}
