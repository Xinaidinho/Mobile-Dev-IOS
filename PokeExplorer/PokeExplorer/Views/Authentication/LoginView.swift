// Importa o framework SwiftUI para construção da interface
import SwiftUI

// View responsável pela tela de login do usuário
struct LoginView: View {
    // ViewModel global de login, compartilhado via environment
    @EnvironmentObject var viewModel: LoginViewModel
    // Acesso ao container de dados do SwiftData
    @Environment(\.modelContext.container) private var modelContainer

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // Logo do aplicativo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.bottom, 30)

                // Campo para nome de usuário
                TextField("Nome de Usuário", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)

                // Campo para senha
                SecureField("Senha", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                // Exibe mensagem de erro, se houver
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(AppFonts.caption)
                }

                // Exibe indicador de carregamento durante o login
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    // Botão para login (async)
                    Button("Login") {
                        Task {
                            await viewModel.login()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primaryRed)
                }
                
                Spacer()
                
                // Link para tela de cadastro
                NavigationLink("Não tem uma conta? Cadastre-se") {
                    let persistenceService = PersistenceService(modelContainer: modelContainer)
                    SignupView(viewModel: SignupViewModel(persistenceService: persistenceService))
                }
            }
            .padding()
            .navigationTitle("Bem-vindo")
        }
    }
}
