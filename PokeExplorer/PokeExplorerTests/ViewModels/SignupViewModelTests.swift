//
//  SignupViewModelTests.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/23/25.
//

import XCTest
@testable import PokeExplorer

@MainActor
final class SignupViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: SignupViewModel!
    private var mockPersistenceService: MockPersistenceService!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockPersistenceService = MockPersistenceService()
        viewModel = SignupViewModel(persistenceService: mockPersistenceService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockPersistenceService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Testa o cenário de cadastro bem-sucedido.
    func testSignUp_WhenSuccessful() async {
        // Given
        viewModel.username = "newUser"
        viewModel.email = "new@user.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        mockPersistenceService.shouldSucceed = true
        
        // When
        viewModel.signUp()
        try? await Task.sleep(nanoseconds: 100_000_000) // Aguarda a task interna
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertNil(viewModel.errorMessage, "errorMessage deveria ser nulo em um cadastro bem-sucedido.")
        XCTAssertTrue(viewModel.didSignUpSuccessfully, "didSignUpSuccessfully deveria ser verdadeiro.")
    }
    
    /// Testa a falha no cadastro quando o usuário já existe.
    func testSignUp_WhenUserAlreadyExists() async {
        // Given
        viewModel.username = "existingUser"
        viewModel.email = "existing@user.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        mockPersistenceService.shouldSucceed = false
        mockPersistenceService.errorToThrow = PersistenceError.userAlreadyExists
        let expectedErrorMessage = PersistenceError.userAlreadyExists.errorDescription
        
        // When
        viewModel.signUp()
        try? await Task.sleep(nanoseconds: 100_000_000) // Aguarda a task interna
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria ser falso após a conclusão.")
        XCTAssertFalse(viewModel.didSignUpSuccessfully, "didSignUpSuccessfully deveria ser falso.")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage não deveria ser nulo.")
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage, "A mensagem de erro não é a esperada.")
    }
    
    /// Testa a validação de senhas que não coincidem.
    func testSignUp_WhenPasswordsDoNotMatch() {
        // Given
        viewModel.username = "anyUser"
        viewModel.email = "any@email.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password456"
        
        // When
        viewModel.signUp()
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria permanecer falso se a validação falhar.")
        XCTAssertFalse(viewModel.didSignUpSuccessfully, "didSignUpSuccessfully deveria ser falso.")
        XCTAssertEqual(viewModel.errorMessage, "As senhas não coincidem.", "A mensagem de erro para senhas divergentes não é a esperada.")
    }
    
    /// Testa a validação de campos obrigatórios vazios.
    func testSignUp_WhenFieldsAreEmpty() {
        // Given
        viewModel.username = "" // Campo vazio
        viewModel.email = "any@email.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // When
        viewModel.signUp()
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "isLoading deveria permanecer falso se a validação falhar.")
        XCTAssertFalse(viewModel.didSignUpSuccessfully, "didSignUpSuccessfully deveria ser falso.")
        XCTAssertEqual(viewModel.errorMessage, "Todos os campos são obrigatórios.", "A mensagem de erro para campos vazios não é a esperada.")
    }
}
