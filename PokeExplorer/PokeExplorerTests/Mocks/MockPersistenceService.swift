//
//  MockPersistenceService.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/19/25.
//

import Foundation
@testable import PokeExplorer // Importa o módulo principal para acessar os tipos

/// Uma implementação "mock" (falsa) do PersistenceServiceProtocol para uso em testes de unidade.
/// Esta classe nos permite simular cenários de sucesso e falha sem tocar no banco de dados real.
final class MockPersistenceService: PersistenceServiceProtocol {
    
    // MARK: - Properties to Control Behavior
    
    /// Define se as chamadas de login/signup devem ter sucesso ou falhar.
    var shouldSucceed: Bool = true
    
    /// O erro a ser lançado quando `shouldSucceed` for `false`.
    var errorToThrow: Error = PersistenceError.userNotFound
    
    /// Um usuário falso para ser retornado em chamadas bem-sucedidas.
    lazy var mockUser = User(username: "mockUser", email: "mock@email.com", passwordHash: "mockHash")
    
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
    
    // --- Funções de Favoritos (não necessárias para testes de Login/Signup) ---
    // Podemos deixar implementações vazias ou que lancem um erro se forem chamadas inesperadamente.
    
    func addFavorite(pokemonDetail: PokemonDetail, for user: User) async throws {
        // Não implementado para este mock
    }
    
    func removeFavorite(pokemonID: Int, from user: User) async throws {
        // Não implementado para este mock
    }
    
    func isFavorite(pokemonID: Int, for user: User) async -> Bool {
        return false // Não implementado para este mock
    }
}
