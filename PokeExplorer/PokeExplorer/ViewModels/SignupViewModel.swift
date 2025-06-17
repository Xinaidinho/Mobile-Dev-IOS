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
    
    // O init agora é vazio e padrão.
    init() {}
    
    // A função signUp AGORA RECEBE o modelContext como parâmetro.
    func signUp(context: ModelContext) {
        // A persistenceService é criada aqui, apenas quando necessária.
        let persistenceService = PersistenceService(modelContext: context)
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try persistenceService.signUp(username: self.username, email: self.email, password: self.password)
                self.didSignUpSuccessfully = true
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro desconhecido."
            }
            self.isLoading = false
        }
    }
}
