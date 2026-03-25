import Foundation

enum AppMode: Equatable {
    case normal
    /// XY performance pad mode — controlling the sample at the given position.
    /// `cursor` tracks the current XY grid position being touched.
    case xyPad(target: GridPosition, cursor: GridPosition?)
}
