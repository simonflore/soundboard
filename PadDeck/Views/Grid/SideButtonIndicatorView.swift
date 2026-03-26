import SwiftUI

struct SideButtonIndicatorView: View {
    let indicator: SideButtonIndicator

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: indicator.icon)
                .font(.system(size: 14, weight: .medium))

            Text(indicator.message)
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundStyle(indicator.accentColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(indicator.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
