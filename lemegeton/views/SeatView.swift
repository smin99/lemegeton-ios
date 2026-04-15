//
//  SeatMenuView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/21/25.
//

import SwiftUI

private let SEAT_SIZE: CGFloat = 60

struct SeatView: View {
    @Binding var seat: Seat
    @StateObject var boardVM: BoardViewModel
    
    @State private var showNoteEditor = false
    @State private var showCharacterList = false
    @State private var showEditNameSheet = false
    
    var body: some View {
        if boardVM.currentGame.gameState == .set_up {
            SetupSeatView(seat: $seat)
        } else {
            VStack {
                ZStack {
                    Menu {
                        Button(action: {
                            showEditNameSheet = true
                        }) {
                            Label("Edit Name", systemImage: "pencil.line")
                        }
                        Button(action: {
                            showNoteEditor = true
                        }) {
                            Label("Write Note", systemImage: "note.text")
                        }
                        Button(action: {
                            boardVM.deathUpon(seat: seat)
                        }) {
                            Label(
                                seat.player.isDead ? "Revive!" : "Dead",
                                systemImage: seat.player.isDead
                                ? "sparkles"
                                : "person.slash.fill"
                            )
                        }
                        Button(action: {
                            showCharacterList = true
                        }) {
                            Label(
                                "Claimed Role",
                                systemImage: "person.fill.questionmark"
                            )
                        }
                        Button(action: {
                            boardVM.removeSeat(seat: seat)
                        }) {
                            Label("Remove Seat", systemImage: "trash.fill")
                        }
                    } label: {
                        CircleImageView(
                            character: $seat.player.character,
                            isDead: $seat.player.isDead
                        )
                    }
                    .frame(width: SEAT_SIZE, height: SEAT_SIZE)
                    .menuStyle(.button)
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $showEditNameSheet) {
                        EditNameSheetView(
                            onComplete: { newName in
                                boardVM.editSeatName(
                                    seat: seat,
                                    newName: newName
                                )
                                showEditNameSheet = false
                            },
                            playerName: seat.player.name
                        )
                    }
                    .sheet(isPresented: $showNoteEditor) {
                        NoteTakeView(
                            title: "\(seat.player.name)'s Note",
                            onComplete: { note in
                                boardVM.updatePlayerNote(seat: seat, note: note)
                                showNoteEditor = false
                            },
                            buttonTitle: "Done",
                            note: seat.player.note
                        )
                    }
                    .sheet(isPresented: $showCharacterList) {
                        CharacterListView(
                            titleText: "Guess \(seat.player.name)'s role",
                            onComplete: { characters in
                                boardVM.updateClaimedRole(
                                    seat: seat,
                                    character: Array(characters).first
                                )
                                showCharacterList = false
                            },
                            allCharacters: boardVM.currentGame.inGameCharacters
                                .sorted(by: {
                                    if $0.type < $1.type {
                                        true
                                    } else {
                                        $0.id < $1.id
                                    }
                                }),
                            includeScenario: false,
                            maxSelectionCount: 1,
                            selectedCharacters: Set(
                                seat.player.character.map { [$0] } ?? []
                            )
                        )
                    }
                }
                
                HStack {
                    if seat.player.isCharacterConfirmed {
                        // show check mark
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(
                                seat.player.character?.type
                                == CharacterType.townsfolk
                                || seat.player.character?.type
                                == CharacterType.outsider
                                ? .blue : .red
                            )
                    }
                    
                    Text(seat.player.name)
                        .frame(width: SEAT_SIZE)
                        .foregroundStyle(seat.player.isDead ? .gray : .themeOnSurface)
                        .strikethrough(seat.player.isDead, color: .themeTertiary)
                }
            }
            .position(x: seat.x, y: seat.y)
        }
    }
}

private struct SetupSeatView: View {
    @Binding var seat: Seat
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack {
            CircleImageView(character: $seat.player.character, isDead: $seat.player.isDead)
            
            TextField(
                "",
                text: $seat.player.name,
                prompt: Text("Name").foregroundStyle(.gray.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.themePrimary, lineWidth: 1)
            )
            .foregroundStyle(.themeOnSurface)
            .background(Color.themeSurface)
            .frame(width: SEAT_SIZE)
            .keyboardShortcut(.defaultAction)
            .multilineTextAlignment(.center)
        }
        .position(x: seat.x + dragOffset.width, y: seat.y + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    seat.x += value.translation.width
                    seat.y += value.translation.height
                    dragOffset = .zero
                }
        )
    }
}

private struct CircleImageView: View {
    @Binding var character: Character?
    @Binding var isDead: Bool
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: SEAT_SIZE, height: SEAT_SIZE)
            .overlay(content: {
                if character != nil {
                    Image(character!.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: SEAT_SIZE, height: SEAT_SIZE)
                        .clipShape(Circle())
                }
                
                if isDead {
                    ZStack {
                        Circle()
                            .fill(.red.opacity(0.68))
                        
                        Text("R.I.P.")
                            .foregroundStyle(.white)
                    }
                }
            })
    }
}
