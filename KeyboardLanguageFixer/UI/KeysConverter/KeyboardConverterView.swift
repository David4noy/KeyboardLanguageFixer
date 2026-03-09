//
//  KeyboardConverterView.swift
//  KeyboardLanguageFixer
//
//  Created by David Noy on 09/03/2026.
//

import SwiftUI

struct KeyboardConverterView: View {
    @StateObject private var viewModel = KeyboardConverterModel()

    var body: some View {
        #if os(iOS)
        let minWidth: CGFloat = 0
        let minHeight: CGFloat = 0
        let copy = "Copy"
        let fieldBackground = Color(UIColor.systemBackground)
        let cornerThickness: CGFloat = 1
        #else
        let minWidth: CGFloat = 720
        let minHeight: CGFloat = 560
        let copy = "Copy to clipboard"
        let fieldBackground = Color(NSColor.textBackgroundColor)
        let cornerThickness: CGFloat = 0
        #endif

        VStack(alignment: .leading, spacing: 12) {
            Text("Keyboard Converter")
                .font(.title).bold()

            // From / To pickers as menus (list) on all platforms
            HStack(spacing: 12) {
                #if os(iOS) || os(iPadOS)
                Text("From:")
                #endif
                Picker("From:", selection: $viewModel.fromLang) {
                    ForEach(KeyboardConverterModel.Language.allCases) { lang in
                        Text(lang.label).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                #if os(iOS) || os(iPadOS)
                Text("To:")
                #endif
                Picker("To:", selection: $viewModel.toLang) {
                    ForEach(KeyboardConverterModel.Language.allCases) { lang in
                        Text(lang.label).tag(lang)
                    }
                }
                .pickerStyle(.menu)
            }

            // INPUT
            Text("Input").font(.headline)
            TextEditor(text: $viewModel.inputText)
                .padding(4)
                .font(.system(size: 14, weight: .regular))      // avoid monospaced to allow Hangul fallback
                .frame(minHeight: 140)
                .scrollContentBackground(.hidden)                // keep white look
                .background(fieldBackground)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: cornerThickness))
                .padding(.bottom, 4)

            // actions
            HStack(spacing: 10) {
                Button { viewModel.convert() } label: {
                    Label("Convert", systemImage: "arrow.right.arrow.left")
                }
                Button { viewModel.swapIO() } label: {
                    Label("Swap", systemImage: "arrow.up.arrow.down")
                }
                Button { CrossPlatformPasteboard.copy(viewModel.outputText) } label: {
                    Label(copy, systemImage: "doc.on.doc")
                }
                Button {
                    if let paste = CrossPlatformPasteboard.paste() {
                        viewModel.inputText = paste
                    }
                } label: {
                    Label("Paste", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
            }

            // OUTPUT (editable)
            Text("Output").font(.headline)
            TextEditor(text: $viewModel.outputText)
                .padding(4)
                .font(.system(size: 14, weight: .regular))
                .frame(minHeight: 140)
                .scrollContentBackground(.hidden)
                .background(fieldBackground)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: cornerThickness))
                .padding(4) // visual breathing room; TextEditor has no inner inset on macOS
        }
        .padding(16)
        .frame(minWidth: minWidth, minHeight: minHeight)
    }
}


#Preview {
    KeyboardConverterView()
}
