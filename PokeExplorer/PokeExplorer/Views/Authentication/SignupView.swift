import SwiftUI
import SwiftData

struct SignupView: View {
    // MUDANÇA 1: A view agora recebe o ViewModel e o observa.
    @ObservedObject var viewModel: SignupViewModel
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
                // MUDANÇA 2: A chamada da função não passa mais parâmetros.
                Button("Cadastrar") {
                    viewModel.signUp()
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
