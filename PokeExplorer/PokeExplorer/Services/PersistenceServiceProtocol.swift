//
//  PersistenceServiceProtocol.swift
//  PokeExplorer
//
//  Created by user276522 on 6/19/25.
//

import Foundation

/// Define o contrato para o serviço de persistência de dados.
/// Usar um protocolo nos permite injetar implementações falsas (mocks)
/// durante os testes, isolando os ViewModels de dependências concretas como o SwiftData.
protocol PersistenceServiceProtocol {
    
    /// Realiza o cadastro de um novo usuário.
    func signUp(username: String, email: String, password: String) async throws
    
    /// Autentica um usuário existente.
    func login(username: String, password: String) async throws -> User
    
    /// Adiciona um Pokémon aos favoritos de um usuário.
    func addFavorite(pokemonDetail: PokemonDetail, for user: User) async throws
    
    /// Remove um Pokémon dos favoritos de um usuário.
    func removeFavorite(pokemonID: Int, from user: User) async throws
    
    /// Verifica se um Pokémon específico já foi favoritado por um usuário.
    func isFavorite(pokemonID: Int, for user: User) async -> Bool
}
