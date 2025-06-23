import SwiftUI
import SwiftData

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var authenticatedUser: User?
    
    private var persistenceService: PersistenceServiceProtocol
    
    // O init do app continua funcionando como antes.
    init(modelContainer: ModelContainer) {
        self.persistenceService = PersistenceService(modelContainer: modelContainer)
    }
    
    // O init para os testes.
    init(persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
    // MUDANÇA: A função agora é `async` para que possamos esperá-la nos testes.
    func login() async {
        isLoading = true
        errorMessage = nil
        
        // O `Task` não é mais necessário aqui, pois a própria função já é um contexto assíncrono.
        do {
            let user = try await self.persistenceService.login(username: self.username, password: self.password)
            self.authenticatedUser = user
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro desconhecido."
        }
        
        self.isLoading = false
    }
}
