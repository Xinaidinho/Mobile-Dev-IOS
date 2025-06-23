//
//  MockPersistenceService.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/19/25.
//

import Foundation
@testable import PokeExplorer

/// Uma implementação "mock" (falsa) do PersistenceServiceProtocol para uso em testes de unidade.
/// Esta classe nos permite simular cenários de sucesso e falha sem tocar no banco de dados real.
final class MockPersistenceService: PersistenceServiceProtocol {
    
    // MARK: - Properties to Control Behavior
    
    /// Define se as chamadas devem ter sucesso ou falhar.
    var shouldSucceed: Bool = true
    
    /// O erro a ser lançado quando `shouldSucceed` for `false`.
    var errorToThrow: Error = PersistenceError.userNotFound
    
    /// Um usuário falso para ser retornado em chamadas bem-sucedidas.
    lazy var mockUser = User(username: "mockUser", email: "mock@email.com", passwordHash: "mockHash")
    
    /// Um Set para simular o banco de dados de favoritos em memória.
    private var favoritedPokemonIDs = Set<Int>()
    
    // MARK: - Protocol Conformance
    
    func signUp(username: String, email: String, password: String) async throws {
        if !shouldSucceed {
            throw errorToThrow
        }
        // Em um cenário de sucesso, não fazemos nada, apenas retornamos.
    }
    
    func login(username: String, password: String) async throws -> User {
        if shouldSucceed {
            return mockUser
        } else {
            throw errorToThrow
        }
    }
    
    // MARK: - Favorite Functions Implementation
    
    func addFavorite(pokemonDetail: PokemonDetail, for user: User) async throws {
        if !shouldSucceed { throw errorToThrow }
        
        // Simula a adição do ID do Pokémon ao nosso banco de dados em memória.
        favoritedPokemonIDs.insert(pokemonDetail.id)
    }
    
    func removeFavorite(pokemonID: Int, from user: User) async throws {
        if !shouldSucceed { throw errorToThrow }
        
        // Simula a remoção do ID do Pokémon do nosso banco de dados em memória.
        favoritedPokemonIDs.remove(pokemonID)
    }
    
    func isFavorite(pokemonID: Int, for user: User) async -> Bool {
        // Simula a verificação, retornando true se o ID estiver no nosso banco de dados.
        return favoritedPokemonIDs.contains(pokemonID)
    }
}
