import SwiftUI

struct SideIndicatorView: View {
    let level: Int
    let activeStep: Int
    let hasVocalPad: Bool

    private var isLit: Bool {
        hasVocalPad && level < activeStep
    }

    /// Green (dry) → Blue (wet) gradient across 8 levels
    private var litColor: Color {
        let t = Double(level) / 7.0
        return Color(
            red: 0,
            green: 0.5 * (1.0 - t),
            blue: 0.1 + 0.9 * t
        )
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(isLit ? litColor : Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        isLit ? litColor.opacity(0.5) : Color.white.opacity(0.04),
                        lineWidth: 1
                    )
            )
    }
}
