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
    
    enum ActiveAlert: Identifiable {
        case resetBoard, cannotStartGame, cannotEndGame, completeGame, resetAfterCompleteGame
        var id: Int { hashValue }
        
        var title: String {
            switch self {
            case .resetBoard:
                "Reset the Grimoire?"
            case .cannotStartGame:
                "Cannot begin the chronicle"
            case .cannotEndGame,
                    .completeGame:
                "Finish the game?"
            case .resetAfterCompleteGame:
                "Restart with same board?"
            }
        }
        
        var message: String {
            switch self {
            case .resetBoard:
                "This will clear all player seats and roles. This action cannot be undone."
            case .cannotStartGame:
                "Select at least as many characters as there are seats before starting the game."
            case .cannotEndGame:
                "The game has not ended. Please record all player's characters and update their death state."
            case .completeGame:
                "This will end the game. Ended game cannot be started again."
            case .resetAfterCompleteGame:
                "Restart will keep the current board setup including player name and seats."
            }
        }
    }
    @State private var activeAlert: ActiveAlert?
    
    @State private var showMenu = false
    @State private var showCharacterSheet: Bool = false
    @State private var showPhaseNoteSheet: Bool = false
    @State private var showChronicle = false
    @State private var isChronicleSummaryExpanded = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        SeatsCanvas(boardVM: boardVM)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }

                    if boardVM.currentGame.gameState != .set_up {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isChronicleSummaryExpanded.toggle()
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(boardVM.currentGame.currentPhaseTitle)
                                        .grimoireBoldStyle(size: 20)
                                        .foregroundStyle(.themeOnSurface)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isChronicleSummaryExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundStyle(.themePrimary)
                                }
                                
                                if isChronicleSummaryExpanded {
                                    Text(boardVM.currentGame.currentPhaseNote().isEmpty ? "No chronicle note yet." : boardVM.currentGame.currentPhaseNote())
                                        .grimoireStyle(size: 14, italic: false)
                                        .foregroundStyle(.themePrimary.opacity(0.9))
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.themeSurface.opacity(0.94))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    }
                    
                    // The Custom "Menu" (Dropdown)
                    if showMenu {
                        VStack(alignment: .leading, spacing: 12) {
                            if (boardVM.currentGame.gameState == .set_up) {
                                Button() {
                                    self.showCharacterSheet = true
                                } label: {
                                    Label("Scenario & Roles", systemImage: "theatermasks")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))
                                
                                NavigationLink {
                                    PastGamesView(boardVM: boardVM)
                                } label: {
                                    Label("Previous Games", systemImage: "clock.arrow.circlepath")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))
                                
                                Button(role: .confirm) {
                                    if boardVM.canStartGame() {
                                        boardVM.updateSetup()
                                    } else {
                                        activeAlert = .cannotStartGame
                                    }
                                } label: {
                                    Label("Begin Chronicle", systemImage: "play.circle.fill")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))
                                
                                // Reset the board
                                Button(role: .destructive) {
                                    activeAlert = .resetBoard
                                } label: {
                                    Label("Clear Grimoire", systemImage: "arrow.uturn.backward.circle")
                                }
                                .buttonStyle(GrimoireButtonStyle(isDestructive: true))
                                
                            } else {
                                Button {
                                    showPhaseNoteSheet = true
                                } label: {
                                    Label(boardVM.currentGame.currentPhaseTitle, systemImage: "book.closed")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))
                                
                                // Finish the game
                                Button {
                                    activeAlert = boardVM.canEndGame() ? .completeGame : .cannotEndGame
                                } label: {
                                    Label("Final Verdict", systemImage: "flag.checkered")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))
                                
                                NavigationLink {
                                    PastGamesView(boardVM: boardVM)
                                } label: {
                                    Label("Previous Games", systemImage: "clock.arrow.circlepath")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))
                                
                                // Move back to set up state
                                Button {
                                    boardVM.updateSetup()
                                } label: {
                                    Label("Arrange Seating", systemImage: "slider.horizontal.3")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                            }
                        }
                        .padding()
                        .background(.themeSurface)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1)))
                        .frame(width: 250)
                        .transition(.scale(scale: 0.9, anchor: .topLeading).combined(with: .opacity))
                        .zIndex(1) // Ensure it stays on top
                    }
                }
            }
            .onTapGesture {
                if showMenu {
                    withAnimation {
                        showMenu.toggle()
                    }
                }
            }
            .sheet(isPresented: $showCharacterSheet) {
                CharacterListView(titleText: "Add characters in game", onComplete: { characters in
                    boardVM.setUpCharacters(characters: Array(characters).sorted(by: { $0.type.rawValue < $1.type.rawValue }))
                    showCharacterSheet = false
                }, allCharacters: boardVM.allCharacters, includeScenario: true, maxSelectionCount: nil, selectedCharacters: Set(boardVM.currentGame.inGameCharacters))
            }
            .sheet(isPresented: $showPhaseNoteSheet) {
                NoteTakeView(
                    title: boardVM.currentGame.currentPhaseTitle,
                    onComplete: { note in
                        boardVM.updateCurrentPhaseNote(note)
                        showPhaseNoteSheet = false
                    },
                    buttonTitle: "Save Note",
                    placeholder: "Write what happened during this phase",
                    note: boardVM.currentGame.currentPhaseNote()
                )
            }
            .navigationDestination(isPresented: $showChronicle) {
                ChronicleView(boardVM: boardVM)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(boardVM.currentGame.gameState == .set_up ? "Set up the Grimoire" : "\(boardVM.currentGame.numAliveCharacters()) Alive")
                        .grimoireBoldStyle(size: 18)
                        .tracking(2)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.spring()) {
                            showMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.themePrimary)
                    }
                }
                .sharedBackgroundVisibility(.hidden)
                
                ToolbarItem(placement: .topBarTrailing) {
                    if boardVM.currentGame.gameState != .set_up {
                        Button {
                            showChronicle = true
                        } label: {
                            Image(systemName: "book.pages")
                                .foregroundColor(.themePrimary)
                        }
                    }
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .topBarTrailing) {
                    if boardVM.currentGame.gameState != .set_up {
                        Button {
                            boardVM.advancePhase()
                        } label: {
                            Image(systemName: "moonphase.waning.crescent")
                                .foregroundColor(.themePrimary)
                        }
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            }
            
            // MARK: Alerts
            .alert(item: $activeAlert) { alert in
                var primaryButton: Alert.Button?
                var secondaryButton: Alert.Button?
                switch alert {
                case .resetBoard:
                    primaryButton = .destructive(Text("Reset")) {
                        boardVM.resetBoard()
                    }
                    secondaryButton = .cancel(Text("Cancel"))
                case .cannotEndGame:
                    return Alert(
                        title: Text(alert.title),
                        message: Text(alert.message),
                        dismissButton: .default(Text("OK"))
                    )
                case .cannotStartGame:
                    return Alert(
                        title: Text(alert.title),
                        message: Text(alert.message),
                        dismissButton: .default(Text("OK"))
                    )
                case .completeGame:
                    primaryButton = .default(Text("Complete")) {
                        activeAlert = .resetAfterCompleteGame
                    }
                    secondaryButton = .cancel(Text("Cancel"))
                case .resetAfterCompleteGame:
                    primaryButton = .default(Text("Restart")) {
                        boardVM.endGame(resetGame: false)
                    }
                    secondaryButton = .destructive(Text("Clear Grimorie")) {
                        boardVM.endGame(resetGame: true)
                    }
                }
                
                return Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    primaryButton: primaryButton!,
                    secondaryButton: secondaryButton!)
            }
        }
    }
}

#Preview {
    BoardView()
}
