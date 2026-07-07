import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 56))
                        .foregroundColor(Theme.accent)
                    Text("Recovery Log Pro")
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.textPrimary)
                    Text("Milestone badges and multiple tracked goals")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                    Button {
                        Task {
                            await purchases.purchase()
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        Text(purchases.product != nil ? "Unlock for \(purchases.product!.displayPrice)" : "Unlock Pro")
                            .font(Theme.headlineFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityIdentifier("unlockButton")
                    .padding(.horizontal)

                    Button("Restore Purchases") {
                        Task {
                            await purchases.restore()
                            if purchases.isPro { dismiss() }
                        }
                    }
                    .accessibilityIdentifier("restoreButtonPaywall")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)

                    Button("Not now") { dismiss() }
                        .accessibilityIdentifier("dismissPaywallButton")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.textSecondary)
                        .padding(.bottom)
                }
                .padding()
            }
        }
    }
}
