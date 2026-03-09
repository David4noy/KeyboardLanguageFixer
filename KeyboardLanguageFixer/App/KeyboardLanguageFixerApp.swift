//
//  KeyboardLanguageFixerApp.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import SwiftUI

@main
struct KeyboardLanguageFixerApp: App {
    var body: some Scene {
        WindowGroup {
            KeyboardConverterView()
        }
        #if os(macOS) || os(iPadOS)
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        #endif
    }
}

struct KeyToolsApp_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardConverterView()
    }
}
