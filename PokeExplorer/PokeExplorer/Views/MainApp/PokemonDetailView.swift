import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    // Usamos @StateObject para que o ViewModel persista durante o ciclo de vida da View.
    @StateObject private var viewModel: PokemonDetailViewModel
    
    // Pegamos o modelContext que já existe no ambiente.
    @Environment(\.modelContext) private var modelContext
    
    let animationNamespace: Namespace.ID

    // ESTE É O INIT CORRETO E ROBUSTO
    // Ele recebe os parâmetros necessários da View anterior.
    init(pokemonURL: String, user: User, namespace: Namespace.ID) {
        self.animationNamespace = namespace
        
        // Criamos o StateObject aqui, passando os parâmetros necessários.
        // Note que o modelContext ainda não está disponível NESTE PONTO do código.
        // Por isso, a inicialização completa do ViewModel será feita no .onAppear.
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonURL: pokemonURL, user: user))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView().frame(height: 300)
            } else if let detail = viewModel.pokemonDetail {
                // O conteúdo da View (VStack, etc.) permanece o mesmo...
                VStack(spacing: AppSpacing.medium) {
                    AsyncImage(url: URL(string: detail.sprites.other?.officialArtwork?.front_default ?? "")) { image in
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
            // Aqui, o modelContext do @Environment já está disponível.
            // Nós o passamos para o ViewModel para que ele possa configurar o PersistenceService.
            viewModel.setup(modelContext: modelContext)
            
            // A chamada para buscar os dados também é feita aqui.
            if viewModel.pokemonDetail == nil {
                viewModel.fetchData()
            }
        }
    }
}