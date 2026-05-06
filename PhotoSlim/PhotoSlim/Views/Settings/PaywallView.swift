import SwiftUI
import StoreKit

struct PaywallView: View {
    let storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    comparisonSection
                    purchaseSection
                    restoreSection
                }
                .padding()
            }
            .navigationTitle("PhotoSlim Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("Unlock Full Power")
                .font(.title.bold())

            Text("One-time purchase. No subscriptions. Ever.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    private var comparisonSection: some View {
        VStack(spacing: 0) {
            comparisonRow(free: "5 deletes/day", pro: "Unlimited deletes", isProBetter: true)
            comparisonRow(free: "View scan results", pro: "View + clean results", isProBetter: true)
            comparisonRow(free: "Basic scan", pro: "Full scan + face groups", isProBetter: true)
            comparisonRow(free: "—", pro: "Scan history", isProBetter: true)
            comparisonRow(free: "—", pro: "Priority support", isProBetter: true)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func comparisonRow(free: String, pro: String, isProBetter: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Free")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                Text(free)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("Pro")
                        .font(.caption2.bold())
                        .foregroundStyle(.blue)
                    if isProBetter {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.yellow)
                    }
                }
                Text(pro)
                    .font(.caption)
                    .bold(isProBetter)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            if let product = storeManager.product {
                Button {
                    Task {
                        isPurchasing = true
                        await storeManager.purchasePro()
                        isPurchasing = false
                        if storeManager.isPro { dismiss() }
                    }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isPurchasing ? "Purchasing..." : "Buy PhotoSlim Pro — \(product.displayPrice)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isPurchasing)
            } else {
                ProgressView()
                    .padding()
            }

            Text("One-time purchase • No subscription • Forever yours")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var restoreSection: some View {
        Button {
            Task { await storeManager.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
    }
}
