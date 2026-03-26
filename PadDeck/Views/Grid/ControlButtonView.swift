import SwiftUI

struct ControlButtonView: View {
    let icon: String
    let label: String
    let accentColor: Color
    var isActive: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif

    var body: some View {
        Button(action: action) {
            Group {
                if isCompact {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                } else {
                    VStack(spacing: 2) {
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(label)
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(isEnabled ? (isActive ? accentColor : .white.opacity(0.7)) : .white.opacity(0.2))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive ? accentColor.opacity(0.25) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(
                        isActive ? accentColor.opacity(0.4) : Color.white.opacity(0.06),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}
