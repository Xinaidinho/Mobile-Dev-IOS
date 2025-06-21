//
//  PokeExplorerTests.swift
//  PokeExplorerTests
//
//  Created by user276522 on 6/17/25.
//

import XCTest
// 1. Importe o módulo principal do seu aplicativo para ter acesso às classes.
@testable import PokeExplorer

// 2. Renomeie a classe de teste para refletir o que ela testa.
final class PasswordHasherTests: XCTestCase {

    // MARK: - Test for hash()
    
    /// Testa se a função hash produz uma saída consistente e não vazia.
    func testHash_GivenSamePassword_ShouldReturnSameHash() {
        // Given (Dado)
        let password = "mySecurePassword123"
        
        // When (Quando)
        let hash1 = PasswordHasher.hash(password)
        let hash2 = PasswordHasher.hash(password)
        
        // Then (Então)
        XCTAssertFalse(hash1.isEmpty, "O hash não deve ser uma string vazia.")
        XCTAssertEqual(hash1, hash2, "O hash deve ser consistente para a mesma senha.")
    }

    /// Testa se a função hash produz hashes diferentes para senhas diferentes.
    func testHash_GivenDifferentPasswords_ShouldReturnDifferentHashes() {
        // Given
        let passwordA = "passwordA"
        let passwordB = "passwordB"
        
        // When
        let hashA = PasswordHasher.hash(passwordA)
        let hashB = PasswordHasher.hash(passwordB)
        
        // Then
        XCTAssertNotEqual(hashA, hashB, "Hashes para senhas diferentes não devem ser iguais.")
    }

    // MARK: - Tests for verify()

    /// Testa se a verificação é bem-sucedida com a senha e o hash corretos.
    func testVerify_GivenCorrectPasswordAndHash_ShouldReturnTrue() {
        // Given
        let password = "correct-password"
        let correctHash = PasswordHasher.hash(password)
        
        // When
        let isPasswordCorrect = PasswordHasher.verify(password, against: correctHash)
        
        // Then
        XCTAssertTrue(isPasswordCorrect, "A verificação deve retornar verdadeiro para a senha correta.")
    }
    
    /// Testa se a verificação falha com a senha incorreta.
    func testVerify_GivenIncorrectPassword_ShouldReturnFalse() {
        // Given
        let correctPassword = "correct-password"
        let incorrectPassword = "incorrect-password"
        let correctHash = PasswordHasher.hash(correctPassword)
        
        // When
        let isPasswordCorrect = PasswordHasher.verify(incorrectPassword, against: correctHash)
        
        // Then
        XCTAssertFalse(isPasswordCorrect, "A verificação deve retornar falso para a senha incorreta.")
    }
    
    /// Testa se a verificação falha com uma string de hash mal formatada ou vazia.
    func testVerify_GivenInvalidHash_ShouldReturnFalse() {
        // Given
        let password = "any-password"
        let invalidHash = "this-is-not-a-valid-sha256-hash"
        let emptyHash = ""
        
        // When
        let resultWithInvalidHash = PasswordHasher.verify(password, against: invalidHash)
        let resultWithEmptyHash = PasswordHasher.verify(password, against: emptyHash)
        
        // Then
        XCTAssertFalse(resultWithInvalidHash, "A verificação deve falhar para um hash inválido.")
        XCTAssertFalse(resultWithEmptyHash, "A verificação deve falhar para um hash vazio.")
    }
}
