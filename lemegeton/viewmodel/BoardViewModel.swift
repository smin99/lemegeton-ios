//
//  BoardViewModel.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Foundation
import Combine
import CoreGraphics

class BoardViewModel: ObservableObject {
    
    private let repo = GameRepo.shared
    
    @Published var currentGame: Game
    @Published var pastGames: [Game]
    @Published var allCharacters: [Character]
    
    private let characterSaveFileName = "characterState.json"
    private let saveFileName = "gameState.json"
    // The file URL for the document directory
    private var saveURL: URL {
        // Use the documents directory, which is appropriate for user-generated or critical data.
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot access documents directory.")
        }
        return documentDirectory
    }
    
    init() {
        // Sync from GameRepo if available
        repo.loadCurrentGame()
        
        // Initialize repo-backed game if none exists
        if repo.currentGame == nil {
            repo.startNewGame()
            currentGame = repo.currentGame!
        } else {
            currentGame = repo.currentGame!
        }
        pastGames = repo.pastGames
        allCharacters = CharacterService.availableCharacters
    }
    
    
    // MARK: - Dropdown Menu Actions
    
    /** Set up character  */
    func setUpCharacters(characters: [Character]) {
        currentGame.inGameCharacters = characters
        saveState()
    }
    
    func updateSetup() {
        currentGame.gameState = currentGame.gameState == .set_up ? .in_game : .set_up
        repo.saveCurrentGame(currentGame: currentGame)
    }
    
    func canStartGame() -> Bool {
        let seatCount = currentGame.seats.count
        return seatCount > 0 && currentGame.inGameCharacters.count >= seatCount
    }
    
    
    // Reset the entire board
    func resetBoard() {
        repo.startNewGame()
        currentGame = repo.currentGame!
    }
    
    func canEndGame() -> Bool {
        return currentGame.isAllCharacterConfirmed() &&
        (currentGame.didAllDemonDie() || currentGame.numAliveCharacters() < Game.FINAL_ALIVE_CHARACTER)
    }
    
    func endGame(resetGame: Bool) {
        currentGame.gameState = .game_over
        repo.saveCurrentGame(currentGame: currentGame)
        repo.endCurrentGame()
        refreshPastGames()
        
        if (resetGame) {
            repo.startNewGame()
            currentGame = repo.currentGame!
        } else {
            currentGame.clearGameState()
        }
    }
    
    // MARK: - Set Up Board Actions
    
    func addSeat(at point: CGPoint) {
        currentGame.seats.append(Seat(player: Player(name: "", inGameCharacters: currentGame.inGameCharacters), x: point.x, y: point.y))
        saveState()
    }
    
    func removeSeat(seat: Seat) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            currentGame.seats.remove(at: idx)
            saveState()
        }
    }
    
    func deathUpon(seat: Seat) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            currentGame.seats[idx].player.isDead = !currentGame.seats[idx].player.isDead
            saveState()
        }
    }
    
    func editSeatName(seat: Seat, newName: String) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            currentGame.seats[idx].player.editName(newName: newName)
            saveState()
        }
    }
    
    func updatePlayerNote(seat: Seat, note: String) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            currentGame.seats[idx].player.updateNote(newNote: note)
            saveState()
        }
    }
    
    // MARK: - Private Repo Caller
    
    func saveState() {
        repo.saveCurrentGame(currentGame: currentGame)
    }
    
    func refreshPastGames() {
        repo.loadPastGames()
        pastGames = repo.pastGames
    }
    
    func removePastGames(atOffsets offsets: IndexSet) {
        repo.removePastGames(atOffsets: offsets)
        pastGames = repo.pastGames
    }
}
