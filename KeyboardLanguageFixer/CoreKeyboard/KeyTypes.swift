//
//  KeyTypes.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public enum KeySlot: String, Hashable, CaseIterable {
    case keyA, keyB, keyC, keyD, keyE, keyF, keyG, keyH, keyI, keyJ, keyK, keyL, keyM
    case keyN, keyO, keyP, keyQ, keyR, keyS, keyT, keyU, keyV, keyW, keyX, keyY, keyZ
    case digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, digit8, digit9
    case grave, minus, equal, bracketLeft, bracketRight, backslash
    case semicolon, quote, comma, period, slash
    case space
}

public struct KeyModifiers: Hashable {
    public var shift: Bool
    public init(shift: Bool = false) { self.shift = shift }
    public static let base = KeyModifiers()
    public static let withShift = KeyModifiers(shift: true)
}

public struct KeyStroke: Hashable {
    public let slot: KeySlot
    public let modifiers: KeyModifiers
    public init(slot: KeySlot, modifiers: KeyModifiers) {
        self.slot = slot
        self.modifiers = modifiers
    }
}
