import SwiftUI
import SwiftData

// 1. Crie uma View auxiliar dedicada para a arte do Pokémon.
//    Isso encapsula a lógica de carregamento e evita o erro de compilação.
struct ArtworkView: View {
    let url: URL?
    let pokemonId: Int
    let animationNamespace: Namespace.ID

    @State private var image: Image?

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: pokemonId, in: animationNamespace)
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, minHeight: 300) // Frame para evitar que a view colapse
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url else { return }
        var request = URLRequest(url: url)
        // Adiciona o cabeçalho User-Agent para a requisição da imagem
        request.setValue("PokeExplorerApp/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        } catch {
            print("Falha ao carregar a artwork para o Pokémon ID \(pokemonId): \(error)")
        }
    }
}


struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel
    let namespace: Namespace.ID

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
                        // 2. Use a nova ArtworkView aqui.
                        ArtworkView(
                            url: URL(string: detail.sprites.other?.officialArtwork.frontDefault ?? ""),
                            pokemonId: detail.id,
                            animationNamespace: namespace
                        )
                        
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
                // 3. CORREÇÃO: A função toggleFavorite() não é async,
                //    então o 'await' deve ser removido para evitar um erro de compilação.
                viewModel.toggleFavorite()
            }
        }
    }

    // A função artworkView(for:) foi removida e substituída pela struct ArtworkView.

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
            // Corrigindo a formatação de altura e peso para metros e kg
            Text("Altura: \(String(format: "%.1f m", Float(detail.height) / 10.0))")
            Text("Peso: \(String(format: "%.1f kg", Float(detail.weight) / 10.0))")
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