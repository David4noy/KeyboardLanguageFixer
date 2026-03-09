//
//  KeyboardLayout.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public protocol KeyboardLayout {
    var id: String { get }
    var displayName: String { get }
    var letterShiftIsDistinct: Bool { get }
    var forwardMap: [KeyStroke: String] { get }
}

public extension KeyboardLayout {
    // Deterministic reverse map preferring base over shift
    var reverseMap: [Character: KeyStroke] {
        var map: [Character: KeyStroke] = [:]
        let order: [KeyModifiers] = [.base, .withShift]
        for slot in KeySlot.allCases {
            for mods in order {
                let stroke = KeyStroke(slot: slot, modifiers: mods)
                if let out = forwardMap[stroke], out.count == 1, let ch = out.first, map[ch] == nil {
                    map[ch] = stroke
                }
            }
        }
        return map
    }
}
