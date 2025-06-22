import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel
    let namespace: Namespace.ID
    let pokemon: Pokemon
    
    @State private var favoritingTrigger = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            } else if let detail = viewModel.detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        artworkView()
                        Text(detail.name.capitalized)
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primaryText)
                        typesView(for: detail)
                        sizeView(for: detail)
                        favoriteButton(for: detail)
                    }
                    .padding()
                }
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                EmptyView()
            }
        }
        .navigationTitle(viewModel.detail?.name.capitalized ?? "Carregando…")
        .task(id: favoritingTrigger) {
            if favoritingTrigger {
                viewModel.toggleFavorite()
            }
        }
    }

    // MARK: – Usa a URL do model Pokemon, não o JSON de detail
    private func artworkView() -> some View {
        AsyncImage(url: pokemon.officialArtworkURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            case .success(let img):
                img
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: pokemon.id, in: namespace)
            case .failure:
                // fallback para o sprite pequeno, se quiser:
                if let sprite = pokemon.spriteURL {
                    AsyncImage(url: sprite) { inner in
                        if let image = try? inner.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: pokemon.id, in: namespace)
                        } else {
                            placeholderImage()
                        }
                    }
                } else {
                    placeholderImage()
                }
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func placeholderImage() -> some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .frame(width: 100, height: 100)
    }

    private func typesView(for detail: PokemonDetail) -> some View {
        HStack {
            ForEach(detail.types, id: \.slot) { entry in
                Text(entry.type.name.capitalized)
                    .font(AppFonts.caption)
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, AppSpacing.extraSmall)
                    .background(AppColors.accent)
                    .cornerRadius(AppCornerRadius.small)
                    .foregroundColor(.white)
            }
        }
    }

    private func sizeView(for detail: PokemonDetail) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Text("Altura: \(detail.height)")
            Text("Peso: \(detail.weight)")
        }
        .font(AppFonts.body)
        .foregroundColor(AppColors.secondaryText)
    }

    private func favoriteButton(for detail: PokemonDetail) -> some View {
        Button {
            favoritingTrigger.toggle()
        } label: {
            Label(
                viewModel.isFavorited ? "Remover dos Favoritos" : "Adicionar aos Favoritos",
                systemImage: viewModel.isFavorited ? "star.fill" : "star"
            )
            .font(AppFonts.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primaryRed)
            .foregroundColor(.white)
            .cornerRadius(AppCornerRadius.medium)
        }
    }
}
