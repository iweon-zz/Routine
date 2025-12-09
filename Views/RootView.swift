import SwiftUI

struct RootView: View {
    @StateObject var authManager = AuthManager()
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ContentView(authManager: authManager)
                    .environmentObject(authManager)
            } else {
                AuthView()
                    .environmentObject(authManager)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
