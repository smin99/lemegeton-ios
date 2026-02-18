//
//  NoteTakeView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/20/25.
//

import SwiftUI

struct NoteTakeView: View {
    let onComplete: (String) -> Void
    @State var note: String = ""
    @FocusState private var keyboardFocused: Bool
    
    var body : some View {
        VStack {
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
                    Text("완료")
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
