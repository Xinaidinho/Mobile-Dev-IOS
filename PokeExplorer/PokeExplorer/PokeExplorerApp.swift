import SwiftUI
import SwiftData

// Ponto de entrada principal do aplicativo
// O atributo @main identifica esta struct como o ponto de inicialização do app
@main
struct PokeExplorerApp: App {
    // StateObject para gerenciar o estado de login em todo o app
    // Garante que o estado de login persista enquanto o app estiver em execução
    @StateObject private var loginViewModel: LoginViewModel
    
    // Instância do ModelContainer para gerenciar o armazenamento com SwiftData
    // Este container armazena os modelos de dados para Usuários e Pokémons Favoritos
    private let modelContainer: ModelContainer
    
    // Inicializador para configurar as dependências necessárias do app
    init() {
        do {
            // Cria um ModelContainer capaz de armazenar entidades User e FavoritePokemon
            let container = try ModelContainer(for: User.self, FavoritePokemon.self)
            self.modelContainer = container
            
            // Inicializa o LoginViewModel com o ModelContainer
            // Utiliza StateObject para manter o estado do view model durante o ciclo de vida do app
            _loginViewModel = StateObject(wrappedValue: LoginViewModel(modelContainer: container))
        } catch {
            // Se a inicialização do container falhar, encerra o app com uma mensagem de erro
            // Isso é crítico, pois o app não pode funcionar sem o armazenamento de dados
            fatalError("Não foi possível inicializar o ModelContainer: \(error.localizedDescription)")
        }
    }

    // Define a estrutura de cenas do app
    var body: some Scene {
        WindowGroup {
            // Define ContentView como a view raiz do aplicativo
            ContentView()
                // Torna loginViewModel acessível para todas as views filhas através do ambiente
                .environmentObject(loginViewModel)
        }
        // Torna o ModelContainer disponível em toda a hierarquia de views do app
        // Isso permite que qualquer view acesse e modifique os dados persistentes
        .modelContainer(modelContainer)
    }
}
