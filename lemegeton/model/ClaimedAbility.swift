//
//  ClaimedAbility.swift
//  lemegeton
//
//  Created by Codex on 10/06/25.
//

import Foundation

enum CharacterSelectionScope {
    case any
    case good
    case townsfolk
    case outsider
    case minion
    case evil

    func includes(_ character: Character) -> Bool {
        switch self {
        case .any:
            return true
        case .good:
            return character.type == .townsfolk || character.type == .outsider
        case .townsfolk:
            return character.type == .townsfolk
        case .outsider:
            return character.type == .outsider
        case .minion:
            return character.type == .minion
        case .evil:
            return character.type == .minion || character.type == .demon
        }
    }
}

enum SupportedAbilityInput {
    case text(placeholder: String)
    case players(minSelectionCount: Int, maxSelectionCount: Int, excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool)
    case playerAndCharacter(excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, characterScope: CharacterSelectionScope)
    case playersAndCharacter(playerCount: Int, excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, characterScope: CharacterSelectionScope)
    case playerAndTwoCharacters(excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, firstCharacterScope: CharacterSelectionScope, secondCharacterScope: CharacterSelectionScope)
    case multiplePlayerAndCharacter(maxSelectionCount: Int, excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, characterScope: CharacterSelectionScope)
    case character(characterScope: CharacterSelectionScope)
}

enum AbilitySelection {
    case text(String)
    case players([Seat])
    case playerAndCharacter(player: Seat, character: Character)
    case playersAndCharacter(players: [Seat], character: Character)
    case playerAndTwoCharacters(player: Seat, firstCharacter: Character, secondCharacter: Character)
    case multiplePlayerAndCharacter([(Seat, Character)])
    case character(Character)
}

enum SupportedAbility: String, Codable, Identifiable {
    case washerwomanInfo
    case librarianInfo
    case investigatorInfo
    case chefInfo
    case empathInfo
    case fortuneTellerCheck
    case undertakerInfo
    case monkProtect
    case ravenkeeperCheck
    case slayerShot
    case butlerMaster
    case poisonerPoison
    case impKill
    case grandmotherInfo
    case sailorChoose
    case chambermaidCheck
    case exorcistBlock
    case innkeeperProtect
    case gamblerGuess
    case gossipStatement
    case courtierChooseCharacter
    case professorResurrect
    case lunaticAttack
    case moonchildCurse
    case godfatherKill
    case devilsAdvocateProtect
    case assassinKill
    case zombuulKill
    case pukkaPoison
    case shabalothKill
    case poAttack
    case dreamerInfo
    case snakeCharmerCheck
    case mathematicianInfo
    case flowergirlInfo
    case townCrierInfo
    case oracleInfo
    case savantInfo
    case seamstressCheck
    case philosopherChoose
    case artistQuestion
    case jugglerInfo
    case witchCurse
    case cerenovusMadness
    case pitHagTransform
    case fangGuAttack
    case vigormortisAttack
    case noDashiiAttack
    case vortoxAttack

    var id: String { rawValue }

    var menuTitle: String {
        switch self {
        case .washerwomanInfo, .librarianInfo, .investigatorInfo:
            return "Record Pair"
        case .chefInfo, .empathInfo, .undertakerInfo, .mathematicianInfo,
             .flowergirlInfo, .townCrierInfo, .oracleInfo, .savantInfo:
            return "Record Info"
        case .fortuneTellerCheck:
            return "Checked"
        case .monkProtect, .innkeeperProtect, .devilsAdvocateProtect:
            return "Protected"
        case .ravenkeeperCheck:
            return "Checked Player"
        case .slayerShot:
            return "Shot"
        case .butlerMaster:
            return "Master"
        case .poisonerPoison, .pukkaPoison:
            return "Poisoned"
        case .impKill, .assassinKill, .zombuulKill, .shabalothKill, .fangGuAttack,
             .vigormortisAttack, .noDashiiAttack, .vortoxAttack, .godfatherKill:
            return "Attacked"
        case .grandmotherInfo:
            return "Learned Player"
        case .sailorChoose:
            return "Drank With"
        case .chambermaidCheck, .seamstressCheck:
            return "Chose Players"
        case .exorcistBlock:
            return "Exorcised"
        case .gamblerGuess:
            return "Guess"
        case .gossipStatement:
            return "Statement"
        case .courtierChooseCharacter:
            return "Made Drunk"
        case .professorResurrect:
            return "Resurrected"
        case .lunaticAttack:
            return "Targeted"
        case .moonchildCurse, .witchCurse:
            return "Cursed"
        case .poAttack:
            return "Attacked"
        case .dreamerInfo:
            return "Dreamed"
        case .snakeCharmerCheck:
            return "Charmed"
        case .philosopherChoose:
            return "Became"
        case .artistQuestion:
            return "Question"
        case .jugglerInfo:
            return "Guesses"
        case .cerenovusMadness:
            return "Mad As"
        case .pitHagTransform:
            return "Transform"
        }
    }

