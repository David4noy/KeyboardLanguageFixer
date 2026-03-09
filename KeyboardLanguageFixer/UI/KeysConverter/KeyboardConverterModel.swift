//
//  KeyboardConverterModel.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation
import SwiftUI
import Combine

final class KeyboardConverterModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""

    @Published var fromLang: Language = .hebrew
    @Published var toLang: Language = .english

    enum Language: String, CaseIterable, Identifiable {
        case english, hebrew, korean
        case german, greek, ukrainian, russian
        var id: String { rawValue }
        var label: String {
            switch self {
            case .english:   return "English"
            case .hebrew:    return "Hebrew"
            case .korean:    return "Korean"
            case .german:    return "German"
            case .greek:     return "Greek"
            case .ukrainian: return "Ukrainian"
            case .russian:   return "Russian"
            }
        }
    }

    private let transliterator = KeyboardTransliterator()
    private let hangul = HangulComposer()

    // Layouts
    private let englishLayout   = EnglishUSLayout()
    private let hebrewLayout    = HebrewILLayout()
    private let koreanLayout    = Korean2SetLayout()   // jamo
    private let germanLayout    = GermanDELayout()
    private let greekLayout     = GreekGRLayout()
    private let ukrainianLayout = UkrainianUALayout()
    private let russianLayout   = RussianRULayout()

    func convert() {
        outputText = convert(text: inputText, from: fromLang, to: toLang)
    }

    func swapIO() {
        swap(&inputText, &outputText)
        swap(&fromLang, &toLang)
    }

    private func layout(for lang: Language) -> KeyboardLayout {
        switch lang {
        case .english:   return englishLayout
        case .hebrew:    return hebrewLayout
        case .korean:    return koreanLayout
        case .german:    return germanLayout
        case .greek:     return greekLayout
        case .ukrainian: return ukrainianLayout
        case .russian:   return russianLayout
        }
    }

    private func convert(text: String, from: Language, to: Language) -> String {
        if from == to { return text }

        // Korean glue (compose/decompose)
        if from == .korean && to != .korean {
            let jamo = hangul.decomposeToCompatibility(text)
            let out = transliterator.transliterate(
                jamo,
                from: koreanLayout,
                to: layout(for: to),
                preserveLetterShift: shouldPreserveShift(from: from, to: to)
            )
            return (to == .english) ? out.lowercased() : out
        }
        if to == .korean && from != .korean {
            let jamo = transliterator.transliterate(
                text,
                from: layout(for: from),
                to: koreanLayout,
                preserveLetterShift: shouldPreserveShift(from: from, to: to)
            )
            return hangul.composeFromCompatibility(jamo)
        }

        // All other pairs
        var out = transliterator.transliterate(
            text,
            from: layout(for: from),
            to: layout(for: to),
            preserveLetterShift: shouldPreserveShift(from: from, to: to)
        )
        if to == .english && from != .english {
            out = out.lowercased()
        }
        return out
    }

    private func shouldPreserveShift(from: Language, to: Language) -> Bool {
        // Keep shift almost everywhere; special-case Eng→Heb to avoid forcing letter shift.
        if from == .english && to == .hebrew { return false }
        return true
    }
}
