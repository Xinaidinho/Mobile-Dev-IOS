// Importa frameworks necessários
import SwiftUI
import SwiftData

// View responsável pela tela de cadastro de novo usuário
struct SignupView: View {
    // ViewModel observado para controlar o estado do formulário
    @ObservedObject var viewModel: SignupViewModel
    // Permite fechar a tela de cadastro
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Campo para nome de usuário
            TextField("Nome de Usuário", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)

            // Campo para email
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)

            // Campo para senha
            SecureField("Senha", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            // Campo para confirmação de senha
            SecureField("Confirmar Senha", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
            
            // Exibe mensagem de erro, se houver
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red).font(AppFonts.caption)
            }

            // Exibe indicador de carregamento durante o cadastro
            if viewModel.isLoading {
                ProgressView()
            } else {
                // Botão para cadastrar
                Button("Cadastrar") {
                    viewModel.signUp()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primaryRed)
            }
        }
        .padding()
        .navigationTitle("Criar Conta")
        // Alerta de sucesso ao criar conta
        .alert("Sucesso!", isPresented: $viewModel.didSignUpSuccessfully) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Sua conta foi criada. Por favor, faça o login.")
        }
    }
}
