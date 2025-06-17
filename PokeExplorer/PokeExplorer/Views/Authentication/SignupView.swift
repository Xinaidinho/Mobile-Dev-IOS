import SwiftUI
import SwiftData

struct SignupView: View {
    // 1. O ViewModel é criado da forma mais simples possível. Sem init customizado!
    @StateObject private var viewModel = SignupViewModel()
    
    // 2. A View continua pegando o contexto e o dismiss do ambiente.
    @Environment(\.modelContext) private var modelContext
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
                // 3. O botão agora chama a função passando o modelContext.
                Button("Cadastrar") {
                    viewModel.signUp(context: modelContext)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primaryRed)
            }
        }
        .padding()
        .navigationTitle("Criar Conta")
        // 4. O .onAppear foi REMOVIDO pois não é mais necessário.
        .alert("Sucesso!", isPresented: $viewModel.didSignUpSuccessfully) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Sua conta foi criada. Por favor, faça o login.")
        }
    }
}
