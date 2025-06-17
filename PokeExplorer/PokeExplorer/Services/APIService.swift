//
//  APIService.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import Foundation

// Classe responsável por toda a comunicação com a PokéAPI.
class APIService {
    
    private let baseURL = "https://pokeapi.co/api/v2/"
    private let decoder: JSONDecoder
    
    init() {
        self.decoder = JSONDecoder()
        // Converte chaves do formato snake_case (ex: front_default) para camelCase (ex: frontDefault).
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Busca uma lista paginada de Pokémon.
    /// - Parameters:
    ///   - limit: O número de resultados por página.
    ///   - offset: O ponto inicial da lista.
    /// - Returns: Um objeto `PokemonResponse` contendo a lista.
    /// - Throws: Um erro se a requisição de rede ou a decodificação falhar.
    func fetchPokemonList(limit: Int = 20, offset: Int) async throws -> PokemonResponse {
        let urlString = "\(baseURL)pokemon?limit=\(limit)&offset=\(offset)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Realiza a chamada de rede de forma assíncrona.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decodifica a resposta JSON no nosso modelo `PokemonResponse`.
        let decodedResponse = try decoder.decode(PokemonResponse.self, from: data)
        return decodedResponse
    }
    
    /// Busca os detalhes completos de um Pokémon específico usando sua URL.
    /// - Parameter urlString: A URL completa para o recurso do Pokémon.
    /// - Returns: Um objeto `PokemonDetail`.
    /// - Throws: Um erro se a requisição de rede ou a decodificação falhar.
    func fetchPokemonDetails(from urlString: String) async throws -> PokemonDetail {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedDetail = try decoder.decode(PokemonDetail.self, from: data)
        return decodedDetail
    }
}
