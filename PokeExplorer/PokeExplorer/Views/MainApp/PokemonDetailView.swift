import SwiftUI
import SwiftData

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
                        // A chamada da função permanece a mesma
                        artworkView(for: detail)
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
                // A ação de favoritar não foi alterada
                viewModel.toggleFavorite()
            }
        }
    }

    // A função artworkView foi atualizada para o carregamento manual
    private func artworkView(for detail: PokemonDetail) -> some View {
        let url = URL(string: detail.sprites.other?.officialArtwork.frontDefault ?? "")
        
        // Novo componente para carregamento de imagem com User-Agent
        CustomAsyncImageView(url: url)
            .scaledToFit()
            .matchedGeometryEffect(id: detail.id, in: namespace)
    }

    // ... (o restante do arquivo, como typesView, sizeView, favoriteButton, permanece o mesmo) ...
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
            Text("Altura: \(String(format: "%.1f", Float(detail.height) / 10)) m")
            Text("Peso: \(String(format: "%.1f", Float(detail.weight) / 10)) kg")
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

// View auxiliar para carregar a imagem com cabeçalho customizado
struct CustomAsyncImageView: View {
    let url: URL?
    @State private var image: Image?

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, idealHeight: 300)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url else { return }
        var request = URLRequest(url: url)
        request.setValue("PokeExplorerApp", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        } catch {
            print("Falha ao carregar a imagem detalhada: \(error.localizedDescription)")
        }
    }
}