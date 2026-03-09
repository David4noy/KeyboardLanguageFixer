//
//  CrossPlatformPasteboard.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

/// Simple cross-platform pasteboard wrapper.
enum CrossPlatformPasteboard {
    static func copy(_ text: String) {
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #elseif canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }

    static func paste() -> String? {
        #if canImport(AppKit)
        return NSPasteboard.general.string(forType: .string)
        #elseif canImport(UIKit)
        return UIPasteboard.general.string
        #else
        return nil
        #endif
    }
}
