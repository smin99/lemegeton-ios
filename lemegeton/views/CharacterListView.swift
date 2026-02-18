//
//  CharacterListView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/19/25.
//

import Foundation
import SwiftUI

extension View {
    func greyOutIf(_ condition: Bool) -> some View {
        if (condition) {
            self.foregroundStyle(.gray) as! Self
        } else {
            self
        }
    }
}

struct CharacterListView: View {
    let titleText: String
    let onComplete: (Set<Character>) -> Void
    let allCharacters: [Character]
    let includeScenario: Bool
    @State var selectedCharacters: Set<Character>
    
    // Define the grid columns
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                
                Text(titleText)
                    .font(.headline)
                    .foregroundStyle(.themeOnSurface)
                
                Spacer()
                
                Button {
                    onComplete(selectedCharacters)
                } label: {
                    Text("Done")
                        .padding()
                }
            }
            
            if (includeScenario) {
                ScenarioCarousel { characters in
                    selectedCharacters = characters
                }
            }
            
            LazyVGrid(columns: columns) {
                ForEach(allCharacters, id: \.id) { character in
                    let isInGame = selectedCharacters.contains(character)
                    VStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(character.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                            }
                            .overlay(content: {
                                if (!isInGame) {
                                    Circle()
                                        .fill(.gray.opacity(0.88))
                                }
                            })
                        
                        Text(character.name)
                            .font(.caption)
                            .foregroundStyle(isInGame ? .themeOnSurface : .gray)
                    }
                    .onTapGesture {
                        if (isInGame) {
                            selectedCharacters.remove(character)
                        } else {
                            selectedCharacters.insert(character)
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
        .background(Color(.themeSurface))
    }
}
