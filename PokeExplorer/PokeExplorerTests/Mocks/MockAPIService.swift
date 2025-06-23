//
//  MockAPIService.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/23/25.
//

import Foundation
@testable import PokeExplorer

/// Uma implementação "mock" do APIServiceProtocol para uso em testes de unidade.
/// Esta classe nos permite simular cenários de sucesso e falha da API
/// sem realizar chamadas de rede reais.
final class MockAPIService: APIServiceProtocol {

    // MARK: - Properties to Control Behavior

    /// Define se as chamadas de API devem ter sucesso ou falhar.
    var shouldSucceed: Bool = true

    /// O erro a ser lançado quando `shouldSucceed` for `false`.
    var errorToThrow: Error = URLError(.badServerResponse)

    /// Uma resposta falsa para ser retornada em chamadas bem-sucedidas de `fetchPokemonList`.
    lazy var mockPokemonResponse = PokemonResponse(
        count: 2,
        next: "next_url",
        previous: nil,
        results: [
            Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            Pokemon(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/")
        ]
    )
    
    /// Um detalhe de Pokémon falso para ser retornado (será útil para testes futuros).
    lazy var mockPokemonDetail = PokemonDetail(
        id: 1,
        name: "bulbasaur",
        height: 7,
        weight: 69,
        types: [],
        stats: [],
        sprites: .init(other: nil)
    )

    // MARK: - Protocol Conformance

    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonResponse {
        if shouldSucceed {
            return mockPokemonResponse
        } else {
            throw errorToThrow
        }
    }

    func fetchPokemonDetail(from urlString: String) async throws -> PokemonDetail {
        if shouldSucceed {
            return mockPokemonDetail
        } else {
            throw errorToThrow
        }
    }
}
