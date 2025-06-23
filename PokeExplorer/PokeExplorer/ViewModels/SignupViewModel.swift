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
    
    // MUDANÇA 1: Adiciona uma propriedade para o serviço de persistência.
    private let persistenceService: PersistenceServiceProtocol
    
    // MUDANÇA 2: O init agora recebe a dependência.
    init(persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
    // MUDANÇA 3: A função signUp agora usa a dependência interna e não recebe parâmetros.
    func signUp() {
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
