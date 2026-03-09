//
//  HangulComposer.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

// Converts between compatibility jamo (e.g., ㅇㅏㄴㄴㅕㅇ) and composed Hangul syllables (e.g., 안녕).
// All comments are in English only.

// HangulComposer.swift
// Compose/decompose Hangul from/to compatibility jamo (e.g., ㅇㅏㄴㄴㅕㅇ <-> 안녕).
// Comments are English only.

import Foundation

public final class HangulComposer {

    public init() {}

    // MARK: - Public API

    public func composeFromCompatibility(_ text: String) -> String {
        let chars = Array(text)
        var i = 0
        var result = String()

        var pendingL: Character? = nil   // standard initial jamo (ᄀ…ᄒ)
        var pendingV: Character? = nil   // standard medial jamo (ᅡ…ᅵ)

        while i < chars.count {
            let ch = chars[i]

            if compatConsonants.contains(ch) {
                if pendingL == nil {
                    // Start L
                    if let l = compatToL[ch] { pendingL = l } else { result.append(ch) }
                    i += 1
                    continue
                }

                if let l = pendingL, let v = pendingV {
                    // We have LV; decide if this consonant is final T or starts next syllable.
                    let nextIsVowel = (i + 1 < chars.count) ? compatVowels.contains(chars[i + 1]) : false
                    if nextIsVowel {
                        // Close LV as syllable without T; start new L with this consonant
                        if let syll = composeSyllable(l: l, v: v, t: nil) {
                            result.append(syll)
                        } else {
                            result.append(standardLToCompat[l] ?? l)
                            result.append(standardVToCompat[v] ?? v)
                        }
                        pendingL = compatToL[ch]
                        pendingV = nil
                        i += 1
                        continue
                    } else {
                        // Treat as final T (maybe a cluster with the next consonant)
                        var consumed = 1
                        var tStd: Character? = compatToT[ch]
                        if i + 1 < chars.count, compatConsonants.contains(chars[i + 1]) {
                            let pair = Bigram(ch, chars[i + 1])
                            if let cluster = compatPairToT[pair] { tStd = cluster; consumed = 2 }
                        }

                        if let syll = composeSyllable(l: l, v: v, t: tStd) {
                            result.append(syll)
                        } else {
                            result.append(standardLToCompat[l] ?? l)
                            result.append(standardVToCompat[v] ?? v)
                            if let t = tStd { result.append(standardTToCompat[t] ?? t) }
                        }
                        pendingL = nil
                        pendingV = nil
                        i += consumed
                        continue
                    }
                } else {
                    // Had L but no V; flush L and restart (rare case)
                    if let l = pendingL {
                        result.append(standardLToCompat[l] ?? l)
                        pendingL = nil
                    }
                    pendingL = compatToL[ch]
                    i += 1
                    continue
                }
            } else if compatVowels.contains(ch) {
                if pendingL == nil {
                    // Leading vowel (no implicit ᄋ insertion) – output as-is
                    result.append(ch)
                    i += 1
                    continue
                }

                if pendingV == nil {
                    // Set V (try to combine with next vowel to a composite)
                    var v = compatToV[ch]
                    var consumed = 1
                    if i + 1 < chars.count {
                        let pair = Bigram(ch, chars[i + 1])
                        if let composite = compatVowelPairToV[pair] { v = composite; consumed = 2 }
                    }
                    pendingV = v
                    i += consumed
                    continue
                } else {
                    // Already have V: close current LV and reprocess current vowel in next loop
                    if let l = pendingL, let v = pendingV {
                        if let syll = composeSyllable(l: l, v: v, t: nil) {
                            result.append(syll)
                        } else {
                            result.append(standardLToCompat[l] ?? l)
                            result.append(standardVToCompat[v] ?? v)
                        }
                    }
                    pendingL = nil
                    pendingV = nil
                    // do not advance; let loop handle current vowel again
                    continue
                }
            } else {
                // Non-Korean char – flush and append
                if let l = pendingL, let v = pendingV {
                    if let syll = composeSyllable(l: l, v: v, t: nil) {
                        result.append(syll)
                    } else {
                        result.append(standardLToCompat[l] ?? l)
                        result.append(standardVToCompat[v] ?? v)
                    }
                    pendingL = nil
                    pendingV = nil
                } else if let l = pendingL {
                    result.append(standardLToCompat[l] ?? l)
                    pendingL = nil
                }
                result.append(ch)
                i += 1
            }
        }

        // Flush tail
        if let l = pendingL, let v = pendingV {
            if let syll = composeSyllable(l: l, v: v, t: nil) {
                result.append(syll)
            } else {
                result.append(standardLToCompat[l] ?? l)
                result.append(standardVToCompat[v] ?? v)
            }
        } else if let l = pendingL {
            result.append(standardLToCompat[l] ?? l)
        }

        return result
    }

