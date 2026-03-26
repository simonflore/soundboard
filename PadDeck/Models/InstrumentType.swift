import Foundation

enum InstrumentType: String, Codable, CaseIterable, Identifiable, Sendable {
    case piano
    case drums
    case marimba
    case synthLead
    case synthPad

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .piano: "Piano"
        case .drums: "Drums"
        case .marimba: "Marimba"
        case .synthLead: "Synth Lead"
        case .synthPad: "Synth Pad"
        }
    }

    var iconName: String {
        switch self {
        case .piano: "pianokeys"
        case .drums: "drum.fill"
        case .marimba: "music.quarternote.3"
        case .synthLead: "waveform"
        case .synthPad: "waveform.path"
        }
    }

    var soundFontFilename: String {
        switch self {
        case .piano: "Piano"
        case .drums: "Drums"
        case .marimba: "Marimba"
        case .synthLead: "SynthLead"
        case .synthPad: "SynthPad"
        }
    }

    var defaultColor: LaunchpadColor {
        switch self {
        case .piano: LaunchpadColor(r: 100, g: 100, b: 127)
        case .drums: LaunchpadColor(r: 127, g: 40, b: 0)
        case .marimba: LaunchpadColor(r: 127, g: 70, b: 10)
        case .synthLead: LaunchpadColor(r: 0, g: 127, b: 30)
        case .synthPad: LaunchpadColor(r: 100, g: 0, b: 127)
        }
    }

    var noteLayout: NoteLayout {
        switch self {
        case .piano: Self.pianoLayout()
        case .drums: Self.drumsLayout()
        case .marimba: Self.marimbaLayout()
        case .synthLead: Self.isomorphicLayout(base: 48, brightColor: LaunchpadColor(r: 0, g: 127, b: 30), dimColor: LaunchpadColor(r: 0, g: 40, b: 10))
        case .synthPad: Self.isomorphicLayout(base: 36, brightColor: LaunchpadColor(r: 100, g: 0, b: 127), dimColor: LaunchpadColor(r: 30, g: 0, b: 50))
        }
    }
}

// Conform to EffectOption (defined in PadDetailView) for reuse in type selector UI
extension InstrumentType: EffectOption {}

// MARK: - Note Layouts

private extension InstrumentType {
    /// Black key semitones within an octave: C#=1, D#=3, F#=6, G#=8, A#=10
    static let blackKeys: Set<UInt8> = [1, 3, 6, 8, 10]

    // MARK: Piano — chromatic, 1 octave per row, starting at C1 (MIDI 24)

    static func pianoLayout() -> NoteLayout {
        NoteLayout(
            noteForPosition: { pos in
                let note = 24 + (pos.row * 12) + pos.column
                guard note <= 108 else { return nil }  // Clamp at C8
                return UInt8(note)
            },
            colorForPosition: { pos in
                let note = 24 + (pos.row * 12) + pos.column
                guard note <= 108 else { return .off }
                let semitone = UInt8(note % 12)
                return blackKeys.contains(semitone)
                    ? LaunchpadColor(r: 15, g: 15, b: 60)
                    : LaunchpadColor(r: 100, g: 100, b: 100)
            },
            pressedColor: LaunchpadColor(r: 127, g: 127, b: 127)
        )
    }

    // MARK: Drums — 4×4 bottom-left quadrant mapped to GM percussion

    static func drumsLayout() -> NoteLayout {
        // Grid[row][col] → GM drum MIDI note
        // Row 0 (bottom), Row 3 (top of quadrant)
        let drumGrid: [[UInt8]] = [
            [36, 35, 40, 43],  // Row 0: Kick, Kick2, SideStick, FloorTom
            [38, 39, 37, 75],  // Row 1: Snare, Clap, Rimshot, Clave
            [50, 47, 45, 56],  // Row 2: HiTom, MidTom, LowTom, Cowbell
            [49, 51, 46, 42],  // Row 3: Crash, Ride, OpenHH, ClosedHH
        ]

        // Color per drum note category
        let drumColor: (UInt8) -> LaunchpadColor = { note in
            switch note {
            case 35, 36: return LaunchpadColor(r: 127, g: 20, b: 0)    // Kicks: red
            case 37, 38, 39, 40: return LaunchpadColor(r: 127, g: 60, b: 0) // Snares: orange
            case 42, 44, 46: return LaunchpadColor(r: 127, g: 127, b: 0)   // Hi-hats: yellow
            case 49, 51, 52, 55: return LaunchpadColor(r: 0, g: 127, b: 127) // Cymbals: cyan
            case 43, 45, 47, 48, 50: return LaunchpadColor(r: 0, g: 127, b: 20) // Toms: green
            default: return LaunchpadColor(r: 80, g: 0, b: 127)             // Percussion: purple
            }
        }

        return NoteLayout(
            noteForPosition: { pos in
                guard pos.row < 4, pos.column < 4 else { return nil }
                return drumGrid[pos.row][pos.column]
            },
            colorForPosition: { pos in
                guard pos.row < 4, pos.column < 4 else { return .off }
                return drumColor(drumGrid[pos.row][pos.column])
            },
            pressedColor: LaunchpadColor(r: 127, g: 127, b: 127)
        )
    }

    // MARK: Marimba — chromatic, 1 octave per row, starting at F2 (MIDI 41)

    static func marimbaLayout() -> NoteLayout {
        NoteLayout(
            noteForPosition: { pos in
                let note = 41 + (pos.row * 12) + pos.column
                guard note <= 127 else { return nil }
                return UInt8(note)
            },
            colorForPosition: { pos in
                let note = 41 + (pos.row * 12) + pos.column
                guard note <= 127 else { return .off }
                let semitone = UInt8(note % 12)
                return blackKeys.contains(semitone)
                    ? LaunchpadColor(r: 50, g: 25, b: 5)
                    : LaunchpadColor(r: 127, g: 70, b: 10)
            },
            pressedColor: LaunchpadColor(r: 127, g: 120, b: 80)
        )
    }

    // MARK: Isomorphic 4ths — each row +5 semitones (used by Synth Lead and Synth Pad)

    static func isomorphicLayout(base: Int, brightColor: LaunchpadColor, dimColor: LaunchpadColor) -> NoteLayout {
        NoteLayout(
            noteForPosition: { pos in
                let note = base + (pos.row * 5) + pos.column
                guard note <= 127 else { return nil }
                return UInt8(note)
            },
            colorForPosition: { pos in
                let note = base + (pos.row * 5) + pos.column
                guard note <= 127 else { return .off }
                return pos.column == 0 ? brightColor : dimColor
            },
            pressedColor: LaunchpadColor(r: 127, g: 127, b: 127)
        )
    }
}
