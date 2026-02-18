//
//  CharacterManager.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Observation

@Observable
class CharacterManager {
    var characters: [Character] = []
    
    
    init(characters: [Character]) {
        self.characters = characters
    }
    
}
