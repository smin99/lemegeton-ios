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
    case number(placeholder: String)
    case yesNo(prompt: String)
    case players(minSelectionCount: Int, maxSelectionCount: Int, excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool)
    case playersAndYesNo(playerCount: Int, excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, prompt: String)
    case playerAndCharacter(excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, characterScope: CharacterSelectionScope)
    case playersAndCharacter(playerCount: Int, excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, characterScope: CharacterSelectionScope)
    case playerAndTwoCharacters(excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, firstCharacterScope: CharacterSelectionScope, secondCharacterScope: CharacterSelectionScope)
    case multiplePlayerAndCharacter(maxSelectionCount: Int, excludeSelf: Bool, aliveOnly: Bool, deadOnly: Bool, characterScope: CharacterSelectionScope)
    case character(characterScope: CharacterSelectionScope)
}

enum AbilitySelection {
    case text(String)
    case number(Int)
    case yesNo(Bool)
    case players([Seat])
    case playersAndYesNo(players: [Seat], value: Bool)
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
    case virginTrigger
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
            return L10n.tr("Record Pair")
        case .chefInfo:
            return L10n.tr("Evil Pair Count")
        case .empathInfo:
            return L10n.tr("Neighbor Evil Count")
        case .fortuneTellerCheck:
            return L10n.tr("Demon Check")
        case .undertakerInfo:
            return L10n.tr("Executed Role")
        case .monkProtect, .innkeeperProtect, .devilsAdvocateProtect:
            return L10n.tr("Protected")
        case .ravenkeeperCheck:
            return L10n.tr("Checked Player")
        case .slayerShot:
            return L10n.tr("Shot")
        case .virginTrigger:
            return L10n.tr("Virgin Trigger")
        case .butlerMaster:
            return L10n.tr("Master")
        case .poisonerPoison, .pukkaPoison:
            return L10n.tr("Poisoned")
        case .impKill, .assassinKill, .zombuulKill, .shabalothKill, .fangGuAttack,
             .vigormortisAttack, .noDashiiAttack, .vortoxAttack, .godfatherKill:
            return L10n.tr("Attacked")
        case .grandmotherInfo:
            return L10n.tr("Learned Player")
        case .sailorChoose:
            return L10n.tr("Drank With")
        case .chambermaidCheck:
            return L10n.tr("How Many Woke?")
        case .exorcistBlock:
            return L10n.tr("Exorcised")
        case .gamblerGuess:
            return L10n.tr("Guess")
        case .gossipStatement:
            return L10n.tr("Statement")
        case .courtierChooseCharacter:
            return L10n.tr("Made Drunk")
        case .professorResurrect:
            return L10n.tr("Resurrected")
        case .lunaticAttack:
            return L10n.tr("Targeted")
        case .moonchildCurse, .witchCurse:
            return L10n.tr("Cursed")
        case .poAttack:
            return L10n.tr("Attacked")
        case .dreamerInfo:
            return L10n.tr("Dreamed")
        case .snakeCharmerCheck:
            return L10n.tr("Charmed")
        case .mathematicianInfo:
            return L10n.tr("Abnormal Count")
        case .flowergirlInfo:
            return L10n.tr("Demon Voted?")
        case .townCrierInfo:
            return L10n.tr("Minion Nominated?")
        case .oracleInfo:
            return L10n.tr("Dead Evil Count")
        case .savantInfo:
            return L10n.tr("Savant Info")
        case .seamstressCheck:
            return L10n.tr("Same Alignment?")
        case .philosopherChoose:
            return L10n.tr("Became")
        case .artistQuestion:
            return L10n.tr("Question")
        case .jugglerInfo:
            return L10n.tr("Guesses")
        case .cerenovusMadness:
            return L10n.tr("Mad As")
        case .pitHagTransform:
            return L10n.tr("Transform")
        }
    }

    var defaultSystemImage: String {
        switch self {
        case .chefInfo, .empathInfo, .chambermaidCheck, .mathematicianInfo, .oracleInfo:
            return "number.circle"
        case .flowergirlInfo, .townCrierInfo:
            return "checkmark.circle"
        case .fortuneTellerCheck:
            return "eye.circle"
        case .seamstressCheck:
            return "person.2.badge.gearshape"
        case .slayerShot:
            return "scope"
        case .virginTrigger:
            return "sparkles"
        default:
            break
        }

        switch input {
        case .text:
            return "note.text"
        case .number:
            return "number"
        case .yesNo:
            return "checkmark.circle"
        case .players:
            return "person.2.fill"
        case .playersAndYesNo:
            return "person.2.badge.gearshape"
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
        case .chefInfo, .empathInfo, .chambermaidCheck, .mathematicianInfo, .oracleInfo:
            return .number(placeholder: L10n.tr("Enter the number you learned"))
        case .flowergirlInfo, .townCrierInfo:
            return .yesNo(prompt: self == .flowergirlInfo ? L10n.tr("Did the Demon vote today?") : L10n.tr("Did a Minion nominate today?"))
        case .fortuneTellerCheck, .seamstressCheck:
            return .playersAndYesNo(
                playerCount: 2,
                excludeSelf: self == .seamstressCheck,
                aliveOnly: false,
                deadOnly: false,
                prompt: self == .fortuneTellerCheck ? L10n.tr("Was either chosen player the Demon?") : L10n.tr("Were they the same alignment?")
            )
        case .slayerShot:
            return .playersAndYesNo(
                playerCount: 1,
                excludeSelf: false,
                aliveOnly: false,
                deadOnly: false,
                prompt: L10n.tr("Did the shot cause an execution?")
            )
        case .virginTrigger:
            return .playersAndYesNo(
                playerCount: 1,
                excludeSelf: true,
                aliveOnly: false,
                deadOnly: false,
                prompt: L10n.tr("Did the nomination cause an execution?")
            )
        case .undertakerInfo:
            return .playerAndCharacter(excludeSelf: false, aliveOnly: false, deadOnly: true, characterScope: .any)
        case .ravenkeeperCheck:
            return .playerAndCharacter(excludeSelf: false, aliveOnly: false, deadOnly: false, characterScope: .any)
        case .gossipStatement, .savantInfo, .artistQuestion:
            return .text(placeholder: L10n.tr("Record the claimed ability use"))
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
        case .innkeeperProtect, .shabalothKill:
            return .players(minSelectionCount: 2, maxSelectionCount: 2, excludeSelf: false, aliveOnly: false, deadOnly: false)
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
            return L10n.tr("%@, the claimed Washerwoman has said that %@ includes the %@.", actorName, seatNames(players), character.localizedName)
        case let (.librarianInfo, .playersAndCharacter(players, character)):
            return L10n.tr("%@, the claimed Librarian has said that %@ includes the %@.", actorName, seatNames(players), character.localizedName)
        case let (.investigatorInfo, .playersAndCharacter(players, character)):
            return L10n.tr("%@, the claimed Investigator has said that %@ includes the %@.", actorName, seatNames(players), character.localizedName)
        case let (.fortuneTellerCheck, .players(seats)):
            return L10n.tr("%@, the claimed Fortune Teller has said they checked %@.", actorName, seatNames(seats))
        case let (.fortuneTellerCheck, .playersAndYesNo(seats, value)):
            return yesNoCheckSummary(actorName: actorName, roleName: L10n.tr("Fortune Teller"), seats: seats, value: value)
        case let (.ravenkeeperCheck, .players(seats)):
            return L10n.tr("%@, the claimed Ravenkeeper has said they checked %@.", actorName, seatNames(seats))
        case let (.ravenkeeperCheck, .playerAndCharacter(player, character)):
            return L10n.tr("%@, the claimed Ravenkeeper has said they learned that %@ is the %@.", actorName, seatName(player), character.localizedName)
        case let (.slayerShot, .players(seats)):
            return L10n.tr("%@, the claimed Slayer has said they shot %@.", actorName, seatNames(seats))
        case let (.slayerShot, .playersAndYesNo(seats, value)):
            return executionSummary(
                actorName: actorName,
                roleName: L10n.tr("Slayer"),
                verb: L10n.tr("shot"),
                seats: seats,
                executionHappened: value
            )
        case let (.virginTrigger, .playersAndYesNo(seats, value)):
            return executionSummary(
                actorName: actorName,
                roleName: L10n.tr("Virgin"),
                verb: L10n.tr("was nominated by"),
                seats: seats,
                executionHappened: value
            )
        case let (.butlerMaster, .players(seats)):
            return L10n.tr("%@, the claimed Butler has said they chose %@ as their master.", actorName, seatNames(seats))
        case let (.poisonerPoison, .players(seats)):
            return L10n.tr("%@, the claimed Poisoner has said they poisoned %@.", actorName, seatNames(seats))
        case let (.impKill, .players(seats)):
            return L10n.tr("%@, the claimed Imp has said they attacked %@.", actorName, seatNames(seats))
        case let (.grandmotherInfo, .playerAndCharacter(player, character)):
            return L10n.tr("%@, the claimed Grandmother has said they learned that %@ is the %@.", actorName, seatName(player), character.localizedName)
        case let (.sailorChoose, .players(seats)):
            return L10n.tr("%@, the claimed Sailor has said they drank with %@.", actorName, seatNames(seats))
        case let (.chambermaidCheck, .players(seats)):
            return L10n.tr("%@, the claimed Chambermaid has said they checked %@.", actorName, seatNames(seats))
        case let (.exorcistBlock, .players(seats)):
            return L10n.tr("%@, the claimed Exorcist has said they chose %@.", actorName, seatNames(seats))
        case let (.innkeeperProtect, .players(seats)):
            return L10n.tr("%@, the claimed Innkeeper has said they protected %@.", actorName, seatNames(seats))
        case let (.gamblerGuess, .playerAndCharacter(player, character)):
            return L10n.tr("%@, the claimed Gambler has said they guessed that %@ was the %@.", actorName, seatName(player), character.localizedName)
        case let (.gossipStatement, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Gossip"), verb: L10n.tr("made the statement"), text: text)
        case let (.courtierChooseCharacter, .character(character)):
            return L10n.tr("%@, the claimed Courtier has said they chose %@.", actorName, character.localizedName)
        case let (.professorResurrect, .players(seats)):
            return L10n.tr("%@, the claimed Professor has said they resurrected %@.", actorName, seatNames(seats))
        case let (.lunaticAttack, .players(seats)):
            return L10n.tr("%@, the claimed Lunatic has said they targeted %@.", actorName, seatNames(seats))
        case let (.moonchildCurse, .players(seats)):
            return L10n.tr("%@, the claimed Moonchild has said they chose %@.", actorName, seatNames(seats))
        case let (.godfatherKill, .players(seats)):
            return L10n.tr("%@, the claimed Godfather has said they attacked %@.", actorName, seatNames(seats))
        case let (.devilsAdvocateProtect, .players(seats)):
            return L10n.tr("%@, the claimed Devil's Advocate has said they protected %@.", actorName, seatNames(seats))
        case let (.assassinKill, .players(seats)):
            return L10n.tr("%@, the claimed Assassin has said they attacked %@.", actorName, seatNames(seats))
        case let (.zombuulKill, .players(seats)):
            return L10n.tr("%@, the claimed Zombuul has said they attacked %@.", actorName, seatNames(seats))
        case let (.pukkaPoison, .players(seats)):
            return L10n.tr("%@, the claimed Pukka has said they poisoned %@.", actorName, seatNames(seats))
        case let (.shabalothKill, .players(seats)):
            return L10n.tr("%@, the claimed Shabaloth has said they attacked %@.", actorName, seatNames(seats))
        case let (.poAttack, .players(seats)):
            if seats.isEmpty {
                return L10n.tr("%@, the claimed Po has said they chose no-one.", actorName)
            }
            return L10n.tr("%@, the claimed Po has said they attacked %@.", actorName, seatNames(seats))
        case let (.dreamerInfo, .playerAndTwoCharacters(player, firstCharacter, secondCharacter)):
            return L10n.tr("%@, the claimed Dreamer has said they learned that %@ is either the %@ or the %@.", actorName, seatName(player), firstCharacter.localizedName, secondCharacter.localizedName)
        case let (.snakeCharmerCheck, .players(seats)):
            return L10n.tr("%@, the claimed Snake Charmer has said they chose %@.", actorName, seatNames(seats))
        case let (.seamstressCheck, .players(seats)):
            return L10n.tr("%@, the claimed Seamstress has said they checked %@.", actorName, seatNames(seats))
        case let (.seamstressCheck, .playersAndYesNo(seats, value)):
            return yesNoCheckSummary(actorName: actorName, roleName: L10n.tr("Seamstress"), seats: seats, value: value)
        case let (.philosopherChoose, .character(character)):
            return L10n.tr("%@, the claimed Philosopher has said they chose %@.", actorName, character.localizedName)
        case let (.artistQuestion, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Artist"), verb: L10n.tr("asked"), text: text)
        case let (.jugglerInfo, .multiplePlayerAndCharacter(guesses)):
            guard !guesses.isEmpty else { return nil }
            let guessSummary = guesses.map { L10n.tr("%@ as %@", seatName($0.0), $0.1.localizedName) }.joined(separator: ", ")
            return L10n.tr("%@, the claimed Juggler has said they guessed %@.", actorName, guessSummary)
        case let (.witchCurse, .players(seats)):
            return L10n.tr("%@, the claimed Witch has said they cursed %@.", actorName, seatNames(seats))
        case let (.cerenovusMadness, .playerAndCharacter(player, character)):
            return L10n.tr("%@, the claimed Cerenovus has said they chose %@ and made them mad as %@.", actorName, seatName(player), character.localizedName)
        case let (.pitHagTransform, .playerAndCharacter(player, character)):
            return L10n.tr("%@, the claimed Pit-Hag has said they chose %@ to become %@.", actorName, seatName(player), character.localizedName)
        case let (.fangGuAttack, .players(seats)):
            return L10n.tr("%@, the claimed Fang Gu has said they attacked %@.", actorName, seatNames(seats))
        case let (.vigormortisAttack, .players(seats)):
            return L10n.tr("%@, the claimed Vigormortis has said they attacked %@.", actorName, seatNames(seats))
        case let (.noDashiiAttack, .players(seats)):
            return L10n.tr("%@, the claimed No Dashii has said they attacked %@.", actorName, seatNames(seats))
        case let (.vortoxAttack, .players(seats)):
            return L10n.tr("%@, the claimed Vortox has said they attacked %@.", actorName, seatNames(seats))
        case let (.chefInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Chef"), verb: L10n.tr("has said"), text: text)
        case let (.chefInfo, .number(value)):
            return numberSummary(actorName: actorName, roleName: L10n.tr("Chef"), value: value)
        case let (.empathInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Empath"), verb: L10n.tr("has said"), text: text)
        case let (.empathInfo, .number(value)):
            return numberSummary(actorName: actorName, roleName: L10n.tr("Empath"), value: value)
        case let (.undertakerInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Undertaker"), verb: L10n.tr("has said"), text: text)
        case let (.undertakerInfo, .playerAndCharacter(player, character)):
            return L10n.tr("%@, the claimed Undertaker has said they learned that %@ was the %@.", actorName, seatName(player), character.localizedName)
        case let (.mathematicianInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Mathematician"), verb: L10n.tr("has said"), text: text)
        case let (.mathematicianInfo, .number(value)):
            return numberSummary(actorName: actorName, roleName: L10n.tr("Mathematician"), value: value)
        case let (.flowergirlInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Flowergirl"), verb: L10n.tr("has said"), text: text)
        case let (.flowergirlInfo, .yesNo(value)):
            return yesNoSummary(actorName: actorName, roleName: L10n.tr("Flowergirl"), value: value)
        case let (.townCrierInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Town Crier"), verb: L10n.tr("has said"), text: text)
        case let (.townCrierInfo, .yesNo(value)):
            return yesNoSummary(actorName: actorName, roleName: L10n.tr("Town Crier"), value: value)
        case let (.oracleInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Oracle"), verb: L10n.tr("has said"), text: text)
        case let (.oracleInfo, .number(value)):
            return numberSummary(actorName: actorName, roleName: L10n.tr("Oracle"), value: value)
        case let (.savantInfo, .text(text)):
            return textSummary(actorName: actorName, roleName: L10n.tr("Savant"), verb: L10n.tr("has said"), text: text)
        case let (.chambermaidCheck, .number(value)):
            return numberSummary(actorName: actorName, roleName: L10n.tr("Chambermaid"), value: value)
        default:
            return nil
        }
    }

    private func textSummary(actorName: String, roleName: String, verb: String, text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return L10n.tr("%@, the claimed %@ %@: %@", actorName, roleName, verb, trimmed)
    }

    private func numberSummary(actorName: String, roleName: String, value: Int) -> String {
        L10n.tr("%@, the claimed %@ has said: %lld", actorName, roleName, Int64(value))
    }

    private func yesNoSummary(actorName: String, roleName: String, value: Bool) -> String {
        L10n.tr("%@, the claimed %@ has said: %@", actorName, roleName, value ? L10n.tr("Yes") : L10n.tr("No"))
    }

    private func yesNoCheckSummary(actorName: String, roleName: String, seats: [Seat], value: Bool) -> String {
        L10n.tr(
            "%@, the claimed %@ has said they checked %@ and learned %@.",
            actorName,
            roleName,
            seatNames(seats),
            value ? L10n.tr("Yes") : L10n.tr("No")
        )
    }

    private func executionSummary(actorName: String, roleName: String, verb: String, seats: [Seat], executionHappened: Bool) -> String {
        let outcome = executionHappened ? L10n.tr("an execution happened") : L10n.tr("no execution happened")
        return L10n.tr(
            "%@, the claimed %@ has said they %@ %@ and %@.",
            actorName,
            roleName,
            verb,
            seatNames(seats),
            outcome
        )
    }

    private func seatNames(_ seats: [Seat]) -> String {
        let names = seats.map(seatName(_:))
        switch names.count {
        case 0:
            return L10n.tr("no-one")
        case 1:
            return names[0]
        case 2:
            return L10n.tr("%@ and %@", names[0], names[1])
        default:
            return L10n.tr("%@, and %@", names.dropLast().joined(separator: ", "), names.last ?? "")
        }
    }

    private func seatName(_ seat: Seat) -> String {
        let trimmed = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.tr("Unnamed player") : trimmed
    }
}
