//
//  Character.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Foundation

enum AbilityType {
    case passive        // 비정보 능력; 패시브
    case active         // 비정보 능력;
    case singleInfo     // 정보 능력; 일회성
    case multiInfo      // 정보 능력; 매일 밤
}

enum CharacterType: String, Codable, CaseIterable, Comparable {
    case townsfolk
    case outsider
    case minion
    case demon
    
    // Define the custom, logical sort order here
    static let customOrder: [CharacterType] = [.townsfolk, .outsider, .minion, .demon]
    
    // 2. Create a static map for quick lookup: [Tier: Index]
    static let sortIndexMap: [CharacterType : Int] = {
        var map: [CharacterType : Int] = [:]
        for (index, tier) in customOrder.enumerated() {
            map[tier] = index
        }
        return map
    }()
    
    static func < (leftType: CharacterType, rightType: CharacterType) -> Bool {
        return CharacterType.sortIndexMap[leftType]! < CharacterType.sortIndexMap[rightType]!
    }
}

struct Character: Codable, Identifiable, Hashable {
    var id: String

    var name: String
    var imageName: String
    var description: String
    var type: CharacterType
    
    init(id: String, name: String, imageName: String, description: String, type: CharacterType) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.description = description
        self.type = type
    }
}
