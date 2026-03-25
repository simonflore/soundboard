import UniformTypeIdentifiers

enum AudioFormats {
    static let supportedTypes: [UTType] = [
        .wav, .mp3, .aiff, .mpeg4Audio,
    ]

    static let supportedExtensions: Set<String> = [
        "wav", "mp3", "aac", "m4a", "aiff", "aif",
    ]

    static func isSupported(_ url: URL) -> Bool {
        supportedExtensions.contains(url.pathExtension.lowercased())
    }
}
