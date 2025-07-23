import SwiftUI

struct FormView: View {

    @EnvironmentObject private var router: AppRouter
    @StateObject var viewModel: FormViewModel

    var body: some View {

        ZStack {
            linearGradientBackground

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                contentView
            }
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        .navigationTitle("\(viewModel.countryConfig.country) KYC Form")
        .navigationBarBackButtonHidden(true)
        .toolbar(content: { toolbarContent })
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
    var contentView: some View {
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

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                router.path.removeLast()
            }) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
    }
}

