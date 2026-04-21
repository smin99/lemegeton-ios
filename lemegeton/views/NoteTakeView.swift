//
//  NoteTakeView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/20/25.
//

import SwiftUI

struct NoteTakeView: View {
    let title: String
    let onComplete: (String) -> Void
    let buttonTitle: String
    let placeholder: String
    @State var note: String = ""
    @FocusState private var keyboardFocused: Bool
    
    var body : some View {
        VStack {
            HStack {
                Text(title)
                    .grimoireBoldStyle(size: 20)
                    .foregroundStyle(.themeOnSurface)
                Spacer()
            }
            .padding(.horizontal)

            TextEditor(text: $note)
                .foregroundStyle(.themeOnSurface)
                .padding()
                .focused($keyboardFocused)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.themeSurface.opacity(0.96))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.themePrimary.opacity(0.28), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if note.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.themeOnSurface.opacity(0.58))
                            .padding(.horizontal, 22)
                            .padding(.top, 24)
                            .allowsHitTesting(false)
                    }
                }
            
            HStack {
                Spacer()
                Button {
                    onComplete(note)
                } label: {
                    Text(buttonTitle)
                }
                .padding()
            }
        }
        .padding()
        .background(Color(.themeSurface))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                keyboardFocused = true
            }
        }
    }
}
