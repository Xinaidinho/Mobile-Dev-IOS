//
//  APIServiceProtocol.swift
//  PokeExplorer
//
//  Created by user276522 on 6/23/25.
//

import Foundation

/// Define o contrato para o serviço de API.
/// Usar um protocolo nos permite injetar uma implementação falsa (mock)
/// durante os testes, isolando os ViewModels das chamadas de rede reais.
protocol APIServiceProtocol {
    
    /// Busca a lista paginada de Pokémon.
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonResponse
    
    /// Busca os detalhes de um Pokémon a partir de uma URL completa.
    func fetchPokemonDetail(from urlString: String) async throws -> PokemonDetail
}
