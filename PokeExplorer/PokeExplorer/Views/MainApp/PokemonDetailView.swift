import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel
    let namespace: Namespace.ID
    
    // 1. Adicione esta variável de estado para ser nosso gatilho.
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
        // 2. Adicione este modificador. Ele cria uma tarefa segura que será
        //    cancelada automaticamente quando a view desaparecer.
        .task(id: favoritingTrigger) {
            // A tarefa só roda quando o gatilho muda de false para true.
            if favoritingTrigger {
                await viewModel.toggleFavorite()
            }
        }
    }

    // ... (funções artworkView, typesView, sizeView permanecem iguais) ...
    private func artworkView(for detail: PokemonDetail) -> some View {
        let url = URL(string: detail.sprites.other?.officialArtwork.frontDefault ?? "")
        return AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView().scaleEffect(1.5).padding()
            case .success(let img):
                img.resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: detail.id, in: namespace)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
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
            // 3. A ação do botão agora apenas ativa o gatilho.
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
