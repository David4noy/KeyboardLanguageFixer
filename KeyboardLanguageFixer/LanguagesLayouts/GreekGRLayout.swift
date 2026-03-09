//
//  GreekGRLayout.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public struct GreekGRLayout: KeyboardLayout {
    public let id = "el-GR"
    public let displayName = "Greek (EL)"
    public let letterShiftIsDistinct = true
    private(set) public var forwardMap: [KeyStroke: String] = [:]

    public init() {
        var m: [KeyStroke:String] = [:]

        // Top row
        setLetter(&m, .keyQ, "ς", "Σ")   // tolerant: map Q to final sigma
        setLetter(&m, .keyW, "ς", "Σ")   // and W as well (helps recovery)
        setLetter(&m, .keyE, "ε", "Ε")
        setLetter(&m, .keyR, "ρ", "Ρ")
        setLetter(&m, .keyT, "τ", "Τ")
        setLetter(&m, .keyY, "υ", "Υ")
        setLetter(&m, .keyU, "θ", "Θ")
        setLetter(&m, .keyI, "ι", "Ι")
        setLetter(&m, .keyO, "ο", "Ο")
        setLetter(&m, .keyP, "π", "Π")

        // Home row
        setLetter(&m, .keyA, "α", "Α")
        setLetter(&m, .keyS, "σ", "Σ")
        setLetter(&m, .keyD, "δ", "Δ")
        setLetter(&m, .keyF, "φ", "Φ")
        setLetter(&m, .keyG, "γ", "Γ")
        setLetter(&m, .keyH, "η", "Η")
        setLetter(&m, .keyJ, "ξ", "Ξ")
        setLetter(&m, .keyK, "κ", "Κ")
        setLetter(&m, .keyL, "λ", "Λ")

        // Bottom row
        setLetter(&m, .keyZ, "ζ", "Ζ")
        setLetter(&m, .keyX, "χ", "Χ")
        setLetter(&m, .keyC, "ψ", "Ψ")
        setLetter(&m, .keyV, "ω", "Ω")
        setLetter(&m, .keyB, "β", "Β")
        setLetter(&m, .keyN, "ν", "Ν")
        setLetter(&m, .keyM, "μ", "Μ")

        // Punctuation (basic)
        set(&m, .comma, ",", "<")
        set(&m, .period, ".", ">")
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
