import SwiftUI
import SwiftData

@main
struct PokeExplorerApp: App {
    @StateObject private var loginViewModel: LoginViewModel
    private let modelContainer: ModelContainer
    
    init() {
        do {
            let container = try ModelContainer(for: User.self, FavoritePokemon.self)
            self.modelContainer = container
            // Passa o ModelContainer para o init do LoginViewModel
            _loginViewModel = StateObject(wrappedValue: LoginViewModel(modelContainer: container))
        } catch {
            fatalError("Não foi possível inicializar o ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginViewModel)
        }
        // Injeta o container no ambiente para que outras views possam usá-lo
        .modelContainer(modelContainer)
    }
}
