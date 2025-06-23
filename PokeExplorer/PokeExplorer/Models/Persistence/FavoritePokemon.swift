//
//  FavoritePokemon.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import Foundation
import SwiftData

// Modelo de dados que representa um Pokémon favoritado por um usuário
@Model
final class FavoritePokemon {
    /// Usamos o ID do Pokémon da PokéAPI como nosso identificador único para evitar duplicatas.
    @Attribute(.unique) var pokemonID: Int
    
    var name: String
    var imageUrl: String? // Opcional, caso a imagem não esteja disponível
    var favoritedDate: Date
    
    /// Relação inversa: a qual usuário este favorito pertence.
    var user: User?
    
    /// Inicializador padrão do favorito
    init(pokemonID: Int, name: String, imageUrl: String?) {
        self.pokemonID = pokemonID
        self.name = name
        self.imageUrl = imageUrl
        self.favoritedDate = .now
    }
}
