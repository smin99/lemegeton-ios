//
//  SeatMenuView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/21/25.
//

import SwiftUI

struct SeatView : View {
    var boardSide: BoardSide
    var seat: Seat
    @StateObject var boardVM: BoardViewModel
    
    @State private var showNoteEditor = false
    @State private var showCharacterList = false
    @State private var showEditNameSheet = false
    
    private let SEAT_SIZE: CGFloat = 60
    
    var body : some View {
        let isDead = seat.player.isDead
        let seatIndex = boardVM.getSeatIndex(boardSide: boardSide, seat: seat)
        VStack {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: SEAT_SIZE, height: SEAT_SIZE)
                    .overlay(content: {
                        if (seat.player.character != nil) {
                            Image(seat.player.character!.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: SEAT_SIZE, height: SEAT_SIZE)
                                .clipShape(Circle())
                        }
                        
                        if (isDead) {
                            ZStack {
                                Circle()
                                    .fill(.red.opacity(0.68))
                                
                                Text("R.I.P.")
                                    .foregroundStyle(.white)
                            }
                        }
                        Menu("      ") {
                            Button("이름 변경") {
                                showEditNameSheet = true
                            } 
                            Button("노트 수정") {
                                showNoteEditor = true
                            }
                            Button(isDead ? "부활!" : "죽다") {
                                if (seatIndex != nil) {
                                    boardVM.sides[boardSide]!.seats[seatIndex!].player.isDead = !isDead
                                }
                            }
                            Button("추정 캐릭터") {
                                showCharacterList = true
                            }
                            Button("캐릭터 확정") {
                                if (seatIndex != nil) {
                                    boardVM.sides[boardSide]!.seats[seatIndex!].player.isCharacterConfirmed = true
                                }
                            }
                            
                            if (seatIndex != nil) {
                                let isDrunk = boardVM.sides[boardSide]!.seats[seatIndex!].player.isDrunk
                                Button(isDrunk ? "안 취한듯?" : "취한듯?") {
                                    boardVM.sides[boardSide]!.seats[seatIndex!].player.isDrunk = !isDrunk
                                }
                            }
                            Button("플레이어 삭제") {
                                if (seatIndex != nil) {
                                    boardVM.removeSeat(boardSide: boardSide, index: seatIndex!)
                                }
                            }
                        }
                        .frame(width: SEAT_SIZE, height: SEAT_SIZE)
                        .menuStyle(.button)
                        .buttonStyle(.borderless)
                    })
                    .sheet(isPresented: $showEditNameSheet) {
                        EditNameSheetView(onComplete: { newName in
                            if (seatIndex != nil) {
                                boardVM.editSeatName(boardSide: boardSide, seatIndex: seatIndex!, newName: newName)
                            }
                            showEditNameSheet = false
                        }, playerName: seat.player.name)
                    }
                    .sheet(isPresented: $showNoteEditor) {
                        if (seatIndex != nil) {
                            let currentNote = boardVM.sides[boardSide]!.seats[seatIndex!].player.note
                            NoteTakeView(onComplete: { note in
                                boardVM.updatePlayerNote(boardSide: boardSide, seatIndex: seatIndex!, note: note)
                                showNoteEditor = false
                            }, note: currentNote)
                        }
                    }
                    .sheet(isPresented: $showCharacterList) {
                        if (seatIndex != nil) {
                            CharacterListView(titleText: "\(seat.player.name)의 역할은 누구일까", onComplete: { characters in
                                let array = Array(characters)
                                if (array.count == 1) {
                                    boardVM.sides[boardSide]!.seats[seatIndex!].player.character = array[0]
                                }
                                boardVM.sides[boardSide]!.seats[seatIndex!].player.possibleCharacters = array
                                showCharacterList = false
                            }, allCharacters: boardVM.inGameCharacters.sorted(by: {
                                if ($0.type < $1.type) {
                                    true
                                } else {
                                    $0.id < $1.id
                                }}), includeScenario: false, selectedCharacters: Set(seat.player.possibleCharacters))
                        }
                    }
            }
            
            HStack {
                if (seat.player.isCharacterConfirmed) {
                    // show check mark
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(
                            seat.player.character?.type == CharacterType.townsfolk || seat.player.character?.type == CharacterType.outsider ? .blue : .red)
                }
                
                if boardVM.isSettingUp {
                    if let binding = nameBindingForSeat() {
                        TextField("Name", text: binding)
                            .foregroundStyle(.themeOnSurface)
                            .frame(width: SEAT_SIZE)
                            .textFieldStyle(.roundedBorder)
                            .keyboardShortcut(.defaultAction)
                    } else {
                        // Fallback non-editable when binding cannot be created
                        Text(seat.player.name)
                            .foregroundColor(.white)
                            .frame(width: SEAT_SIZE)
                    }
                } else {
                    Text(seat.player.name)
                        .foregroundColor(.white)
                        .frame(width: SEAT_SIZE)
                }
            }
        }
    }
    
    // Helper to create a safe binding to the player's name when editable
    private func nameBindingForSeat() -> Binding<String>? {
        let seatIndex = boardVM.getSeatIndex(boardSide: boardSide, seat: seat)
        if let idx = seatIndex, let _ = boardVM.sides[boardSide] {
            return Binding<String>(
                get: { boardVM.sides[boardSide]!.seats[idx].player.name },
                set: { newValue in
                    boardVM.editSeatName(boardSide: boardSide, seatIndex: idx, newName: newValue)
                }
            )
        } else {
            return nil
        }
    }
}
