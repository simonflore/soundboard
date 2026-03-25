import Foundation

struct PadConfiguration: Codable, Identifiable, Sendable {
    let position: GridPosition
    var sample: Sample?
    var color: LaunchpadColor
    var playMode: PlayMode
    var volume: Float
    var emoji: String?

    var id: Int { position.id }
    var isEmpty: Bool { sample == nil }

    init(position: GridPosition) {
        self.position = position
        self.sample = nil
        self.color = .off
        self.playMode = .oneShot
        self.volume = 1.0
        self.emoji = nil
    }

    init(position: GridPosition, sample: Sample?, color: LaunchpadColor, playMode: PlayMode, volume: Float, emoji: String? = nil) {
        self.position = position
        self.sample = sample
        self.color = color
        self.playMode = playMode
        self.volume = volume
        self.emoji = emoji
    }
}
