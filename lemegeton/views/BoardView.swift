//
//  ContentView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/4/25.
//

import SwiftUI
import Combine

struct BoardView: View {
    @StateObject var boardVM: BoardViewModel = BoardViewModel()
    @State private var showCharacterSheet: Bool = false
    
    // ⚙️ Geometry to position the seat dynamically
    func seatOffset(boardSide: BoardSide) -> CGSize {
        switch boardSide {
        case .top:
            return CGSize(width: 0, height: -250) // Top center
        case .bottom:
            return CGSize(width: 0, height: 250) // Bottom center
        case .left:
            return CGSize(width: -150, height: 0) // Left center
        case .right:
            return CGSize(width: 150, height: 0) // Right center
        }
    }
    
    var body: some View {
        // 1. ZStack layers the content: Board (background), Seats, and Buttons
        VStack(alignment: .center) {
            let titleStr =
            if (boardVM.isSettingUp) {
                "Finish Board Set Up"
            } else {
                "Win the Game"
            }
            ZStack {
                HStack {
                    Button {
                        self.showCharacterSheet = true
                    } label: {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.themePrimary)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            boardVM.saveState()
                        } label: {
                            Text("저장하기")
                        }
                        
                        Button {
                            boardVM.resetState()
                        } label: {
                            Text("저장 지우기")
                        }
                        
                        Button {
                            boardVM.updateSetup()
                        } label: {
                            Text(boardVM.isSettingUp ? "게임 시작" : "게임판 변경"
                            )
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .frame(width: 24, height: 24)
                            .padding()
                    }
                    
                }
                
                Text(titleStr)
            }
            
            ZStack {
                ForEach(BoardSide.allCases, id: \.self) { boardSide in
                    SideView(boardSide: boardSide, boardVM: boardVM)
                        .offset(seatOffset(boardSide: boardSide))
                        .frame(maxWidth: 300, maxHeight: 300)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.themeSurface))
        }
        .sheet(isPresented: $showCharacterSheet) {
            CharacterListView(titleText: "Add characters in game", onComplete: { characters in
                boardVM.setUpCharacters(characters: Array(characters).sorted(by: { $0.type.rawValue < $1.type.rawValue }))
                showCharacterSheet = false
            }, allCharacters: boardVM.allCharacters, includeScenario: true, selectedCharacters: Set(boardVM.inGameCharacters))
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    BoardView()
}
