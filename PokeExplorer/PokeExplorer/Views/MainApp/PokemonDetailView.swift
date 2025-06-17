import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel
    @Environment(\.modelContext) private var modelContext // Pega o contexto do ambiente
    let animationNamespace: Namespace.ID

    init(pokemonURL: String, user: User, namespace: Namespace.ID) {
        self.animationNamespace = namespace
        // A inicialização agora é feita de forma síncrona, mas o @Environment
        // garante que o modelContext estará disponível quando a View for renderizada.
        // Por isso, usamos um contexto temporário aqui.
        let tempModelContext = try! ModelContainer(for: User.self, FavoritePokemon.self).mainContext
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonURL: pokemonURL, user: user, modelContext: tempModelContext))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView().frame(height: 300)
            } else if let detail = viewModel.pokemonDetail {
                VStack(spacing: AppSpacing.medium) {
                    AsyncImage(url: URL(string: detail.sprites.other?.officialArtwork.front_default ?? "")) { image in
                        image.resizable().scaledToFit()
                    } placeholder: { ProgressView() }
                    .frame(height: 250)
                    .matchedGeometryEffect(id: detail.name, in: animationNamespace)

                    Text(detail.name.capitalized).font(AppFonts.title).bold()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { viewModel.toggleFavorite() }
                    }) {
                        Label(viewModel.isFavorite ? "Favorito" : "Adicionar aos Favoritos",
                              systemImage: viewModel.isFavorite ? "star.fill" : "star")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.isFavorite ? .yellow : AppColors.primaryRed)
                    .scaleEffect(viewModel.isFavorite ? 1.1 : 1.0)
                    
                }.padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }
        }
        .navigationTitle(viewModel.pokemonDetail?.name.capitalized ?? "Carregando...")
        .onAppear {
            if viewModel.pokemonDetail == nil {
                viewModel.fetchData()
            }
        }
    }
}
