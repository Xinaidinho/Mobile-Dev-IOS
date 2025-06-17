import SwiftUI
import SwiftData

@MainActor
class LoginViewModel: ObservableObject {
    // Propriedades que a View vai observar
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var authenticatedUser: User?
    
    private var persistenceService: PersistenceService
    
    init(modelContext: ModelContext) {
        self.persistenceService = PersistenceService(modelContext: modelContext)
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        // Simula um pequeno atraso para a animação de loading ser visível
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let user = try self.persistenceService.login(username: self.username, password: self.password)
                self.authenticatedUser = user
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro desconhecido."
            }
            
            self.isLoading = false
        }
    }
}
