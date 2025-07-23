import SwiftUI

struct FormView: View {

    @StateObject var viewModel: FormViewModel

    var body: some View {

        ZStack {
            linearGradientBackground

            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.fieldViewModels) { fieldViewModel in
                            FormFieldView(viewModel: fieldViewModel)
                        }
                    }
                    .padding(16)
                }
                .scrollIndicators(.hidden)

                PrimaryButton(title: "Submit", action: viewModel.onTapSubmitButton)
                    .disabled(!viewModel.isSubmitEnabled)
                    .padding()
            }
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
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

    @ViewBuilder
    var linearGradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blackHowl, .tuna]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

