//
//  PasswordHasher.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import Foundation
import CryptoKit // Framework nativo da Apple para operações criptográficas

struct PasswordHasher {
    
    /// Gera um hash seguro a partir de uma senha em texto puro.
    /// - Parameter password: A senha a ser criptografada.
    /// - Returns: Uma string contendo o hash da senha.
    static func hash(password: String) throws -> String {
        guard let passwordData = password.data(using: .utf8) else {
            // Lança um erro se a senha não puder ser convertida para dados.
            throw NSError(domain: "PasswordHasherError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid password format"])
        }
        
        // Usa o algoritmo SHA256 para criar o hash.
        let hashedData = SHA256.hash(data: passwordData)
        
        // Retorna o hash como uma string hexadecimal para armazenamento.
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verifica se uma senha em texto puro corresponde a um hash armazenado.
    /// - Parameters:
    ///   - password: A senha que o usuário digitou para fazer login.
    ///   - storedHash: O hash que está armazenado no banco de dados.
    /// - Returns: `true` se a senha for válida, `false` caso contrário.
    static func verify(password: String, against storedHash: String) -> Bool {
        do {
            let newHash = try hash(password: password)
            return newHash == storedHash
        } catch {
            return false
        }
    }
}
