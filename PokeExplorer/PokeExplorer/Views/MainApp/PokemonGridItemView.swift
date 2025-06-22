import SwiftUI

struct PokemonGridItemView: View {
    let pokemon: Pokemon
    let animationNamespace: Namespace.ID
    
    // Estado para armazenar a imagem carregada
    @State private var image: Image?
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            // Lógica de exibição da imagem
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .matchedGeometryEffect(id: pokemon.id, in: animationNamespace)
            } else {
                // Placeholder enquanto a imagem carrega ou em caso de falha
                ProgressView()
                    .frame(width: 80, height: 80)
            }

            Text(pokemon.name.capitalized)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(1)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.small)
        // Task para carregar a imagem quando a view aparecer
        .task {
            await loadImage()
        }
    }
    
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