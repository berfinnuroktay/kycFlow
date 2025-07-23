import SwiftUI

struct FormFieldView: View {

    @ObservedObject var viewModel: FormFieldItemViewModel

    @State private var calendarId: Int = 0
    @State private var showPicker: Bool = false
    @State private var showDatePicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            fieldHeader

            Group {
                switch viewModel.type {
                case .text, .number:
                    textField
                case .date:
                    dateField
                }
            }
            .disabled(viewModel.isReadOnly)
            .padding(12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.white)
            .tint(.white)

            Text(viewModel.validationError ?? "")
                .font(.caption)
                .foregroundColor(.red)
                .opacity(viewModel.validationError == nil ? 1 : 0)
                .transition(.opacity.animation(.easeIn))

        }
        .padding(.vertical, 5)
        .onChange(of: viewModel.value) {
            if viewModel.validationError != nil {
                viewModel.validationError = nil
            }
        }
    }
}

// MARK: - Helper views
private extension FormFieldView {

    @ViewBuilder
    var textField: some View {
        TextField(viewModel.label, text: $viewModel.value)
            .keyboardType(viewModel.type.keyboardType)
    }

    @ViewBuilder
    var fieldHeader: some View {
        HStack(spacing: 2) {
            Text(viewModel.label)
            if viewModel.isRequired {
                Text("*").foregroundColor(.red)
            }
        }
        .font(.headline)
        .foregroundColor(.white.opacity(0.8))
    }

    var dateBinding: Binding<Date> {
        Binding(
            get: {
                return viewModel.formatter.date(from: viewModel.value) ?? Date()
            },
            set: {
                viewModel.value = viewModel.formatter.string(from: $0)

            }
        )
    }

    @ViewBuilder
    private var dateField: some View {
        VStack {
            Button(action: {
                withAnimation {
                    showDatePicker.toggle()
                }
            }) {
                HStack {
                    Text(viewModel.value)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
            }

            if showDatePicker {
                DatePicker(
                    "",
                    selection: dateBinding,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorInvert()
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}
