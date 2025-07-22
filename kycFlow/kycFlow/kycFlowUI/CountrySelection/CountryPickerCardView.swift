import SwiftUI

/// Card view to display each country option
struct CountryPickerCardView: View {
    let country: CountryInfo
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(country.name)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .black)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
                .opacity(isSelected ? 1 : 0)
        }
        .padding()
        .background(isSelected ? .accent : .white)
        .cornerRadius(12)
        .animation(
            .spring(
                response: 0.3,
                dampingFraction: 0.7
            ),
            value: isSelected
        )
    }
}
