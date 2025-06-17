//
//  Pokemon.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import Foundation

// Esta struct representa a resposta completa da API quando pedimos a lista de Pokémon.
struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pokemon]
}

// Esta struct representa um único Pokémon na lista.
// Conforma com Codable para decodificação do JSON.
// Conforma com Identifiable e Hashable para ser usado facilmente em listas SwiftUI.
struct Pokemon: Codable, Identifiable, Hashable {
    // A API não nos dá um ID na lista, então geramos um UUID para o SwiftUI.
    let id = UUID()
    let name: String
    let url: String

    // Propriedade computada para extrair o ID do Pokémon da URL.
    // Ex: "https://pokeapi.co/api/v2/pokemon/25/" -> 25
    // Isso será muito útil para buscar a imagem oficial.
    var pokemonID: Int? {
        return Int(url.split(separator: "/").last?.description ?? "0")
    }

    // Propriedade computada para obter a URL da imagem oficial de alta qualidade.
    var officialArtworkURL: URL? {
        guard let pokemonID = pokemonID else { return nil }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonID).png")
    }
    
    // Necessário para que o compilador ignore 'id' durante a decodificação do JSON.
    enum CodingKeys: String, CodingKey {
        case name, url
    }
}
