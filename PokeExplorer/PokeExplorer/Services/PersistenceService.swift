//
//  PersistenceService.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import Foundation
import SwiftData

/// Define erros específicos para o serviço de persistência para um tratamento mais claro.
enum PersistenceError: LocalizedError {
    case userNotFound
    case wrongPassword
    case userAlreadyExists
    case favoriteAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .userNotFound: "Usuário não encontrado."
        case .wrongPassword: "Senha incorreta."
        case .userAlreadyExists: "Este nome de usuário já está em uso."
        case .favoriteAlreadyExists: "Este Pokémon já está nos seus favoritos."
        }
    }
}

@MainActor
class PersistenceService {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - User Authentication
    
    func signUp(username: String, email: String, password: String) throws {
        // 1. Verifica se o usuário já existe
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        let existingUsers = try modelContext.fetch(descriptor)
        
        guard existingUsers.isEmpty else {
            throw PersistenceError.userAlreadyExists
        }
        
        // 2. Criptografa a senha
        let passwordHash = try PasswordHasher.hash(password: password)
        
        // 3. Cria e salva o novo usuário
        let newUser = User(username: username, email: email, passwordHash: passwordHash)
        modelContext.insert(newUser)
        try modelContext.save()
    }
    
    func login(username: String, password: String) throws -> User {
        // 1. Busca o usuário pelo nome
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        let users = try modelContext.fetch(descriptor)
        
        guard let user = users.first else {
            throw PersistenceError.userNotFound
        }
        
        // 2. Verifica a senha
        guard PasswordHasher.verify(password: password, against: user.passwordHash) else {
            throw PersistenceError.wrongPassword
        }
        
        // 3. Retorna o usuário se tudo estiver correto
        return user
    }
    
    // MARK: - Favorites Management
    
    func addFavorite(pokemonDetail: PokemonDetail, for user: User) throws {
        // 1. Verifica se o favorito já existe para este usuário
        let pokemonID = pokemonDetail.id
        if user.favoritePokemons.contains(where: { $0.pokemonID == pokemonID }) {
            throw PersistenceError.favoriteAlreadyExists
        }
        
        // 2. Cria o novo favorito
        let newFavorite = FavoritePokemon(
            pokemonID: pokemonDetail.id,
            name: pokemonDetail.name,
            imageUrl: pokemonDetail.sprites.other?.officialArtwork.front_default
        )
        
        // 3. Associa ao usuário e salva
        newFavorite.user = user
        modelContext.insert(newFavorite)
        try modelContext.save()
    }
    
    func removeFavorite(pokemonID: Int, from user: User) throws {
        guard let favoriteToRemove = user.favoritePokemons.first(where: { $0.pokemonID == pokemonID }) else {
            return // Se não encontrar, não faz nada
        }
        
        modelContext.delete(favoriteToRemove)
        try modelContext.save()
    }
    
    func isFavorite(pokemonID: Int, for user: User) -> Bool {
        user.favoritePokemons.contains(where: { $0.pokemonID == pokemonID })
    }
}
