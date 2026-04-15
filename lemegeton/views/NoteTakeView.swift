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
                .background(.clear)
            
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
        .interactiveDismissDisabled(true)
        .padding()
        .background(Color(.themeSurface))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                keyboardFocused = true
            }
        }
    }
}
