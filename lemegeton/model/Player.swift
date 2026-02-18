//
//  Player.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Foundation

struct Player: Codable, Identifiable {
    
    var id = UUID()
    var name: String
    var character: Character? = nil
    var possibleCharacters: [Character] = []
    var isCharacterConfirmed: Bool
    var isDrunk: Bool   // 취하거나 중독 상태인지
    var isDead: Bool
    var note: String    // 
    
    init(name: String, inGameCharacters: [Character]) {
        self.name = name
        self.possibleCharacters = []
        self.isCharacterConfirmed = false
        self.isDrunk = false
        self.isDead = false
        self.note = ""
    }
    
    mutating func editName(newName: String) {
        name = newName
    }
    
    mutating func updateNote(newNote: String) {
        note = newNote
    }
}
