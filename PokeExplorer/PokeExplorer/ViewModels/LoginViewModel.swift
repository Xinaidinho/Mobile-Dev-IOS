import SwiftUI
import SwiftData

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var authenticatedUser: User?
    
    // MUDANÇA AQUI: A propriedade agora é do tipo do protocolo.
    private var persistenceService: PersistenceServiceProtocol
    
    // O init do app continua funcionando como antes.
    init(modelContainer: ModelContainer) {
        self.persistenceService = PersistenceService(modelContainer: modelContainer)
    }
    
    // MUDANÇA AQUI: Adicionamos um init para os testes.
    init(persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await self.persistenceService.login(username: self.username, password: self.password)
                self.authenticatedUser = user
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro desconhecido."
            }
            
            self.isLoading = false
        }
    }
}
