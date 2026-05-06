import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            onboardingPage(
                icon: "camera.metering.matrix",
                title: "Welcome to PhotoSlim",
                subtitle: "The smartest way to clean up your photo library",
                tag: 0
            )
            onboardingPage(
                icon: "brain.head.profile",
                title: "100% Offline AI",
                subtitle: "All processing happens on your device. Your photos never leave your phone.",
                tag: 1
            )
            onboardingPage(
                icon: "doc.on.doc.fill",
                title: "Find Duplicates",
                subtitle: "Detect exact and similar duplicates using Vision AI",
                tag: 2
            )
            onboardingPage(
                icon: "eye.slash.fill",
                title: "Detect Blurry Photos",
                subtitle: "Automatically identify blurry shots you can safely delete",
                tag: 3
            )
            onboardingPage(
                icon: "photo.fill",
                title: "Clean Screenshots",
                subtitle: "Find and remove old screenshots taking up space",
                tag: 4
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))

        VStack(spacing: 16) {
            Button {
                withAnimation { hasCompletedOnboarding = true }
            } label: {
                Text(currentPage == 4 ? "Get Started" : "Skip")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 32)
    }

    private func onboardingPage(icon: String, title: String, subtitle: String, tag: Int) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 72))
                .foregroundStyle(.blue)
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .tag(tag)
    }
}
