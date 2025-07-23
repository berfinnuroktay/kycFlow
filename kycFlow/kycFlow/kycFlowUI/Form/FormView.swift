import SwiftUI

struct FormView: View {

    @StateObject var viewModel: FormViewModel

    var body: some View {
        Form {
            ForEach(viewModel.fieldViewModels) { fieldViewModel in
                FormFieldView(viewModel: fieldViewModel)
            }

            Button("Submit") {
                viewModel.onTapSubmitButton()
            }
        }
        .navigationTitle("\(viewModel.countryConfig.country) KYC Form")
        .alert(
            "Submission Successful",
            isPresented: $viewModel.isSubmissionResultPresented,
            actions: { alertActions },
            message: {alertMessage}
        )
    }
}

private extension FormView {

    @ViewBuilder
    var alertMessage: some View {
        Text(viewModel.submissionResult ?? "")
    }

    @ViewBuilder
    var alertActions: some View {
        Button("OK", role: .cancel) {
            viewModel.onTapAlertCancel()
        }
    }
}
