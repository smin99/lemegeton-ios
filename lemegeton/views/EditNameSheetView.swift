//
//  EditNameSheetView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/19/25.
//

import SwiftUI

struct EditNameSheetView : View {
    let onComplete: (String) -> Void
    @State var playerName: String
    @FocusState private var keyboardFocused: Bool
    
    var body : some View {
        VStack(alignment: .center) {
            ZStack {
                HStack {
                    Spacer()
                    Button {
                        onComplete(playerName)
                    } label: {
                        Text("Done")
                    }
                    .padding()
                }
                Text("Add a name")
                    .padding()
            }
            
            TextField("Name", text: $playerName)
                .focused($keyboardFocused)
                .onSubmit {
                    onComplete(playerName)
                }
                .padding()
            
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.2)])
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                keyboardFocused = true
            }
        }
    }
}
