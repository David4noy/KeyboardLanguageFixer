//
//  HebrewILLayout.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public struct HebrewILLayout: KeyboardLayout {
    public let id = "he-IL"
    public let displayName = "Hebrew (IL)"
    public let letterShiftIsDistinct = false
    private(set) public var forwardMap: [KeyStroke: String] = [:]

    public init() {
        var m: [KeyStroke: String] = [:]

        // Top row (Q/W are punctuation on IL)
        putSame(&m, .keyQ, "/")
        putSame(&m, .keyW, "'")
        putSame(&m, .keyE, "ק")
        putSame(&m, .keyR, "ר")
        putSame(&m, .keyT, "א")
        putSame(&m, .keyY, "ט")
        putSame(&m, .keyU, "ו")
        putSame(&m, .keyI, "ן")
        putSame(&m, .keyO, "ם")
        putSame(&m, .keyP, "פ")

        // Home row
        putSame(&m, .keyA, "ש")
        putSame(&m, .keyS, "ד")
        putSame(&m, .keyD, "ג")
        putSame(&m, .keyF, "כ")
        putSame(&m, .keyG, "ע")
        putSame(&m, .keyH, "י")
        putSame(&m, .keyJ, "ח")
        putSame(&m, .keyK, "ל")
        putSame(&m, .keyL, "ך")

        // Bottom row
        putSame(&m, .keyZ, "ז")
        putSame(&m, .keyX, "ס")
        putSame(&m, .keyC, "ב")
        putSame(&m, .keyV, "ה")
        putSame(&m, .keyB, "נ")
        putSame(&m, .keyN, "מ")
        putSame(&m, .keyM, "צ")

        // Finals / punctuation keys per IL
        putSame(&m, .semicolon, "ף")
        putSame(&m, .comma, "ת")
        putSame(&m, .period, "ץ")

        // Common IL punctuation on US-punc keys
        putSame(&m, .quote, ",")     // quote prints comma
        putSame(&m, .slash, ".")     // slash prints period

        // Digits row (keep US digits/punct for cross-layout recovery)
        put(&m, .digit1, "1", "!")
        put(&m, .digit2, "2", "@")
        put(&m, .digit3, "3", "#")
        put(&m, .digit4, "4", "$")
        put(&m, .digit5, "5", "%")
        put(&m, .digit6, "6", "^")
        put(&m, .digit7, "7", "&")
        put(&m, .digit8, "8", "*")
        put(&m, .digit9, "9", "(")
        put(&m, .digit0, "0", ")")

        // Basic punctuation kept US-like for numbers/punct usability
        put(&m, .minus, "-", "_")
        put(&m, .equal, "=", "+")
        put(&m, .bracketLeft, "[", "{")
        put(&m, .bracketRight, "]", "}")
        put(&m, .backslash, "\\", "|")
        put(&m, .grave, "`", "~")

        // Space
        forwardMap[KeyStroke(slot: .space, modifiers: .base)] = " "

        forwardMap = m
    }

    // MARK: - helpers
    private func putSame(_ map: inout [KeyStroke: String], _ slot: KeySlot, _ ch: String) {
        map[KeyStroke(slot: slot, modifiers: .base)] = ch
        map[KeyStroke(slot: slot, modifiers: .withShift)] = ch
    }

    private func put(_ map: inout [KeyStroke: String], _ slot: KeySlot, _ base: String, _ shift: String? = nil) {
        map[KeyStroke(slot: slot, modifiers: .base)] = base
        map[KeyStroke(slot: slot, modifiers: .withShift)] = shift ?? base
    }
}
