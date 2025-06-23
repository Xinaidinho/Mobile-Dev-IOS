//
//  PokemonListViewModelTests.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/23/25.
//

import XCTest
@testable import PokeExplorer

@MainActor
final class PokemonListViewModelTests: XCTestCase {

    // MARK: - Properties

    private var viewModel: PokemonListViewModel!
    private var mockApiService: MockAPIService!

    // MARK: - Setup & Teardown

    /// Este método é chamado antes de cada teste.
    /// Perfeito para criar nossos objetos e garantir um estado limpo.
    override func setUp() {
        super.setUp()
        // 1. Crie uma nova instância do nosso mock de API.
        mockApiService = MockAPIService()
        // 2. Crie o ViewModel, injetando o mock.
        viewModel = PokemonListViewModel(api: mockApiService)
    }

    /// Este método é chamado após a conclusão de cada teste.
    /// Usamos para limpar os objetos.
    override func tearDown() {
        viewModel = nil
        mockApiService = nil
        super.tearDown()
    }

    // MARK: - Test Cases

    /// Testa se o ViewModel busca e carrega a lista inicial de Pokémon com sucesso.
    func testFetchInitialPokemons_WhenSuccessful() async {
        // Given (Dado)
        // O mock já está configurado para ter sucesso por padrão.
        let expectedPokemonCount = mockApiService.mockPokemonResponse.results.count

        // When (Quando)
        await viewModel.fetchInitialPokemons()

        // Then (Então)
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.errorMessage, "errorMessage deveria ser nulo em um cenário de sucesso.")
        XCTAssertEqual(viewModel.pokemons.count, expectedPokemonCount, "O número de Pokémon carregados deve ser o esperado.")
        XCTAssertEqual(viewModel.pokemons.first?.name, "bulbasaur", "O primeiro Pokémon deve ser o esperado.")
    }

    /// Testa se o ViewModel lida com um erro de API corretamente.
    func testFetchInitialPokemons_WhenFailure() async {
        // Given
        mockApiService.shouldSucceed = false
        let expectedError = URLError(.notConnectedToInternet)
        mockApiService.errorToThrow = expectedError

        // When
        await viewModel.fetchInitialPokemons()

        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertTrue(viewModel.pokemons.isEmpty, "A lista de pokémons deveria estar vazia em caso de falha.")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage não deveria ser nulo.")
        XCTAssertEqual(viewModel.errorMessage, expectedError.localizedDescription, "A mensagem de erro não é a esperada.")
    }
    
    /// Testa a lógica de paginação (carregar mais).
    func testLoadMorePokemons_AppendsToList() async {
        // Given
        // Primeiro, carregamos a lista inicial.
        await viewModel.fetchInitialPokemons()
        let initialCount = viewModel.pokemons.count
        
        // Configuramos uma nova resposta do mock para a segunda chamada
        let newPokemonList = [
            Pokemon(name: "charmander", url: "https://pokeapi.co/api/v2/pokemon/4/"),
            Pokemon(name: "squirtle", url: "https://pokeapi.co/api/v2/pokemon/7/")
        ]
        mockApiService.mockPokemonResponse = PokemonResponse(
            count: 4, next: nil, previous: "prev_url", results: newPokemonList
        )
        
        let expectedTotalCount = initialCount + newPokemonList.count

        // When
        await viewModel.loadMorePokemons()
        
        // Then
        XCTAssertEqual(viewModel.pokemons.count, expectedTotalCount, "A nova lista de pokémons não foi anexada corretamente.")
        XCTAssertEqual(viewModel.pokemons.last?.name, "squirtle", "O último pokémon não é o esperado após a paginação.")
    }
}