    var defaultSystemImage: String {
        switch input {
        case .text:
            return "note.text"
        case .players:
            return "person.2.fill"
        case .playerAndCharacter:
            return "person.text.rectangle"
        case .playersAndCharacter:
            return "person.2.crop.square.stack.fill"
        case .playerAndTwoCharacters:
            return "person.2.badge.gearshape.fill"
        case .multiplePlayerAndCharacter:
            return "list.bullet.clipboard"
        case .character:
            return "theatermasks"
        }
    }

    var input: SupportedAbilityInput {
        switch self {
        case .chefInfo, .empathInfo, .undertakerInfo, .gossipStatement,
             .mathematicianInfo, .flowergirlInfo, .townCrierInfo, .oracleInfo,
             .savantInfo, .artistQuestion:
            return .text(placeholder: "Record the claimed ability use")
        case .washerwomanInfo:
            return .playersAndCharacter(playerCount: 2, excludeSelf: true, aliveOnly: false, deadOnly: false, characterScope: .townsfolk)
        case .librarianInfo:
            return .playersAndCharacter(playerCount: 2, excludeSelf: true, aliveOnly: false, deadOnly: false, characterScope: .outsider)
        case .investigatorInfo:
            return .playersAndCharacter(playerCount: 2, excludeSelf: true, aliveOnly: false, deadOnly: false, characterScope: .minion)
        case .grandmotherInfo:
            return .playerAndCharacter(excludeSelf: false, aliveOnly: false, deadOnly: false, characterScope: .good)
        case .dreamerInfo:
            return .playerAndTwoCharacters(excludeSelf: false, aliveOnly: false, deadOnly: false, firstCharacterScope: .good, secondCharacterScope: .evil)
        case .jugglerInfo:
            return .multiplePlayerAndCharacter(maxSelectionCount: 5, excludeSelf: false, aliveOnly: false, deadOnly: false, characterScope: .any)
        case .fortuneTellerCheck, .innkeeperProtect, .chambermaidCheck, .shabalothKill,
             .seamstressCheck:
            return .players(minSelectionCount: 2, maxSelectionCount: 2, excludeSelf: self == .chambermaidCheck || self == .seamstressCheck, aliveOnly: self == .chambermaidCheck, deadOnly: false)
        case .monkProtect, .butlerMaster:
            return .players(minSelectionCount: 1, maxSelectionCount: 1, excludeSelf: true, aliveOnly: false, deadOnly: false)
        case .ravenkeeperCheck, .slayerShot, .poisonerPoison, .impKill, .sailorChoose,
             .exorcistBlock, .lunaticAttack, .moonchildCurse, .godfatherKill,
             .devilsAdvocateProtect, .assassinKill, .zombuulKill, .pukkaPoison,
             .snakeCharmerCheck, .witchCurse, .fangGuAttack, .vigormortisAttack,
             .noDashiiAttack, .vortoxAttack:
            return .players(minSelectionCount: 1, maxSelectionCount: 1, excludeSelf: self == .sailorChoose || self == .snakeCharmerCheck, aliveOnly: self == .snakeCharmerCheck || self == .devilsAdvocateProtect, deadOnly: false)
        case .professorResurrect:
            return .players(minSelectionCount: 1, maxSelectionCount: 1, excludeSelf: false, aliveOnly: false, deadOnly: true)
        case .poAttack:
            return .players(minSelectionCount: 0, maxSelectionCount: 1, excludeSelf: false, aliveOnly: false, deadOnly: false)
        case .gamblerGuess, .pitHagTransform:
            return .playerAndCharacter(excludeSelf: false, aliveOnly: false, deadOnly: false, characterScope: .any)
        case .cerenovusMadness:
            return .playerAndCharacter(excludeSelf: false, aliveOnly: false, deadOnly: false, characterScope: .good)
        case .courtierChooseCharacter:
            return .character(characterScope: .any)
        case .philosopherChoose:
            return .character(characterScope: .good)
        }
    }

