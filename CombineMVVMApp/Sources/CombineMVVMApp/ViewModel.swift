import Combine
import Foundation

class ViewModel: ObservableObject {
    @Published var text = "Loading..."
    private var cancellables = Set<AnyCancellable>()

    func fetch() {
        Just(Model(value: "Hello, Combine!"))
            .map { $0.value }
            .assign(to: &$text)
    }
}
