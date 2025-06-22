import SwiftUI

struct PokemonGridItemView: View {
    let pokemon: Pokemon
    let animationNamespace: Namespace.ID

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            // aqui o AsyncImage com o spriteURL
            AsyncImage(url: pokemon.spriteURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .matchedGeometryEffect(id: pokemon.id, in: animationNamespace)
                case .failure:
                    Image(systemName: "questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }

            Text(pokemon.name.capitalized)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(1)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.small)
    }
}
