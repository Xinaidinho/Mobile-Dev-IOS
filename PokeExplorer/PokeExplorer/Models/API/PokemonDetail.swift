//
//  PokemonDetail.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import Foundation

// Representa a estrutura completa dos detalhes de um Pokémon.
struct PokemonDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int // Altura em decímetros
    let weight: Int // Peso em hectogramas
    let types: [TypeElement]
    let sprites: Sprites
    let abilities: [AbilityElement]
    let moves: [MoveElement]
    let stats: [StatElement]
}

// Sub-estruturas para organizar os dados aninhados do JSON.

struct AbilityElement: Codable, Hashable {
    let ability: Species
}

struct MoveElement: Codable, Hashable {
    let move: Species
}

struct Sprites: Codable {
    // A API usa "snake_case". O decoder cuidará da conversão.
    let front_default: String
    let other: OtherSprites?
}

struct OtherSprites: Codable {
    let officialArtwork: OfficialArtwork
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let front_default: String
}

struct StatElement: Codable, Hashable {
    let base_stat: Int
    let stat: Species
}

struct TypeElement: Codable, Hashable {
    let slot: Int
    let type: Species
}

// Uma struct genérica usada por Abilities, Moves, Stats e Types.
struct Species: Codable, Hashable {
    let name: String
    let url: String
}
