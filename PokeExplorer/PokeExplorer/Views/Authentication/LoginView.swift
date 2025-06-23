import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(\.modelContext.container) private var modelContainer

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.bottom, 30)

                TextField("Nome de Usuário", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)

                SecureField("Senha", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(AppFonts.caption)
                }

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    // MUDANÇA: Como login() agora é async, a chamada precisa estar em uma Task.
                    Button("Login") {
                        Task {
                            await viewModel.login()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primaryRed)
                }
                
                Spacer()
                
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
