//
//  PasswordHasher.swift
//  PokeExplorer/Utils
//
//  Created by user276522 on 6/17/25.
//

import Foundation
import CryptoKit

/// Hash e verificação de senhas usando SHA-256
struct PasswordHasher {
    /// Gera o hash SHA-256 de uma string e retorna como hex string.
    /// - Parameter password: senha em texto puro
    /// - Returns: hash hexadecimal
    static func hash(_ password: String) -> String {
        let data = Data(password.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Verifica se uma senha em texto puro corresponde ao hash armazenado.
    /// - Parameters:
    ///   - password: senha em texto puro
    ///   - storedHash: hash hexadecimal armazenado
    /// - Returns: true se bater, false caso contrário
    static func verify(_ password: String, against storedHash: String) -> Bool {
        return hash(password) == storedHash
    }
}
