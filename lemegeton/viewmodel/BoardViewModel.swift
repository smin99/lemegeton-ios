//
//  BoardViewModel.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Foundation
import Combine

class BoardViewModel: ObservableObject {
    
    @Published var allCharacters: [Character]
    @Published var scenarios: [Scenario]
    @Published var inGameCharacters: [Character]
    // 🎲 State to hold the list of seats currently on the board
    @Published var sides: [BoardSide : Side] = [
        .top : Side(),
        .left : Side(),
        .right : Side(),
        .bottom : Side(),
    ]
    @Published var isSettingUp: Bool = true
    
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
        allCharacters = CharacterService.availableCharacters
        scenarios = CharacterService.scenarios
        inGameCharacters = []
        
        loadState()
        loadCharacters()
    }
    
    /** Set up seats */
    func addSeatToSide(boardSide: BoardSide, seat: Seat) {
        sides[boardSide]?.addSeat(seat: seat)
    }
    
    func removeSeat(boardSide: BoardSide, index: Int) {
        sides[boardSide]?.seats.remove(at: index)
    }
    
    func getSeatIndex(boardSide: BoardSide, seat: Seat) -> Int? {
        return sides[boardSide]!.seats.firstIndex(where: { $0.id == seat.id})
    }
    
    func updateSetup() {
        isSettingUp = !isSettingUp
    }
    
    func deathUpon(boardSide: BoardSide, seatIndex: Int) {
        if (!sides.keys.contains(boardSide) || sides[boardSide]!.seats.count < seatIndex) {
            return
        }
        sides[boardSide]!.seats[seatIndex].player.isDead = !sides[boardSide]!.seats[seatIndex].player.isDead
    }
    
    func editSeatName(boardSide: BoardSide, seatIndex: Int, newName: String) {
        if (!sides.keys.contains(boardSide) || sides[boardSide]!.seats.count < seatIndex) {
            return
        }
        sides[boardSide]?.seats[seatIndex].player.editName(newName: newName)
    }
    
    /** Set up character  */
    func setUpCharacters(characters: [Character]) {
        self.inGameCharacters = characters
    }
    
    /** Update player */
    func updatePlayerNote(boardSide: BoardSide, seatIndex: Int, note: String) {
        if (!sides.keys.contains(boardSide) || sides[boardSide]!.seats.count < seatIndex) {
            return
        }
        sides[boardSide]?.seats[seatIndex].player.updateNote(newNote: note)
    }
    
    
    /// Manage Game State
    func saveState() {
        do {
            // Encode the current state object to JSON Data
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(sides)
            let stateUrl = saveURL.appendingPathComponent(saveFileName)
            try data.write(to: stateUrl, options: [.atomicWrite])
            print("Game state saved successfully to \(stateUrl.path)")
            
            let characterData = try encoder.encode(inGameCharacters)
            let characterUrl = saveURL.appendingPathComponent(characterSaveFileName)
            try characterData.write(to: characterUrl, options: [.atomicWrite])
            print("Game state saved successfully to \(characterUrl.path)")
        } catch {
            print("Failed to save game state: \(error.localizedDescription)")
        }
    }
    
    func resetState() {
        do {
            let stateUrl = saveURL.appendingPathComponent(saveFileName)
            let characterUrl = saveURL.appendingPathComponent(characterSaveFileName)
            
            try FileManager.default.removeItem(at: stateUrl)
            try FileManager.default.removeItem(at: characterUrl)
        } catch {
            print("Failed to clean up state: \(error.localizedDescription)")
        }
        
        
    }
    
    func loadState() {
        let stateUrl = saveURL.appendingPathComponent(saveFileName)
        guard FileManager.default.fileExists(atPath: stateUrl.path) else {
            print("No saved state file found. Starting new game.")
            return
        }
        
        do {
            // Read the file data
            let data = try Data(contentsOf: stateUrl)
            
            // Decode the JSON Data back into the GameState struct
            let decoder = JSONDecoder()
            
            sides = try decoder.decode([BoardSide: Side].self, from: data)
            print("Game state loaded successfully.")
        } catch {
            print("Failed to load game state: \(error.localizedDescription)")
            return
        }
    }
    
    func loadCharacters() {
        let characterUrl = saveURL.appendingPathComponent(characterSaveFileName)
        guard FileManager.default.fileExists(atPath: characterUrl.path) else {
            print("No saved state file found. Starting new game.")
            return
        }
        
        do {
            // Read the file data
            let data = try Data(contentsOf: characterUrl)
            
            // Decode the JSON Data back into the GameState struct
            let decoder = JSONDecoder()
            
            inGameCharacters = try decoder.decode([Character].self, from: data)
            print("Game state loaded successfully.")
        } catch {
            print("Failed to load game state: \(error.localizedDescription)")
            return
        }
    }
}
