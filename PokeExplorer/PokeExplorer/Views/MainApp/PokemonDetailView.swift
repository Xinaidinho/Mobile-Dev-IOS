// Importa frameworks necessários
import SwiftUI
import SwiftData

// View responsável por exibir os detalhes de um Pokémon selecionado
struct PokemonDetailView: View {
    // ViewModel com os dados e lógica da tela de detalhes
    @ObservedObject var viewModel: PokemonDetailViewModel
    // Namespace para animações
    let namespace: Namespace.ID
    // Pokémon a ser detalhado
    let pokemon: Pokemon
    
    // Estado para controlar o botão de favoritar
    @State private var favoritingTrigger = false

    var body: some View {
        Group {
            // Exibe indicador de carregamento
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            // Exibe detalhes do Pokémon, se disponíveis
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
            // Exibe mensagem de erro, se houver
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            // Caso não haja dados nem erro
            } else {
                EmptyView()
            }
        }
        .navigationTitle(viewModel.detail?.name.capitalized ?? "Carregando…")
        // Atualiza favoritos ao acionar o botão
        .task(id: favoritingTrigger) {
            if favoritingTrigger {
                viewModel.toggleFavorite()
            }
        }
    }

    // MARK: – Exibe a imagem principal do Pokémon
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
                // Fallback para sprite pequeno, se houver erro
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
    
    // Imagem placeholder caso não seja possível carregar a arte
    private func placeholderImage() -> some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .frame(width: 100, height: 100)
    }

    // Exibe os tipos do Pokémon
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

    // Exibe altura e peso do Pokémon
    private func sizeView(for detail: PokemonDetail) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Text("Altura: \(detail.height)")
            Text("Peso: \(detail.weight)")
        }
        .font(AppFonts.body)
        .foregroundColor(AppColors.secondaryText)
    }

    // Botão para favoritar/desfavoritar o Pokémon
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
