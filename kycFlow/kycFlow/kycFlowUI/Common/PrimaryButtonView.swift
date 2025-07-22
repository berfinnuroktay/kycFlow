import SwiftUI

/// Primary button component to be used throughout the app
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: .accentColor.opacity(isEnabled ? 0.3 : 0), radius: 10, y: 5)
        }
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
