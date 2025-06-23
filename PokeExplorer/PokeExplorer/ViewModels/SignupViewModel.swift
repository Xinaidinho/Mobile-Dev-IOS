// Importa frameworks necessários
import SwiftUI
import SwiftData

// ViewModel responsável pela lógica de cadastro de novos usuários
@MainActor
class SignupViewModel: ObservableObject {
    // Campos do formulário de cadastro
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    // Mensagem de erro exibida na tela
    @Published var errorMessage: String?
    // Indica se o cadastro está em andamento
    @Published var isLoading = false
    // Indica se o cadastro foi realizado com sucesso
    @Published var didSignUpSuccessfully = false
    
    // Serviço de persistência para salvar o novo usuário
    private let persistenceService: PersistenceServiceProtocol
    
    // Inicializador recebe a dependência do serviço de persistência
    init(persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
    // Função para realizar o cadastro do usuário
    func signUp() {
        // Valida se as senhas coincidem
        guard password == confirmPassword else {
            errorMessage = "As senhas não coincidem."
            return
        }
        
        // Valida se todos os campos estão preenchidos
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Todos os campos são obrigatórios."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Executa o cadastro de forma assíncrona
        Task {
            do {
                try await persistenceService.signUp(username: self.username, email: self.email, password: self.password)
                self.didSignUpSuccessfully = true
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro desconhecido."
            }
            self.isLoading = false
        }
    }
}
