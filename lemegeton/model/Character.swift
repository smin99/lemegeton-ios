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

    var supportedAbility: SupportedAbility? {
        switch id {
        case "trouble_brewing_001":
            return .washerwomanInfo
        case "trouble_brewing_002":
            return .librarianInfo
        case "trouble_brewing_003":
            return .investigatorInfo
        case "trouble_brewing_004":
            return .chefInfo
        case "trouble_brewing_005":
            return .empathInfo
        case "trouble_brewing_006":
            return .fortuneTellerCheck
        case "trouble_brewing_007":
            return .undertakerInfo
        case "trouble_brewing_008":
            return .monkProtect
        case "trouble_brewing_009":
            return .ravenkeeperCheck
        case "trouble_brewing_011":
            return .slayerShot
        case "trouble_brewing_014":
            return .butlerMaster
        case "trouble_brewing_018":
            return .poisonerPoison
        case "trouble_brewing_022":
            return .impKill
        case "bad_moon_001":
            return .grandmotherInfo
        case "bad_moon_002":
            return .sailorChoose
        case "bad_moon_003":
            return .chambermaidCheck
        case "bad_moon_004":
            return .exorcistBlock
        case "bad_moon_005":
            return .innkeeperProtect
        case "bad_moon_006":
            return .gamblerGuess
        case "bad_moon_007":
            return .gossipStatement
        case "bad_moon_008":
            return .courtierChooseCharacter
        case "bad_moon_009":
            return .professorResurrect
        case "bad_moon_015":
            return .lunaticAttack
        case "bad_moon_017":
            return .moonchildCurse
        case "bad_moon_018":
            return .godfatherKill
        case "bad_moon_019":
            return .devilsAdvocateProtect
        case "bad_moon_020":
            return .assassinKill
        case "bad_moon_022":
            return .zombuulKill
        case "bad_moon_023":
            return .pukkaPoison
        case "bad_moon_024":
            return .shabalothKill
        case "bad_moon_025":
            return .poAttack
        case "sects_violets_002":
            return .dreamerInfo
        case "sects_violets_003":
            return .snakeCharmerCheck
        case "sects_violets_004":
            return .mathematicianInfo
        case "sects_violets_005":
            return .flowergirlInfo
        case "sects_violets_006":
            return .townCrierInfo
        case "sects_violets_007":
            return .oracleInfo
        case "sects_violets_008":
            return .savantInfo
        case "sects_violets_009":
            return .seamstressCheck
        case "sects_violets_010":
            return .philosopherChoose
        case "sects_violets_011":
            return .artistQuestion
        case "sects_violets_012":
            return .jugglerInfo
        case "sects_violets_019":
            return .witchCurse
        case "sects_violets_020":
            return .cerenovusMadness
        case "sects_violets_021":
            return .pitHagTransform
        case "sects_violets_022":
            return .fangGuAttack
        case "sects_violets_023":
            return .vigormortisAttack
        case "sects_violets_024":
            return .noDashiiAttack
        case "sects_violets_025":
            return .vortoxAttack
        default:
            return nil
        }
    }
}
