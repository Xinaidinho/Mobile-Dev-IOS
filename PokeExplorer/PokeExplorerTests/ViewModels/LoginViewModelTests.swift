//
//  LoginViewModelTests.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/19/25.
//

import XCTest
@testable import PokeExplorer

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: LoginViewModel!
    private var mockPersistenceService: MockPersistenceService!

    // MARK: - Setup & Teardown
    
    /// Este método é chamado antes de cada teste na classe.
    /// É o lugar perfeito para criar nossos objetos de teste.
    override func setUp() {
        super.setUp()
        // 1. Crie uma nova instância do nosso mock antes de cada teste.
        mockPersistenceService = MockPersistenceService()
        // 2. Crie o ViewModel, injetando o mock através do init de teste.
        viewModel = LoginViewModel(persistenceService: mockPersistenceService)
    }

    /// Este método é chamado após a conclusão de cada teste.
    /// Usamos para limpar os objetos e evitar vazamento de memória entre os testes.
    override func tearDown() {
        viewModel = nil
        mockPersistenceService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases

    /// Testa o cenário de login bem-sucedido.
    func testLogin_WhenSuccessful() async {
        // Given (Dado)
        mockPersistenceService.shouldSucceed = true
        let expectedUser = mockPersistenceService.mockUser
        
        viewModel.username = "mockUser"
        viewModel.password = "correct_password"
        
        // When (Quando)
        await viewModel.login()
        
        // Then (Então)
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.errorMessage, "errorMessage deveria ser nulo em um login bem-sucedido.")
        XCTAssertNotNil(viewModel.authenticatedUser, "authenticatedUser não deveria ser nulo.")
        XCTAssertEqual(viewModel.authenticatedUser?.username, expectedUser.username, "O usuário autenticado deve ser o esperado.")
    }
    
    /// Testa o cenário de falha de login (usuário não encontrado).
    func testLogin_WhenUserNotFound() async {
        // Given (Dado)
        mockPersistenceService.shouldSucceed = false
        mockPersistenceService.errorToThrow = PersistenceError.userNotFound
        let expectedErrorMessage = "Usuário não encontrado."
        
        viewModel.username = "non_existent_user"
        viewModel.password = "any_password"
        
        // When (Quando)
        await viewModel.login()
        
        // Then (Então)
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.authenticatedUser, "authenticatedUser deveria ser nulo em um login com falha.")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage não deveria ser nulo.")
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage, "A mensagem de erro não é a esperada.")
    }
    
    /// Testa o cenário de falha de login (senha incorreta).
    func testLogin_WhenWrongPassword() async {
        // Given (Dado)
        mockPersistenceService.shouldSucceed = false
        mockPersistenceService.errorToThrow = PersistenceError.wrongPassword
        let expectedErrorMessage = "Senha incorreta."
        
        viewModel.username = "mockUser"
        viewModel.password = "wrong_password"
        
        // When (Quando)
        await viewModel.login()
        
        // Then (Então)
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.authenticatedUser, "authenticatedUser deveria ser nulo em um login com falha.")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage não deveria ser nulo.")
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage, "A mensagem de erro não é a esperada.")
    }
    
    /// Testa se a propriedade `isLoading` é gerenciada corretamente durante a chamada de login.
    func testIsLoading_IsManagedCorrectlyDuringLogin() async {
        // Given
        mockPersistenceService.shouldSucceed = true
        
        // Create an expectation
        let expectation = XCTestExpectation(description: "Login completes and sets isLoading to false")
        
        // Observe a mudança em isLoading
        let cancellable = viewModel.$isLoading.sink { isLoading in
            if !isLoading { // When it turns back to false
                expectation.fulfill()
            }
        }
        
        // When
        viewModel.login() // Don't await here, we want to check the state during the call
        
        // Then
        XCTAssertTrue(viewModel.isLoading, "isLoading deveria ser true imediatamente após chamar login().")
        
        // Wait for the expectation to be fulfilled
        await fulfillment(of: [expectation], timeout: 1.0)
        cancellable.cancel() // Clean up the observer
    }
}