    public func decomposeToCompatibility(_ text: String) -> String {
        var result = String()
        for ch in text {
            guard let scalar = ch.unicodeScalars.first else { result.append(ch); continue }
            let v = scalar.value
            if v >= HangulComposer.SBase && v < HangulComposer.SBase + UInt32(HangulComposer.SCount) {
                let sIndex = Int(v - HangulComposer.SBase)
                let lIndex = sIndex / HangulComposer.NCount
                let vIndex = (sIndex % HangulComposer.NCount) / HangulComposer.TCount
                let tIndex = sIndex % HangulComposer.TCount

                let lChar = standardL[lIndex]
                let vChar = standardV[vIndex]
                result.append(standardLToCompat[lChar] ?? lChar)
                result.append(standardVToCompat[vChar] ?? vChar)
                if tIndex > 0 {
                    let tChar = standardT[tIndex]
                    result.append(standardTToCompat[tChar] ?? tChar)
                }
            } else {
                result.append(ch)
            }
        }
        return result
    }

    // MARK: - Core

    private func composeSyllable(l: Character, v: Character, t: Character?) -> Character? {
        guard let lIdx = standardLIndex[l],
              let vIdx = standardVIndex[v] else { return nil }

        let tIdx = t.flatMap { standardTIndex[$0] } ?? 0

        // FIX: use VCount (21) here, not NCount (VCount * TCount).
        let sIndex = (lIdx * HangulComposer.VCount + vIdx) * HangulComposer.TCount + tIdx
        let scalarValue = HangulComposer.SBase + UInt32(sIndex)

        return UnicodeScalar(scalarValue).map(Character.init)
    }

    // MARK: - Data

    private struct Bigram: Hashable {
        let first: Character
        let second: Character
        init(_ a: Character, _ b: Character) { first = a; second = b }
    }

    // Unicode constants
    static let SBase: UInt32 = 0xAC00
    static let LBase: UInt32 = 0x1100
    static let VBase: UInt32 = 0x1161
    static let TBase: UInt32 = 0x11A7
    static let LCount = 19, VCount = 21, TCount = 28
    static let NCount = VCount * TCount
    static let SCount = LCount * NCount

    // Standard jamo arrays and maps
    private static let LChars: [Character] = (0..<LCount)
        .compactMap { UnicodeScalar(LBase + UInt32($0)).map(Character.init) }
    private static let VChars: [Character] = (0..<VCount)
        .compactMap { UnicodeScalar(VBase + UInt32($0)).map(Character.init) }
    private static let TChars: [Character] = (0..<TCount)
        .compactMap { UnicodeScalar(TBase + UInt32($0)).map(Character.init) } // index 0 is "null"

    private let standardL = HangulComposer.LChars
    private let standardV = HangulComposer.VChars
    private let standardT = HangulComposer.TChars

    private lazy var standardLIndex: [Character: Int] = {
        var map: [Character: Int] = [:]; for (i,c) in standardL.enumerated() { map[c] = i }; return map
    }()
    private lazy var standardVIndex: [Character: Int] = {
        var map: [Character: Int] = [:]; for (i,c) in standardV.enumerated() { map[c] = i }; return map
    }()
    private lazy var standardTIndex: [Character: Int] = {
        var map: [Character: Int] = [:]; for (i,c) in standardT.enumerated() { map[c] = i }; return map
    }()

    // Compatibility sets
    private let compatConsonants: Set<Character> = [
        "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    private let compatVowels: Set<Character> = [
        "ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅛ","ㅜ","ㅠ","ㅡ","ㅣ"
    ]

    // Mapping from compatibility jamo to standard jamo
    private let compatToL: [Character: Character] = [
        "ㄱ":"ᄀ","ㄲ":"ᄁ","ㄴ":"ᄂ","ㄷ":"ᄃ","ㄸ":"ᄄ","ㄹ":"ᄅ","ㅁ":"ᄆ","ㅂ":"ᄇ","ㅃ":"ᄈ",
        "ㅅ":"ᄉ","ㅆ":"ᄊ","ㅇ":"ᄋ","ㅈ":"ᄌ","ㅉ":"ᄍ","ㅊ":"ᄎ","ㅋ":"ᄏ","ㅌ":"ᄐ","ㅍ":"ᄑ","ㅎ":"ᄒ"
    ]
    private let compatToV: [Character: Character] = [
        "ㅏ":"ᅡ","ㅐ":"ᅢ","ㅑ":"ᅣ","ㅒ":"ᅤ","ㅓ":"ᅥ","ㅔ":"ᅦ","ㅕ":"ᅧ","ㅖ":"ᅨ",
        "ㅗ":"ᅩ","ㅛ":"ᅭ","ㅜ":"ᅮ","ㅠ":"ᅲ","ㅡ":"ᅳ","ㅣ":"ᅵ"
    ]
    private let compatToT: [Character: Character] = [
        "ㄱ":"ᆨ","ㄲ":"ᆩ","ㄴ":"ᆫ","ㄷ":"ᆮ","ㄹ":"ᆯ","ㅁ":"ᆷ","ㅂ":"ᆸ","ㅅ":"ᆺ","ㅆ":"ᆻ","ㅇ":"ᆼ",
        "ㅈ":"ᆽ","ㅊ":"ᆾ","ㅋ":"ᆿ","ㅌ":"ᇀ","ㅍ":"ᇁ","ㅎ":"ᇂ"
    ]

