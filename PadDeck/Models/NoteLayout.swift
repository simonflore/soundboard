import Foundation

struct NoteLayout {
    /// Returns the MIDI note for a grid position, or nil if the pad is inactive.
    let noteForPosition: (GridPosition) -> UInt8?

    /// Returns the LED color for a grid position (rest state).
    let colorForPosition: (GridPosition) -> LaunchpadColor

    /// Color to show when a pad is pressed.
    let pressedColor: LaunchpadColor
}
