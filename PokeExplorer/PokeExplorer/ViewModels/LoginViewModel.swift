// Importa frameworks necessários
import SwiftUI
import SwiftData

// ViewModel responsável pela lógica de autenticação do usuário
@MainActor
class LoginViewModel: ObservableObject {
    // Campos do formulário de login
    @Published var username = ""
    @Published var password = ""
    // Mensagem de erro exibida na tela
    @Published var errorMessage: String?
    // Indica se o login está em andamento
    @Published var isLoading = false
    // Usuário autenticado, se o login for bem-sucedido
    @Published var authenticatedUser: User?
    
    // Serviço de persistência para autenticação
    private var persistenceService: PersistenceServiceProtocol
    
    // Inicializador padrão usado no app
    init(modelContainer: ModelContainer) {
        self.persistenceService = PersistenceService(modelContainer: modelContainer)
    }
    
    // Inicializador alternativo para testes
    init(persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
    // Função assíncrona para realizar o login do usuário
    func login() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await self.persistenceService.login(username: self.username, password: self.password)
            self.authenticatedUser = user
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro desconhecido."
        }
        
        self.isLoading = false
    }
}