    // Final clusters (compat pair -> standard T jamo)
    private let compatPairToT: [Bigram: Character] = [
        Bigram("ㄱ","ㅅ"): "ᆪ",
        Bigram("ㄴ","ㅈ"): "ᆬ",
        Bigram("ㄴ","ㅎ"): "ᆭ",
        Bigram("ㄹ","ㄱ"): "ᆰ",
        Bigram("ㄹ","ㅁ"): "ᆱ",
        Bigram("ㄹ","ㅂ"): "ᆲ",
        Bigram("ㄹ","ㅅ"): "ᆳ",
        Bigram("ㄹ","ㅌ"): "ᆴ",
        Bigram("ㄹ","ㅍ"): "ᆵ",
        Bigram("ㄹ","ㅎ"): "ᆶ",
        Bigram("ㅂ","ㅅ"): "ᆹ"
    ]

    // Composite vowels (compat pair -> standard V jamo)
    private let compatVowelPairToV: [Bigram: Character] = [
        Bigram("ㅗ","ㅏ"): "ᅪ",
        Bigram("ㅗ","ㅐ"): "ᅫ",
        Bigram("ㅗ","ㅣ"): "ᅬ",
        Bigram("ㅜ","ㅓ"): "ᅯ",
        Bigram("ㅜ","ㅔ"): "ᅰ",
        Bigram("ㅜ","ㅣ"): "ᅱ",
        Bigram("ㅡ","ㅣ"): "ᅴ"
    ]

    // Reverse (standard -> compatibility), used for fallback and decompose
    private let standardLToCompat: [Character: Character] = [
        "ᄀ":"ㄱ","ᄁ":"ㄲ","ᄂ":"ㄴ","ᄃ":"ㄷ","ᄄ":"ㄸ","ᄅ":"ㄹ","ᄆ":"ㅁ","ᄇ":"ㅂ","ᄈ":"ㅃ",
        "ᄉ":"ㅅ","ᄊ":"ㅆ","ᄋ":"ㅇ","ᄌ":"ㅈ","ᄍ":"ㅉ","ᄎ":"ㅊ","ᄏ":"ㅋ","ᄐ":"ㅌ","ᄑ":"ㅍ","ᄒ":"ㅎ"
    ]
    private let standardVToCompat: [Character: Character] = [
        "ᅡ":"ㅏ","ᅢ":"ㅐ","ᅣ":"ㅑ","ᅤ":"ㅒ","ᅥ":"ㅓ","ᅦ":"ㅔ","ᅧ":"ㅕ","ᅨ":"ㅖ",
        "ᅩ":"ㅗ","ᅪ":"ㅘ","ᅫ":"ㅙ","ᅬ":"ㅚ","ᅭ":"ㅛ",
        "ᅮ":"ㅜ","ᅯ":"ㅝ","ᅰ":"ㅞ","ᅱ":"ㅟ","ᅲ":"ㅠ",
        "ᅳ":"ㅡ","ᅴ":"ㅢ","ᅵ":"ㅣ"
    ]
    private let standardTToCompat: [Character: Character] = [
        "ᆨ":"ㄱ","ᆩ":"ㄲ","ᆪ":"ㄳ","ᆫ":"ㄴ","ᆬ":"ㄵ","ᆭ":"ㄶ","ᆮ":"ㄷ","ᆯ":"ㄹ","ᆰ":"ㄺ",
        "ᆱ":"ㄻ","ᆲ":"ㄼ","ᆳ":"ㄽ","ᆴ":"ㄾ","ᆵ":"ㄿ","ᆶ":"ㅀ","ᆷ":"ㅁ","ᆸ":"ㅂ","ᆹ":"ㅄ",
        "ᆺ":"ㅅ","ᆻ":"ㅆ","ᆼ":"ㅇ","ᆽ":"ㅈ","ᆾ":"ㅊ","ᆿ":"ㅋ","ᇀ":"ㅌ","ᇁ":"ㅍ","ᇂ":"ㅎ"
    ]
}
