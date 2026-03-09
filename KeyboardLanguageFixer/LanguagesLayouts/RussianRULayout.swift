//
//  RussianRULayout.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public struct RussianRULayout: KeyboardLayout {
    public let id = "ru-RU"
    public let displayName = "Russian (JCUKEN)"
    public let letterShiftIsDistinct = true
    private(set) public var forwardMap: [KeyStroke: String] = [:]

    public init() {
        var m: [KeyStroke:String] = [:]

        // Top row
        setLetter(&m, .keyQ, "й","Й")
        setLetter(&m, .keyW, "ц","Ц")
        setLetter(&m, .keyE, "у","У")
        setLetter(&m, .keyR, "к","К")
        setLetter(&m, .keyT, "е","Е")
        setLetter(&m, .keyY, "н","Н")
        setLetter(&m, .keyU, "г","Г")
        setLetter(&m, .keyI, "ш","Ш")
        setLetter(&m, .keyO, "щ","Щ")
        setLetter(&m, .keyP, "з","З")
        setLetter(&m, .bracketLeft, "х","Х")
        setLetter(&m, .bracketRight, "ъ","Ъ")

        // Home row
        setLetter(&m, .keyA, "ф","Ф")
        setLetter(&m, .keyS, "ы","Ы")
        setLetter(&m, .keyD, "в","В")
        setLetter(&m, .keyF, "а","А")
        setLetter(&m, .keyG, "п","П")
        setLetter(&m, .keyH, "р","Р")
        setLetter(&m, .keyJ, "о","О")
        setLetter(&m, .keyK, "л","Л")
        setLetter(&m, .keyL, "д","Д")
        setLetter(&m, .semicolon, "ж","Ж")
        setLetter(&m, .quote, "э","Э")

        // Bottom row
        setLetter(&m, .keyZ, "я","Я")
        setLetter(&m, .keyX, "ч","Ч")
        setLetter(&m, .keyC, "с","С")
        setLetter(&m, .keyV, "м","М")
        setLetter(&m, .keyB, "и","И")
        setLetter(&m, .keyN, "т","Т")
        setLetter(&m, .keyM, "ь","Ь")
        setLetter(&m, .comma, "б","Б")
        setLetter(&m, .period, "ю","Ю")

        // Basic punctuation used in the common recovery scenario
        set(&m, .slash, ".")
        set(&m, .space, " ")

        forwardMap = m
    }

    // helpers
    private func setLetter(_ map: inout [KeyStroke:String], _ slot: KeySlot, _ lower: String, _ upper: String) {
        map[KeyStroke(slot: slot, modifiers: .base)] = lower
        map[KeyStroke(slot: slot, modifiers: .withShift)] = upper
    }
    private func set(_ map: inout [KeyStroke:String], _ slot: KeySlot, _ base: String, _ shift: String? = nil) {
        map[KeyStroke(slot: slot, modifiers: .base)] = base
        map[KeyStroke(slot: slot, modifiers: .withShift)] = shift ?? base
    }
}
