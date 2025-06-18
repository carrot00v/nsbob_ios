import SwiftUI

@main
struct CombineMVVMAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ViewModel())
        }
    }
}
