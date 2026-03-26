import SwiftUI

struct InstrumentStatusBar: View {
    let instrumentType: InstrumentType
    let onExit: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: instrumentType.iconName)
                .font(.system(size: 14, weight: .medium))

            Text(instrumentType.displayName)
                .font(.system(size: 14, weight: .bold, design: .rounded))

            Spacer()

            Button(action: onExit) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("Exit")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .foregroundStyle(instrumentType.defaultColor.swiftUIColor)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(instrumentType.defaultColor.swiftUIColor.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 14)
        .padding(.top, 14)
    }
}
