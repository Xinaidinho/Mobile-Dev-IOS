import SwiftUI
import SwiftData

struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    
    // 1. Obtenha o ModelContainer do ambiente
    @Environment(\.modelContext.container) private var modelContainer
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            TextField("Nome de Usuário", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)

            SecureField("Senha", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirmar Senha", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red).font(AppFonts.caption)
            }

            if viewModel.isLoading {
                ProgressView()
            } else {
                // 2. Passe o modelContainer ao chamar a função signUp
                Button("Cadastrar") {
                    viewModel.signUp(modelContainer: modelContainer)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primaryRed)
            }
        }
        .padding()
        .navigationTitle("Criar Conta")
        .alert("Sucesso!", isPresented: $viewModel.didSignUpSuccessfully) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Sua conta foi criada. Por favor, faça o login.")
        }
    }
}
