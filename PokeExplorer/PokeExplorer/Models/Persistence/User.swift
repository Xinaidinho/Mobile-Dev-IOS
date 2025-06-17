//
//  User.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import Foundation
import SwiftData

@Model
final class User {
    /// O nome de usuário, que deve ser único para cada usuário.
    @Attribute(.unique) var username: String
    
    var email: String
    
    /// A senha já criptografada (hash). NUNCA armazene senhas em texto puro.
    var passwordHash: String
    
    var registrationDate: Date
    
    /// Define a relação "um-para-muitos": um Usuário pode ter muitos Pokémon favoritos.
    /// A regra 'cascade' significa que se um usuário for deletado, todos os seus favoritos também serão.
    @Relationship(deleteRule: .cascade, inverse: \FavoritePokemon.user)
    var favoritePokemons: [FavoritePokemon] = []
    
    init(username: String, email: String, passwordHash: String) {
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.registrationDate = .now
    }
}
