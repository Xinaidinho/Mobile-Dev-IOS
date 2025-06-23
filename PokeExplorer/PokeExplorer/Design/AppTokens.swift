//
//  AppTokens.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import SwiftUI

// Arquivo central de tokens de design do app (cores, fontes, espaçamentos, bordas)
// Facilita a padronização visual e a manutenção do design

// Enum com as cores principais do aplicativo, referenciando o Assets.xcassets
enum AppColors {
    static let primaryRed = Color("PrimaryRed")           // Cor principal/vermelho
    static let cardBackground = Color("CardBackground")   // Fundo de cards
    static let primaryText = Color("PrimaryText")         // Texto principal
    static let secondaryText = Color("SecondaryText")     // Texto secundário
    static let accent         = Color("AccentColor")      // Cor de destaque
}

// Enum com estilos de fontes usados no app
enum AppFonts {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)         // Título grande
    static let headline = Font.system(size: 16, weight: .semibold, design: .rounded)  // Destaque
    static let body = Font.system(size: 14, weight: .regular)                        // Corpo de texto
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)    // Legenda
}

// Enum com espaçamentos padrão para margens e paddings
enum AppSpacing {
    static let extraSmall: CGFloat = 4   // Espaçamento extra pequeno
    static let small: CGFloat = 8        // Espaçamento pequeno
    static let medium: CGFloat = 16      // Espaçamento médio
    static let large: CGFloat = 24       // Espaçamento grande
}

// Enum com raios de borda padrão para cantos arredondados
enum AppCornerRadius {
    static let small: CGFloat = 8    // Raio pequeno
    static let medium: CGFloat = 12  // Raio médio
    static let large: CGFloat = 20   // Raio grande
}
