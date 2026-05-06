import SwiftUI

struct ReportView: View {
    let scanViewModel: ScanViewModel

    var body: some View {
        NavigationStack {
            Group {
                if scanViewModel.scanPhase != .completed {
                    emptyStateView
                } else {
                    reportContentView
                }
            }
            .navigationTitle("Storage Report")
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Report Yet",
            systemImage: "chart.bar",
            description: Text("Run a scan first to see your storage report")
        )
    }

    private var reportContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                totalSpaceCard
                categoryBreakdownCard
                recommendationsCard
            }
            .padding()
        }
    }

    private var totalSpaceCard: some View {
        VStack(spacing: 12) {
            Text("Reclaimable Space")
                .font(.headline)
            Text(ByteCountFormatter.string(fromByteCount: scanViewModel.totalReclaimableSpace, countStyle: .file))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
            Text("out of \(scanViewModel.totalPhotosScanned) photos scanned")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var categoryBreakdownCard: some View {
        VStack(spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            breakdownRow(
                icon: "doc.on.doc.fill",
                title: "Duplicates",
                count: scanViewModel.duplicateCount,
                size: scanViewModel.duplicateSize,
                color: .orange
            )
            breakdownRow(
                icon: "eye.slash.fill",
                title: "Blurry Photos",
                count: scanViewModel.blurryCount,
                size: scanViewModel.blurrySize,
                color: .purple
            )
            breakdownRow(
                icon: "photo.fill",
                title: "Screenshots",
                count: scanViewModel.screenshotCount,
                size: scanViewModel.screenshotSize,
                color: .green
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func breakdownRow(icon: String, title: String, count: Int, size: Int64, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Text("\(count) photos")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                .font(.caption.bold())
                .foregroundStyle(color)
        }
    }

    private var recommendationsCard: some View {
        VStack(spacing: 12) {
            Text("Recommendations")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if scanViewModel.duplicateCount > 0 {
                recommendationRow(
                    icon: "doc.on.doc.fill",
                    text: "Delete \(scanViewModel.duplicateCount) duplicate photos to save \(ByteCountFormatter.string(fromByteCount: scanViewModel.duplicateSize, countStyle: .file))"
                )
            }
            if scanViewModel.blurryCount > 0 {
                recommendationRow(
                    icon: "eye.slash.fill",
                    text: "Remove \(scanViewModel.blurryCount) blurry photos to reclaim \(ByteCountFormatter.string(fromByteCount: scanViewModel.blurrySize, countStyle: .file))"
                )
            }
            if scanViewModel.screenshotCount > 0 {
                recommendationRow(
                    icon: "photo.fill",
                    text: "Clean \(scanViewModel.screenshotCount) screenshots to free \(ByteCountFormatter.string(fromByteCount: scanViewModel.screenshotSize, countStyle: .file))"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func recommendationRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
