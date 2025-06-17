import SwiftUI

struct LoginView: View {
    // Recebe o ViewModel do ambiente
    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // Lembre-se de adicionar uma imagem "logo" nos seus Assets
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
                    Button("Login") { viewModel.login() }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.primaryRed)
                }
                
                Spacer()
                
                NavigationLink("Não tem uma conta? Cadastre-se") {
                    SignupView()
                }
            }
            .padding()
            .navigationTitle("Bem-vindo")
        }
    }
}
