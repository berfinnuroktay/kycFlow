import SwiftUI

struct FormFieldView: View {

    @ObservedObject var viewModel: FormFieldItemViewModel

    @State private var calendarId: Int = 0
    @State private var showPicker: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            fieldHeader

            switch viewModel.type {
            case .text, .number:
                textField
            case .date:
                datePicker
            }

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
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(viewModel.type.keyboardType)
            .disabled(viewModel.isReadOnly)
    }

    @ViewBuilder
    var datePicker: some View {
        DatePicker(
            "",
            selection: dateBinding,
            displayedComponents: .date
        )
        //.labelsHidden()
            .disabled(viewModel.isReadOnly)
            .id(calendarId)
            .onChange(of: dateBinding.wrappedValue) {
              calendarId += 1
            }
            .datePickerStyle(.wheel)
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
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                return formatter.date(from: viewModel.value) ?? Date()
            },
            set: {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                viewModel.value = formatter.string(from: $0)
            }
        )
    }
}
