import SwiftUI

/// A header view which has title and subtitle for generic use
struct HeaderView: View {
    let title: String
    let subtitle: String
    let alignment: HorizontalAlignment

    init(title: String, subtitle: String, alignment: HorizontalAlignment? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.alignment = alignment ?? .leading
    }

    var body: some View {
        VStack(alignment: alignment) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
