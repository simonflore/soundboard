import SwiftUI

struct PlayEditToggle: View {
    @Binding var isEditMode: Bool
    var compact: Bool = false

    private let cornerRadius: CGFloat = 8

    var body: some View {
        if compact {
            compactLayout
        } else {
            fullLayout
        }
    }

    // MARK: - Full (macOS / iPad)

    private var fullLayout: some View {
        HStack(spacing: 0) {
            segmentButton(label: "Play", icon: "play.fill", isSelected: !isEditMode) {
                isEditMode = false
            }
            segmentButton(label: "Edit", icon: "pencil", isSelected: isEditMode) {
                isEditMode = true
            }
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isEditMode)
    }

    private func segmentButton(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                isSelected
                    ? (isEditMode ? Color.orange.opacity(0.4) : Color.green.opacity(0.25))
                    : Color.clear
            )
            .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Compact (iPhone)

    private var compactLayout: some View {
        HStack(spacing: 0) {
            compactSegment(icon: "play.fill", isSelected: !isEditMode) {
                isEditMode = false
            }
            compactSegment(icon: "pencil", isSelected: isEditMode) {
                isEditMode = true
            }
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isEditMode)
    }

    private func compactSegment(icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .frame(width: 44, height: 44)
                .background(
                    isSelected
                        ? (isEditMode ? Color.orange.opacity(0.4) : Color.green.opacity(0.25))
                        : Color.clear
                )
                .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
        }
        .buttonStyle(.plain)
    }
}
