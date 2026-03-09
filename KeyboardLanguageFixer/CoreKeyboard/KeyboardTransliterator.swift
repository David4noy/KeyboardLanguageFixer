//
//  KeyboardTransliterator.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public struct KeyboardTransliterator {
    public init() {}

    public func transliterate(
        _ text: String,
        from fromLayout: KeyboardLayout,
        to toLayout: KeyboardLayout,
        preserveLetterShift: Bool
    ) -> String {
        var result = String()
        result.reserveCapacity(text.count)

        let reverse = fromLayout.reverseMap

        for ch in text {
            // Try exact, else lowercase fallback
            let lowerCh = Character(String(ch).lowercased())
            guard let stroke = reverse[ch] ?? reverse[lowerCh] else {
                result.append(ch)
                continue
            }

            // --- Key rule fix ---
            // If we are NOT preserving letter shift, but the source char is a SHIFT-produced punctuation,
            // pass it through unchanged (e.g., ":" "<" ">" "?" "\"" "{" "}" "|" "~" "!" ...).
            if preserveLetterShift == false,
               stroke.modifiers.shift == true,
               isAsciiPunctuation(ch) {
                result.append(ch)
                continue
            }
            // ---------------------

            let inferredUpperLatin = isUppercaseLatin(ch)
            let keepShift = preserveLetterShift ? (stroke.modifiers.shift || inferredUpperLatin) : false

            let target = KeyStroke(slot: stroke.slot, modifiers: KeyModifiers(shift: keepShift))
            let fallback = KeyStroke(slot: stroke.slot, modifiers: .base)

            if let mapped = toLayout.forwardMap[target] ?? toLayout.forwardMap[fallback] {
                result.append(mapped)
            } else {
                result.append(ch)
            }
        }

        return result
    }

    private func isUppercaseLatin(_ ch: Character) -> Bool {
        let s = String(ch)
        return s == s.uppercased() && s != s.lowercased()
    }

    private func isAsciiPunctuation(_ ch: Character) -> Bool {
        // Treat all non-alphanumeric ASCII symbols as punctuation
        // This set covers common symbols produced via Shift on US layout.
        let punct = "!@#$%^&*()_+{}|:\"<>?`~-=\\[];',./"
        return ch.unicodeScalars.allSatisfy { scalar in
            scalar.isASCII && punct.contains(Character(UnicodeScalar(scalar)))
        }
    }
}
