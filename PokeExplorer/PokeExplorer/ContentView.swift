import SwiftUI

struct ContentView: View {
    // Recebe o ViewModel do ambiente, injetado pelo PokeExplorerApp
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        // A lógica permanece a mesma, mas a View está mais limpa
        if let user = loginViewModel.authenticatedUser {
            AppTabView(user: user)
        } else {
            LoginView()
        }
    }
}
