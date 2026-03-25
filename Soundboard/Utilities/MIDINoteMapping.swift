import Foundation

enum MIDINoteMapping {
    static func isMainGrid(note: UInt8) -> Bool {
        let row = Int(note) / 10
        let col = Int(note) % 10
        return (1...8).contains(row) && (1...8).contains(col)
    }

    static func isTopRow(cc: UInt8) -> Bool {
        (91...98).contains(cc)
    }

    static func isRightColumn(cc: UInt8) -> Bool {
        [19, 29, 39, 49, 59, 69, 79, 89].contains(Int(cc))
    }
}
