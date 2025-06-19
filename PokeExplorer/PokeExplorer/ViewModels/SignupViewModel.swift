import SwiftUI
import SwiftData

@MainActor
class SignupViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var didSignUpSuccessfully = false
    
    init() {}
    
    // 1. A função signUp agora recebe o ModelContainer
    func signUp(modelContainer: ModelContainer) {
        // Cria o serviço com o container recebido
        let persistenceService = PersistenceService(modelContainer: modelContainer)
        
        guard password == confirmPassword else {
            errorMessage = "As senhas não coincidem."
            return
        }
        
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Todos os campos são obrigatórios."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 2. A chamada assíncrona ao serviço de cadastro está dentro de uma Task
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
