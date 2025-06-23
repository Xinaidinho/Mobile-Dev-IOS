// Importa o framework SwiftUI para construção da interface
import SwiftUI

// View responsável por exibir um card individual de Pokémon no grid
struct PokemonGridItemView: View {
    // Pokémon a ser exibido
    let pokemon: Pokemon
    // Namespace para animações
    let animationNamespace: Namespace.ID
    
    // Estado para armazenar a imagem carregada do Pokémon
    @State private var image: Image?
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            // Exibe a imagem do Pokémon, se carregada
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .matchedGeometryEffect(id: pokemon.id, in: animationNamespace)
            } else {
                // Placeholder enquanto a imagem carrega
                ProgressView()
                    .frame(width: 80, height: 80)
            }

            // Nome do Pokémon
            Text(pokemon.name.capitalized)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(1)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.small)
        // Carrega a imagem do Pokémon ao exibir o card
        .task {
            await loadImage()
        }
    }
    
    // Função assíncrona para buscar a imagem do Pokémon
    private func loadImage() async {
        guard let url = pokemon.spriteURL else { return }
        
        var request = URLRequest(url: url)
        // Adiciona o cabeçalho User-Agent obrigatório
        request.setValue("PokeExplorerApp", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        } catch {
            print("Falha ao carregar a imagem para \(pokemon.name): \(error.localizedDescription)")
        }
    }
}