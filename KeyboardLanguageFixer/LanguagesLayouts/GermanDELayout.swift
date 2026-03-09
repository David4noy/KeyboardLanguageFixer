//
//  GermanDELayout.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation

public struct GermanDELayout: KeyboardLayout {
    public let id = "de-DE"
    public let displayName = "German (DE QWERTZ)"
    public let letterShiftIsDistinct = true
    private(set) public var forwardMap: [KeyStroke: String] = [:]

   

    public init() {
        var m: [KeyStroke:String] = [:]

        // Letters (QWERTZ: y<->z)
        setLetter(&m, .keyQ, "q","Q");
        setLetter(&m, .keyW, "w","W")
        setLetter(&m, .keyE, "e","E");
        setLetter(&m, .keyR, "r","R")
        setLetter(&m, .keyT, "t","T")
        setLetter(&m, .keyY, "z","Z") // swapped
        setLetter(&m, .keyU, "u","U");
        setLetter(&m, .keyI, "i","I")
        setLetter(&m, .keyO, "o","O");
        setLetter(&m, .keyP, "p","P")

        setLetter(&m, .keyA, "a","A");
        setLetter(&m, .keyS, "s","S")
        setLetter(&m, .keyD, "d","D");
        setLetter(&m, .keyF, "f","F")
        setLetter(&m, .keyG, "g","G");
        setLetter(&m, .keyH, "h","H")
        setLetter(&m, .keyJ, "j","J");
        setLetter(&m, .keyK, "k","K")
        setLetter(&m, .keyL, "l","L")

        setLetter(&m, .keyZ, "y","Y") // swapped
        setLetter(&m, .keyX, "x","X");
        setLetter(&m, .keyC, "c","C")
        setLetter(&m, .keyV, "v","V");
        setLetter(&m, .keyB, "b","B")
        setLetter(&m, .keyN, "n","N");
        setLetter(&m, .keyM, "m","M")

        // Umlauts / ß (positions approximate for physical-key mapping use-case)
        setLetter(&m, .bracketLeft,  "ü","Ü")
        setLetter(&m, .semicolon,    "ö","Ö")
        setLetter(&m, .quote,        "ä","Ä")
        setLetter(&m, .minus,        "ß","ẞ")

        // Common punctuation
        set(&m, .comma, ",","<")
        set(&m, .period, ".",">")
        set(&m, .slash, "/","?")
        set(&m, .backslash, "\\","|")
        set(&m, .equal, "=","+")
        set(&m, .space, " ")

        forwardMap = m
    }
    
    // helpers (not nested in init)
    private func setLetter(_ map: inout [KeyStroke:String], _ slot: KeySlot, _ lower: String, _ upper: String) {
        map[KeyStroke(slot: slot, modifiers: .base)] = lower
        map[KeyStroke(slot: slot, modifiers: .withShift)] = upper
    }
    private func set(_ map: inout [KeyStroke:String], _ slot: KeySlot, _ base: String, _ shift: String? = nil) {
        map[KeyStroke(slot: slot, modifiers: .base)] = base
        map[KeyStroke(slot: slot, modifiers: .withShift)] = shift ?? base
    }
}
