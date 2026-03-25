import Foundation

enum LaunchpadProtocol {
    static let sysExHeader: [UInt8] = [0x00, 0x20, 0x29, 0x02, 0x0C]

    static func programmerModeMessage() -> [UInt8] {
        [0xF0] + sysExHeader + [0x0E, 0x01, 0xF7]
    }

    static func liveModeMessage() -> [UInt8] {
        [0xF0] + sysExHeader + [0x0E, 0x00, 0xF7]
    }

    static func rgbLEDMessage(note: UInt8, r: UInt8, g: UInt8, b: UInt8) -> [UInt8] {
        [0xF0] + sysExHeader + [0x03, 0x03, note, r, g, b, 0xF7]
    }

    static func paletteLEDMessage(note: UInt8, type: UInt8, colorIndex: UInt8) -> [UInt8] {
        [0xF0] + sysExHeader + [0x03, type, note, colorIndex, 0xF7]
    }

    /// Batch set multiple LEDs to RGB. More efficient than individual messages.
    static func batchRGBMessage(entries: [(note: UInt8, r: UInt8, g: UInt8, b: UInt8)]) -> [UInt8] {
        var msg: [UInt8] = [0xF0] + sysExHeader + [0x03]
        for entry in entries {
            msg += [0x03, entry.note, entry.r, entry.g, entry.b]
        }
        msg += [0xF7]
        return msg
    }
}
