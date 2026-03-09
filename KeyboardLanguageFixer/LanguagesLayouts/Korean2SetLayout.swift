//
//  Korean2SetLayout.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public struct Korean2SetLayout: KeyboardLayout {
    public let id = "ko-KR-2set"
    public let displayName = "Korean (2-Set, jamo)"
    public let letterShiftIsDistinct = true
    private(set) public var forwardMap: [KeyStroke: String] = [:]

    public init() {
        var m: [KeyStroke:String] = [:]

        // Top row
        set(&m, .keyQ, "ㅂ", "ㅃ")
        set(&m, .keyW, "ㅈ", "ㅉ")
        set(&m, .keyE, "ㄷ", "ㄸ")
        set(&m, .keyR, "ㄱ", "ㄲ")
        set(&m, .keyT, "ㅅ", "ㅆ")
        set(&m, .keyY, "ㅛ")
        set(&m, .keyU, "ㅕ")
        set(&m, .keyI, "ㅑ")
        set(&m, .keyO, "ㅐ", "ㅒ")
        set(&m, .keyP, "ㅔ", "ㅖ")

        // Home row
        set(&m, .keyA, "ㅁ")
        set(&m, .keyS, "ㄴ")
        set(&m, .keyD, "ㅇ")
        set(&m, .keyF, "ㄹ")
        set(&m, .keyG, "ㅎ")
        set(&m, .keyH, "ㅗ")
        set(&m, .keyJ, "ㅓ")
        set(&m, .keyK, "ㅏ")
        set(&m, .keyL, "ㅣ")

        // Bottom row
        set(&m, .keyZ, "ㅋ")
        set(&m, .keyX, "ㅌ")
        set(&m, .keyC, "ㅊ")
        set(&m, .keyV, "ㅍ")
        set(&m, .keyB, "ㅠ")
        set(&m, .keyN, "ㅜ")
        set(&m, .keyM, "ㅡ")

        // Space
        set(&m, .space, " ")

        forwardMap = m
    }

    // helpers
    private func set(_ map: inout [KeyStroke:String], _ slot: KeySlot, _ base: String, _ shift: String? = nil) {
        map[KeyStroke(slot: slot, modifiers: .base)] = base
        map[KeyStroke(slot: slot, modifiers: .withShift)] = shift ?? base
    }
}
