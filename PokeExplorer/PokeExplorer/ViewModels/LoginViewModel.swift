import SwiftUI
import SwiftData

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var authenticatedUser: User?
    
    private var persistenceService: PersistenceService
    
    // 1. O init agora recebe um ModelContainer
    init(modelContainer: ModelContainer) {
        self.persistenceService = PersistenceService(modelContainer: modelContainer)
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        // 2. A chamada assíncrona ao serviço de login agora está dentro de uma Task
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
