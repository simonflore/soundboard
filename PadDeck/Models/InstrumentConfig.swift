import Foundation

struct InstrumentConfig: Codable, Equatable, Sendable {
    var instrumentType: InstrumentType
    var volume: Float

    init(instrumentType: InstrumentType, volume: Float = 0.8) {
        self.instrumentType = instrumentType
        self.volume = volume
    }
}
