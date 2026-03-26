import AppKit
import SwiftUI

/// A single-emoji text field that opens the macOS character viewer on click.
struct EmojiTextField: NSViewRepresentable {
    @Binding var emoji: String

    func makeNSView(context: Context) -> EmojiNSTextField {
        let field = EmojiNSTextField()
        field.delegate = context.coordinator
        field.stringValue = emoji
        field.alignment = .center
        field.font = NSFont.systemFont(ofSize: 24)
        field.isBezeled = true
        field.bezelStyle = .roundedBezel
        field.placeholderString = "+"
        field.focusRingType = .exterior
        return field
    }

    func updateNSView(_ nsView: EmojiNSTextField, context: Context) {
        if nsView.stringValue != emoji {
            nsView.stringValue = emoji
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(emoji: $emoji)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var emoji: Binding<String>

        init(emoji: Binding<String>) {
            self.emoji = emoji
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            let text = field.stringValue

            if text.isEmpty {
                emoji.wrappedValue = ""
                return
            }

            // Find the last character that is a real emoji (not digits, #, * etc.)
            let lastEmoji = text.last.flatMap { char -> String? in
                let scalars = char.unicodeScalars
                let isRealEmoji = scalars.contains { scalar in
                    scalar.properties.isEmoji &&
                    scalar.properties.isEmojiPresentation
                } || (scalars.count > 1 && scalars.first?.properties.isEmoji == true)
                return isRealEmoji ? String(char) : nil
            }

            if let single = lastEmoji {
                emoji.wrappedValue = single
                field.stringValue = single
            } else {
                field.stringValue = emoji.wrappedValue
            }
        }
    }
}

/// Custom NSTextField that shows the emoji picker when it becomes first responder.
final class EmojiNSTextField: NSTextField {
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            // Open the macOS character/emoji viewer
            NSApp.orderFrontCharacterPalette(nil)
        }
        return result
    }
}
