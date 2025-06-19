import Foundation
import SwiftData

enum PersistenceError: LocalizedError {
    case userNotFound
    case wrongPassword
    case userAlreadyExists
    case favoriteAlreadyExists

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Usuário não encontrado."
        case .wrongPassword:
            return "Senha incorreta."
        case .userAlreadyExists:
            return "Este nome de usuário já está em uso."
        case .favoriteAlreadyExists:
            return "Este Pokémon já está nos seus favoritos."
        }
    }
}

// O serviço não precisa mais ser @MainActor
class PersistenceService {
    // 1. Armazene o ModelContainer, que é thread-safe.
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // --- Métodos de Autenticação (agora são async) ---
    
    func signUp(username: String, email: String, password: String) async throws {
        // Crie um contexto em background para esta operação
        let context = ModelContext(modelContainer)
        
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        let existingUsers = try context.fetch(descriptor)

        guard existingUsers.isEmpty else {
            throw PersistenceError.userAlreadyExists
        }

        let passwordHash = PasswordHasher.hash(password)
        let newUser = User(username: username, email: email, passwordHash: passwordHash)
        context.insert(newUser)
        try context.save()
    }

    func login(username: String, password: String) async throws -> User {
        // Crie um contexto em background para esta operação
        let context = ModelContext(modelContainer)
        
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        guard let user = try context.fetch(descriptor).first else {
            throw PersistenceError.userNotFound
        }

        guard PasswordHasher.verify(password, against: user.passwordHash) else {
            throw PersistenceError.wrongPassword
        }
        return user
    }

    // --- Métodos de Favoritos (agora são async) ---

    func addFavorite(pokemonDetail: PokemonDetail, for user: User) async throws {
        // Crie um contexto em background para esta operação de escrita
        let context = ModelContext(modelContainer)

        // Busque a instância do usuário *neste contexto específico* para criar a relação
        let userID = user.username
        let userDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == userID })
        guard let userInContext = try context.fetch(userDescriptor).first else {
            throw PersistenceError.userNotFound
        }

        let newFavorite = FavoritePokemon(
            pokemonID: pokemonDetail.id,
            name: pokemonDetail.name,
            imageUrl: pokemonDetail.sprites.other?.officialArtwork.frontDefault
        )
        
        newFavorite.user = userInContext
        context.insert(newFavorite)
        try context.save()
    }

    func removeFavorite(pokemonID: Int, from user: User) async throws {
        // Crie um contexto em background para esta operação de escrita
        let context = ModelContext(modelContainer)
        
        let userID = user.username
        let predicate = #Predicate<FavoritePokemon> { favorite in
            favorite.pokemonID == pokemonID && favorite.user?.username == userID
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let favoriteToRemove = try context.fetch(descriptor).first {
            context.delete(favoriteToRemove)
            try context.save()
        }
    }

    func isFavorite(pokemonID: Int, for user: User) async -> Bool {
        // Crie um contexto em background para esta operação de leitura
        let context = ModelContext(modelContainer)
        
        let userID = user.username
        let predicate = #Predicate<FavoritePokemon> { favorite in
            favorite.pokemonID == pokemonID && favorite.user?.username == userID
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let count = try context.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Falha ao buscar o status de favorito: \(error)")
            return false
        }
    }
}
