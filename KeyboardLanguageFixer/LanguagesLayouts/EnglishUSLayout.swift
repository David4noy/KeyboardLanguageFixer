//
//  EnglishUSLayout.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public struct EnglishUSLayout: KeyboardLayout {
    public let id = "en-US"
    public let displayName = "English (US)"
    public let letterShiftIsDistinct = true
    private(set) public var forwardMap: [KeyStroke: String] = [:]

    public init() {
        var m: [KeyStroke: String] = [:]

        // Letters
        setLetter(&m, .keyQ, "q", "Q")
        setLetter(&m, .keyW, "w", "W")
        setLetter(&m, .keyE, "e", "E")
        setLetter(&m, .keyR, "r", "R")
        setLetter(&m, .keyT, "t", "T")
        setLetter(&m, .keyY, "y", "Y")
        setLetter(&m, .keyU, "u", "U")
        setLetter(&m, .keyI, "i", "I")
        setLetter(&m, .keyO, "o", "O")
        setLetter(&m, .keyP, "p", "P")
        setLetter(&m, .keyA, "a", "A")
        setLetter(&m, .keyS, "s", "S")
        setLetter(&m, .keyD, "d", "D")
        setLetter(&m, .keyF, "f", "F")
        setLetter(&m, .keyG, "g", "G")
        setLetter(&m, .keyH, "h", "H")
        setLetter(&m, .keyJ, "j", "J")
        setLetter(&m, .keyK, "k", "K")
        setLetter(&m, .keyL, "l", "L")
        setLetter(&m, .keyZ, "z", "Z")
        setLetter(&m, .keyX, "x", "X")
        setLetter(&m, .keyC, "c", "C")
        setLetter(&m, .keyV, "v", "V")
        setLetter(&m, .keyB, "b", "B")
        setLetter(&m, .keyN, "n", "N")
        setLetter(&m, .keyM, "m", "M")

        // Digits row
        set(&m, .digit1, "1", "!")
        set(&m, .digit2, "2", "@")
        set(&m, .digit3, "3", "#")
        set(&m, .digit4, "4", "$")
        set(&m, .digit5, "5", "%")
        set(&m, .digit6, "6", "^")
        set(&m, .digit7, "7", "&")
        set(&m, .digit8, "8", "*")
        set(&m, .digit9, "9", "(")
        set(&m, .digit0, "0", ")")

        // Punctuation
        set(&m, .minus, "-", "_")
        set(&m, .equal, "=", "+")
        set(&m, .bracketLeft, "[", "{")
        set(&m, .bracketRight, "]", "}")
        set(&m, .backslash, "\\", "|")
        set(&m, .semicolon, ";", ":")
        set(&m, .quote, "'", "\"")
        set(&m, .comma, ",", "<")
        set(&m, .period, ".", ">")
        set(&m, .slash, "/", "?")
        set(&m, .grave, "`", "~")

        // Space
        set(&m, .space, " ")

        forwardMap = m
    }

    // MARK: - helpers
    private func setLetter(_ map: inout [KeyStroke: String], _ slot: KeySlot, _ lower: String, _ upper: String) {
        map[KeyStroke(slot: slot, modifiers: .base)] = lower
        map[KeyStroke(slot: slot, modifiers: .withShift)] = upper
    }
    private func set(_ map: inout [KeyStroke: String], _ slot: KeySlot, _ base: String, _ shift: String? = nil) {
        map[KeyStroke(slot: slot, modifiers: .base)] = base
        map[KeyStroke(slot: slot, modifiers: .withShift)] = shift ?? base
    }
}
