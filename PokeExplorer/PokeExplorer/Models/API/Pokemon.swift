import Foundation

// MARK: — Pokémon básico da listagem
/// Representa um Pokémon na listagem inicial (nome + URL para detalhes).
struct Pokemon: Codable, Identifiable, Hashable {
    let name: String
    let url: String

    /// Extrai o ID (numérico) a partir da URL.
    var id: Int {
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return Int(trimmed.split(separator: "/").last!)!
    }

    /// URL para o sprite pequeno (2D) oficial do Pokémon.
    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }

    /// URL para o official artwork (imagem maior) do Pokémon.
    var officialArtworkURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}

// MARK: — Resposta paginada da API
/// Estrutura que representa a resposta da listagem de Pokémons com paginação.
struct PokemonResponse: Codable {
    let count: Int      // total de resultados disponíveis
    let next: String?   // URL para a próxima página
    let previous: String? // URL para a página anterior
    let results: [Pokemon] // lista de Pokémons
}

// MARK: — Detalhes de um Pokémon
/// Estrutura que representa os detalhes completos de um Pokémon.
struct PokemonDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int      // altura em decímetros
    let weight: Int      // peso em hectogramas
    let types: [PokemonTypeEntry]
    let stats: [PokemonStatEntry]
    let sprites: PokemonSprites

    /// Tipo e slot de cada entrada de tipo
    struct PokemonTypeEntry: Codable {
        let slot: Int
        let type: NamedAPIResource
    }

    /// Estatísticas base do Pokémon
    struct PokemonStatEntry: Codable {
        let baseStat: Int
        let effort: Int
        let stat: NamedAPIResource
    }
}

// MARK: — Recurso genérico de nome + URL
/// Usado por tipos, estatísticas, habilidades e movimentos.
struct NamedAPIResource: Codable {
    let name: String
    let url: String
}

// MARK: — Sprites (apenas official-artwork)
/// Modelagem simplificada dos sprites, focando no official artwork.
struct PokemonSprites: Codable {
    let other: OtherSprites?

    struct OtherSprites: Codable {
        let officialArtwork: Artwork
        enum CodingKeys: String, CodingKey { case officialArtwork = "official-artwork" }

        struct Artwork: Codable {
            let frontDefault: String?   // URL da imagem
            enum CodingKeys: String, CodingKey { case frontDefault = "front_default" }
        }
    }
}
