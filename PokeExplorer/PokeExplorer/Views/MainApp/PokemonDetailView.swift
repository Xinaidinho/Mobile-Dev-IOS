import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel
    @Environment(\.modelContext) private var context
    let user: User
    let namespace: Namespace.ID

    init(pokemonURL: String, user: User, namespace: Namespace.ID) {
        self.user = user
        self.namespace = namespace
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonURL: pokemonURL))
    }

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
        .task {
            await viewModel.checkIfFavorited(by: user, in: context)
        }
    }

    // MARK: - Subviews

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
            Task {
                await viewModel.toggleFavorite(for: detail, user: user, in: context)
            }
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

struct PokemonDetailView_Previews: PreviewProvider {
    @Namespace static var ns

    static var previews: some View {
        PokemonDetailView(
            pokemonURL: "https://pokeapi.co/api/v2/pokemon/1/",
            user: User(username: "preview", email: "x@x.com", passwordHash: "hash"),
            namespace: ns
        )
    }
}
