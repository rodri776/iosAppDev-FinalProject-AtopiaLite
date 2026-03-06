//
//  Atopiasearchbar.swift
//  Atopia
//
//  Created by Juniper Rodriguez on 2/11/26.
//
import SwiftUI

struct AtopiaSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onCommit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.caption)
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .font(.caption)
                .focused($isFocused)
                .onSubmit {
                    onCommit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isFocused ? Color.accentColor.opacity(0.5) : Color.primary.opacity(0.1), lineWidth: 1)
        )
        .fontDesign(.serif)
    }
}

#Preview {
    VStack(spacing: 20) {
        AtopiaSearchBar(text: .constant(""), placeholder: "Search users...")
        AtopiaSearchBar(text: .constant("rock climbing"), placeholder: "Search users...")
    }
    .padding()
}
