import SwiftUI

struct SideButtonIndicator: Equatable {
    let message: String
    let icon: String
    let accentColor: Color

    static func == (lhs: SideButtonIndicator, rhs: SideButtonIndicator) -> Bool {
        lhs.message == rhs.message && lhs.icon == rhs.icon
    }
}
