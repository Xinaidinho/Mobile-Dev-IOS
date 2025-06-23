//
//  LoginViewModelTests.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/19/25.
//

import XCTest
import Combine // Necessário para observar as mudanças da propriedade @Published
@testable import PokeExplorer

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: LoginViewModel!
    private var mockPersistenceService: MockPersistenceService!

    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockPersistenceService = MockPersistenceService()
        viewModel = LoginViewModel(persistenceService: mockPersistenceService)
    }

    override func tearDown() {
        viewModel = nil
        mockPersistenceService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases

    func testLogin_WhenSuccessful() async throws {
        // Given
        mockPersistenceService.shouldSucceed = true
        let expectedUser = mockPersistenceService.mockUser
        viewModel.username = "mockUser"
        viewModel.password = "correct_password"
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.errorMessage, "errorMessage deveria ser nulo em um login bem-sucedido.")
        XCTAssertNotNil(viewModel.authenticatedUser, "authenticatedUser não deveria ser nulo.")
        XCTAssertEqual(viewModel.authenticatedUser?.username, expectedUser.username, "O usuário autenticado deve ser o esperado.")
    }
    
    func testLogin_WhenUserNotFound() async throws {
        // Given
        mockPersistenceService.shouldSucceed = false
        mockPersistenceService.errorToThrow = PersistenceError.userNotFound
        let expectedErrorMessage = "Usuário não encontrado."
        viewModel.username = "non_existent_user"
        viewModel.password = "any_password"
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.authenticatedUser, "authenticatedUser deveria ser nulo em um login com falha.")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage não deveria ser nulo.")
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage, "A mensagem de erro não é a esperada.")
    }
    
    func testLogin_WhenWrongPassword() async throws {
        // Given
        mockPersistenceService.shouldSucceed = false
        mockPersistenceService.errorToThrow = PersistenceError.wrongPassword
        let expectedErrorMessage = "Senha incorreta."
        viewModel.username = "mockUser"
        viewModel.password = "wrong_password"
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.authenticatedUser, "authenticatedUser deveria ser nulo em um login com falha.")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage não deveria ser nulo.")
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage, "A mensagem de erro não é a esperada.")
    }
    
    /// Testa se a propriedade `isLoading` transita para `true` e depois para `false`.
    func testIsLoading_IsManagedCorrectlyDuringLogin() async {
        // Given
        let startedLoading = XCTestExpectation(description: "isLoading deve se tornar true")
        let finishedLoading = XCTestExpectation(description: "isLoading deve se tornar false")
        
        var loadingStates: [Bool] = []
        // Observamos as mudanças na propriedade $isLoading
        let cancellable = viewModel.$isLoading
            .dropFirst() // Ignoramos o valor inicial que é `false`
            .sink { state in
                loadingStates.append(state)
                if state == true {
                    startedLoading.fulfill() // Cumpre a primeira expectativa
                }
                if state == false {
                    finishedLoading.fulfill() // Cumpre a segunda expectativa
                }
            }

        // When
        await viewModel.login()
        
        // Then
        // Esperamos que ambas as expectativas sejam cumpridas, na ordem correta.
        await fulfillment(of: [startedLoading, finishedLoading], timeout: 1.0, enforceOrder: true)
        
        // Verificação final opcional
        XCTAssertEqual(loadingStates, [true, false], "A transição de estado de isLoading não ocorreu como esperado.")
        
        cancellable.cancel() // Limpamos o observador
    }
}
