//
//  AppTokens.swift
//  PokeExplorer
//
//  Created by user276522 on 6/17/25.
//

import SwiftUI

enum AppColors {
    static let primaryRed = Color("PrimaryRed")
    static let cardBackground = Color("CardBackground")
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let accent         = Color("AccentColor")
}

enum AppFonts {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
}

enum AppSpacing {
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
}

enum AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 20
}