    func chronicleSummary(actorName: String, selection: AbilitySelection) -> String? {
        switch (self, selection) {
        case let (.washerwomanInfo, .playersAndCharacter(players, character)):
            return "\(actorName), the claimed Washerwoman has said that \(seatNames(players)) includes the \(character.name)."
        case let (.librarianInfo, .playersAndCharacter(players, character)):
            return "\(actorName), the claimed Librarian has said that \(seatNames(players)) includes the \(character.name)."
        case let (.investigatorInfo, .playersAndCharacter(players, character)):
            return "\(actorName), the claimed Investigator has said that \(seatNames(players)) includes the \(character.name)."
        case let (.fortuneTellerCheck, .players(seats)):
            return "\(actorName), the claimed Fortune Teller has said they checked \(seatNames(seats))."
        case let (.ravenkeeperCheck, .players(seats)):
            return "\(actorName), the claimed Ravenkeeper has said they checked \(seatNames(seats))."
        case let (.slayerShot, .players(seats)):
            return "\(actorName), the claimed Slayer has said they shot \(seatNames(seats))."
        case let (.butlerMaster, .players(seats)):
            return "\(actorName), the claimed Butler has said they chose \(seatNames(seats)) as their master."
        case let (.poisonerPoison, .players(seats)):
            return "\(actorName), the claimed Poisoner has said they poisoned \(seatNames(seats))."
        case let (.impKill, .players(seats)):
            return "\(actorName), the claimed Imp has said they attacked \(seatNames(seats))."
        case let (.grandmotherInfo, .playerAndCharacter(player, character)):
            return "\(actorName), the claimed Grandmother has said they learned that \(seatName(player)) is the \(character.name)."
        case let (.sailorChoose, .players(seats)):
            return "\(actorName), the claimed Sailor has said they drank with \(seatNames(seats))."
        case let (.chambermaidCheck, .players(seats)):
            return "\(actorName), the claimed Chambermaid has said they checked \(seatNames(seats))."
        case let (.exorcistBlock, .players(seats)):
            return "\(actorName), the claimed Exorcist has said they chose \(seatNames(seats))."
        case let (.innkeeperProtect, .players(seats)):
            return "\(actorName), the claimed Innkeeper has said they protected \(seatNames(seats))."
        case let (.gamblerGuess, .playerAndCharacter(player, character)):
            return "\(actorName), the claimed Gambler has said they guessed that \(seatName(player)) was the \(character.name)."
        case let (.gossipStatement, .text(text)):
            return textSummary(actorName: actorName, roleName: "Gossip", verb: "made the statement", text: text)
        case let (.courtierChooseCharacter, .character(character)):
            return "\(actorName), the claimed Courtier has said they chose \(character.name)."
        case let (.professorResurrect, .players(seats)):
            return "\(actorName), the claimed Professor has said they resurrected \(seatNames(seats))."
        case let (.lunaticAttack, .players(seats)):
            return "\(actorName), the claimed Lunatic has said they targeted \(seatNames(seats))."
        case let (.moonchildCurse, .players(seats)):
            return "\(actorName), the claimed Moonchild has said they chose \(seatNames(seats))."
        case let (.godfatherKill, .players(seats)):
            return "\(actorName), the claimed Godfather has said they attacked \(seatNames(seats))."
        case let (.devilsAdvocateProtect, .players(seats)):
            return "\(actorName), the claimed Devil's Advocate has said they protected \(seatNames(seats))."
        case let (.assassinKill, .players(seats)):
            return "\(actorName), the claimed Assassin has said they attacked \(seatNames(seats))."
        case let (.zombuulKill, .players(seats)):
            return "\(actorName), the claimed Zombuul has said they attacked \(seatNames(seats))."
        case let (.pukkaPoison, .players(seats)):
            return "\(actorName), the claimed Pukka has said they poisoned \(seatNames(seats))."
        case let (.shabalothKill, .players(seats)):
            return "\(actorName), the claimed Shabaloth has said they attacked \(seatNames(seats))."
        case let (.poAttack, .players(seats)):
            if seats.isEmpty {
                return "\(actorName), the claimed Po has said they chose no-one."
            }
            return "\(actorName), the claimed Po has said they attacked \(seatNames(seats))."
        case let (.dreamerInfo, .playerAndTwoCharacters(player, firstCharacter, secondCharacter)):
            return "\(actorName), the claimed Dreamer has said they learned that \(seatName(player)) is either the \(firstCharacter.name) or the \(secondCharacter.name)."
        case let (.snakeCharmerCheck, .players(seats)):
            return "\(actorName), the claimed Snake Charmer has said they chose \(seatNames(seats))."
        case let (.seamstressCheck, .players(seats)):
            return "\(actorName), the claimed Seamstress has said they checked \(seatNames(seats))."
        case let (.philosopherChoose, .character(character)):
            return "\(actorName), the claimed Philosopher has said they chose \(character.name)."
        case let (.artistQuestion, .text(text)):
            return textSummary(actorName: actorName, roleName: "Artist", verb: "asked", text: text)
        case let (.jugglerInfo, .multiplePlayerAndCharacter(guesses)):
            guard !guesses.isEmpty else { return nil }
            let guessSummary = guesses.map { "\(seatName($0.0)) as \($0.1.name)" }.joined(separator: ", ")
            return "\(actorName), the claimed Juggler has said they guessed \(guessSummary)."
        case let (.witchCurse, .players(seats)):
            return "\(actorName), the claimed Witch has said they cursed \(seatNames(seats))."
        case let (.cerenovusMadness, .playerAndCharacter(player, character)):
            return "\(actorName), the claimed Cerenovus has said they chose \(seatName(player)) and made them mad as \(character.name)."
        case let (.pitHagTransform, .playerAndCharacter(player, character)):
            return "\(actorName), the claimed Pit-Hag has said they chose \(seatName(player)) to become \(character.name)."
        case let (.fangGuAttack, .players(seats)):
            return "\(actorName), the claimed Fang Gu has said they attacked \(seatNames(seats))."
        case let (.vigormortisAttack, .players(seats)):
            return "\(actorName), the claimed Vigormortis has said they attacked \(seatNames(seats))."
        case let (.noDashiiAttack, .players(seats)):
            return "\(actorName), the claimed No Dashii has said they attacked \(seatNames(seats))."
        case let (.vortoxAttack, .players(seats)):
            return "\(actorName), the claimed Vortox has said they attacked \(seatNames(seats))."
        case let (.chefInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Chef", verb: "has said", text: text)
        case let (.empathInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Empath", verb: "has said", text: text)
        case let (.undertakerInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Undertaker", verb: "has said", text: text)
        case let (.mathematicianInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Mathematician", verb: "has said", text: text)
        case let (.flowergirlInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Flowergirl", verb: "has said", text: text)
        case let (.townCrierInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Town Crier", verb: "has said", text: text)
        case let (.oracleInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Oracle", verb: "has said", text: text)
        case let (.savantInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: "Savant", verb: "has said", text: text)
        default:
            return nil
        }
    }

    private func textSummary(actorName: String, roleName: String, verb: String, text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return "\(actorName), the claimed \(roleName) \(verb): \(trimmed)"
    }

    private func seatNames(_ seats: [Seat]) -> String {
        let names = seats.map(seatName(_:))
        switch names.count {
        case 0:
            return "no-one"
        case 1:
            return names[0]
        case 2:
            return "\(names[0]) and \(names[1])"
        default:
            return names.dropLast().joined(separator: ", ") + ", and " + (names.last ?? "")
        }
    }

    private func seatName(_ seat: Seat) -> String {
        let trimmed = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unnamed player" : trimmed
    }
}
