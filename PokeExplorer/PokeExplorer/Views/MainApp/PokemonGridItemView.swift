import SwiftUI

struct PokemonGridItemView: View {
    let pokemon: Pokemon
    let animationNamespace: Namespace.ID

    var body: some View {
        VStack {
            AsyncImage(url: pokemon.officialArtworkURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
                    .tint(AppColors.primaryRed)
            }
            .frame(width: 100, height: 100)
            .matchedGeometryEffect(id: pokemon.name, in: animationNamespace) // Efeito da animação

            Text(pokemon.name.capitalized)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.primaryText)
        }
        .padding(AppSpacing.small)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
