import SwiftUI

extension View {
    func navigationDestination<T, Destination: View>(when binding: Binding<T?>, destination: (T) -> Destination) -> some View {
        self.background {
            EmptyView()
                .overlay {
                    NavigationLink("", isActive: Binding(get: { binding.wrappedValue != nil }, set: { _, _ in binding.wrappedValue = nil }), destination: {
                        if let value = binding.wrappedValue {
                            destination(value)
                        }
                    })
                }
        }
    }
}
