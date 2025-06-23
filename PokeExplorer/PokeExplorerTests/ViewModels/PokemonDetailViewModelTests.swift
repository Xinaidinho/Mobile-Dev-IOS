//
//  PokemonDetailViewModelTests.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/23/25.
//

import XCTest
@testable import PokeExplorer

@MainActor
final class PokemonDetailViewModelTests: XCTestCase {

    // MARK: - Properties

    private var viewModel: PokemonDetailViewModel!
    private var mockApiService: MockAPIService!
    private var mockPersistenceService: MockPersistenceService!
    private var mockUser: User!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockApiService = MockAPIService()
        mockPersistenceService = MockPersistenceService()
        mockUser = mockPersistenceService.mockUser

        // Injetamos todos os mocks no ViewModel durante a inicialização
        viewModel = PokemonDetailViewModel(
            pokemonURL: "https://pokeapi.co/api/v2/pokemon/1/",
            user: mockUser,
            api: mockApiService,
            service: mockPersistenceService
        )
    }

    override func tearDown() {
        viewModel = nil
        mockApiService = nil
        mockPersistenceService = nil
        mockUser = nil
        super.tearDown()
    }

    // MARK: - Test Cases

    /// Testa o carregamento bem-sucedido dos detalhes do Pokémon.
    func testFetchDetail_WhenSuccessful() async {
        // Given
        let expectedPokemonName = mockApiService.mockPokemonDetail.name

        // When
        // A busca é chamada no init, então precisamos aguardar sua conclusão.
        // Adicionamos uma pequena espera para dar tempo para a Task do ViewModel rodar.
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos

        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.errorMessage, "errorMessage deveria ser nulo.")
        XCTAssertNotNil(viewModel.detail, "O detalhe do Pokémon não deveria ser nulo.")
        XCTAssertEqual(viewModel.detail?.name, expectedPokemonName, "O nome do Pokémon não é o esperado.")
    }

    /// Testa se o status de favorito é verificado corretamente no carregamento (e é falso por padrão).
    func testCheckIfFavorited_OnLoad_IsInitiallyFalse() async {
        // Given: O mock de persistência começa sem nenhum favorito por padrão.
        
        // When: A busca e a verificação ocorrem no init do ViewModel.
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(viewModel.isFavorited, "O Pokémon não deveria estar favoritado inicialmente.")
    }

    /// Testa a adição de um Pokémon aos favoritos.
    func testToggleFavorite_AddsToFavorites() async {
        // Given
        // Garante que o detalhe foi carregado e o Pokémon não está favoritado.
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertFalse(viewModel.isFavorited, "Pré-condição: O Pokémon não deve estar favoritado.")

        // When
        viewModel.toggleFavorite()
        // Espera a conclusão da tarefa de favoritar
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(viewModel.isFavorited, "O Pokémon deveria ter sido adicionado aos favoritos.")
        let isNowFavoriteInPersistence = await mockPersistenceService.isFavorite(pokemonID: 1, for: mockUser)
        XCTAssertTrue(isNowFavoriteInPersistence, "O mock de persistência deveria registrar o Pokémon como favorito.")
    }

    /// Testa a remoção de um Pokémon dos favoritos.
    // MUDANÇA 1: Adicionamos `throws` à assinatura da função de teste.
    func testToggleFavorite_RemovesFromFavorites() async throws {
        // Given
        // Primeiro, adicionamos o pokémon aos favoritos para o estado inicial do teste.
        // MUDANÇA 2: Adicionamos `try` à chamada da função que pode lançar erro.
        try await mockPersistenceService.addFavorite(pokemonDetail: mockApiService.mockPokemonDetail, for: mockUser)
        
        // Recriamos o ViewModel para que ele carregue o novo estado inicial (já favoritado).
        viewModel = PokemonDetailViewModel(
            pokemonURL: "https://pokeapi.co/api/v2/pokemon/1/",
            user: mockUser,
            api: mockApiService,
            service: mockPersistenceService
        )
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.isFavorited, "Pré-condição: O Pokémon deve estar favoritado para este teste.")

        // When
        viewModel.toggleFavorite()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(viewModel.isFavorited, "O Pokémon deveria ter sido removido dos favoritos.")
        let isStillFavoriteInPersistence = await mockPersistenceService.isFavorite(pokemonID: 1, for: mockUser)
        XCTAssertFalse(isStillFavoriteInPersistence, "O mock de persistência não deveria mais ter o Pokémon como favorito.")
    }
}
