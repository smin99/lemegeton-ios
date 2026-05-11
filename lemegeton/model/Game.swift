//
//  Game.swift
//  lemegeton
//
//  Created by 승민 on 2/17/26.
//

import Foundation

struct NominationRecord: Codable, Identifiable {
    var id: UUID
    var phaseIndex: Int
    var nominatorSeatID: UUID
    var nomineeSeatID: UUID
    var voterSeatIDs: [UUID]

    init(
        id: UUID = UUID(),
        phaseIndex: Int,
        nominatorSeatID: UUID,
        nomineeSeatID: UUID,
        voterSeatIDs: [UUID]
    ) {
        self.id = id
        self.phaseIndex = phaseIndex
        self.nominatorSeatID = nominatorSeatID
        self.nomineeSeatID = nomineeSeatID
        self.voterSeatIDs = voterSeatIDs
    }
}

struct Game: Codable {
    static let FINAL_ALIVE_CHARACTER = 2

    struct SetupCounts {
        let townsfolk: Int
        let outsiders: Int
        let minions: Int
        let demons: Int

        var evilRoles: Int {
            minions + demons
        }
    }

    private enum CodingKeys: String, CodingKey {
        case mdate
        case isCompleted
        case gameLogs
        case seats
        case numOfDay
        case inGameNote
        case gameState
        case inGameCharacters
        case nominationRecords
    }

    enum TurnPhase: Equatable {
        case firstNight
        case day(Int)
        case nomination(Int)
        case night(Int)

        var title: String {
            switch self {
            case .firstNight:
                return L10n.tr("First Night")
            case .day(let number):
                return L10n.tr("Day %lld", Int64(number))
            case .nomination(let number):
                return L10n.tr("Nomination %lld", Int64(number))
            case .night(let number):
                return L10n.tr("Night %lld", Int64(number))
            }
        }

        var nextTitle: String {
            switch self {
            case .firstNight:
                return L10n.tr("Day 1")
            case .day(let number):
                return L10n.tr("Nomination %lld", Int64(number))
            case .nomination(let number):
                return L10n.tr("Night %lld", Int64(number))
            case .night(let number):
                return L10n.tr("Day %lld", Int64(number + 1))
            }
        }
    }
    
    enum GameState: Codable {
        case set_up, in_game, role_reveal, game_over
    }
    
    // MARK: Game Stat related Properties
    var mdate: Date         // 게임 시작한 날
    var isCompleted: Bool   // 게임이 끝났는지
    var gameLogs: [String]  // [완료한 게임용] 게임 내에서 발생하는 모든 로그
    
    // MARK: In-Game Properties
    var seats: [Seat]           // 게임 보드의 자리들
    var numOfDay: Int           // 몇번째 날인지: 0 = 첫번쨰 날, ...
    var inGameNote: [String]    // 각 날에 적은 노트
    var gameState: GameState    // 게임의 단계
    var inGameCharacters: [Character]
    var nominationRecords: [NominationRecord]
    
    init() {
        self.mdate = Date()
        self.isCompleted = false
        self.gameLogs = []
        self.seats = []
        self.numOfDay = 0
        self.inGameNote = []
        self.gameState = .set_up
        self.inGameCharacters = []
        self.nominationRecords = []
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mdate = try container.decode(Date.self, forKey: .mdate)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        gameLogs = try container.decode([String].self, forKey: .gameLogs)
        seats = try container.decode([Seat].self, forKey: .seats)
        numOfDay = try container.decode(Int.self, forKey: .numOfDay)
        inGameNote = try container.decode([String].self, forKey: .inGameNote)
        gameState = try container.decode(GameState.self, forKey: .gameState)
        inGameCharacters = try container.decode([Character].self, forKey: .inGameCharacters)
        nominationRecords = try container.decodeIfPresent([NominationRecord].self, forKey: .nominationRecords) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mdate, forKey: .mdate)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(gameLogs, forKey: .gameLogs)
        try container.encode(seats, forKey: .seats)
        try container.encode(numOfDay, forKey: .numOfDay)
        try container.encode(inGameNote, forKey: .inGameNote)
        try container.encode(gameState, forKey: .gameState)
        try container.encode(inGameCharacters, forKey: .inGameCharacters)
        try container.encode(nominationRecords, forKey: .nominationRecords)
    }
    
    func isScriptSelected() -> Bool {
        return !inGameCharacters.isEmpty
    }

    func setupCounts() -> SetupCounts? {
        switch seats.count {
        case 5:
            return SetupCounts(townsfolk: 3, outsiders: 0, minions: 1, demons: 1)
        case 6:
            return SetupCounts(townsfolk: 3, outsiders: 1, minions: 1, demons: 1)
        case 7:
            return SetupCounts(townsfolk: 5, outsiders: 0, minions: 1, demons: 1)
        case 8:
            return SetupCounts(townsfolk: 5, outsiders: 1, minions: 1, demons: 1)
        case 9:
            return SetupCounts(townsfolk: 5, outsiders: 2, minions: 1, demons: 1)
        case 10:
            return SetupCounts(townsfolk: 7, outsiders: 0, minions: 2, demons: 1)
        case 11:
            return SetupCounts(townsfolk: 7, outsiders: 1, minions: 2, demons: 1)
        case 12:
            return SetupCounts(townsfolk: 7, outsiders: 2, minions: 2, demons: 1)
        case 13:
            return SetupCounts(townsfolk: 9, outsiders: 0, minions: 3, demons: 1)
        case 14:
            return SetupCounts(townsfolk: 9, outsiders: 1, minions: 3, demons: 1)
        case 15:
            return SetupCounts(townsfolk: 9, outsiders: 2, minions: 3, demons: 1)
        default:
            return nil
        }
    }
    
    func numAliveCharacters() -> Int {
        return seats.map( { $0.player.isDead ? 0 : 1 }).reduce(0, +)
    }
    
    func isAllCharacterConfirmed() -> Bool {
        return seats.map(\.player.character).allSatisfy { $0 != nil }
    }

    func isAllRevealedCharacterRecorded() -> Bool {
        !seats.isEmpty && seats.map(\.player.revealedCharacter).allSatisfy { $0 != nil }
    }

    func canCompleteAfterReveal() -> Bool {
        !seats.isEmpty && seats.allSatisfy(\.isResolvedForGameCompletion)
    }
    
    func didAllDemonDie() -> Bool {
        let demonPlayers = seats.map(\.player).filter {
            resolvedCharacter(for: $0)?.type == .demon
        }
        return !demonPlayers.isEmpty && demonPlayers.allSatisfy(\.isDead)
    }
    
    func didEvilWin() -> Bool {
        return (numAliveCharacters() <= Game.FINAL_ALIVE_CHARACTER || isOnlyEvilAlive()) && !didAllDemonDie()
    }

    func isOnlyEvilAlive() -> Bool {
        let alivePlayers = seats.map(\.player).filter { !$0.isDead }
        guard !alivePlayers.isEmpty else { return false }

        return alivePlayers.allSatisfy {
            guard let character = resolvedCharacter(for: $0) else { return false }
            return character.type == .minion || character.type == .demon
        }
    }

    private func resolvedCharacter(for player: Player) -> Character? {
        player.revealedCharacter ?? player.character
    }
    
    mutating func clearGameState() {
        mdate = Date()
        isCompleted = false
        
        for index in seats.indices {
            seats[index].player.clearRoleAndState()
        }
        numOfDay = 0
        inGameNote.removeAll()
        gameState = .set_up
        inGameCharacters.removeAll()
        nominationRecords.removeAll()
    }

    var currentPhaseIndex: Int? {
        inGameNote.isEmpty ? nil : inGameNote.count - 1
    }

    var currentPhase: TurnPhase? {
        guard !inGameNote.isEmpty else { return nil }

        if inGameNote.count == 1 {
            return .firstNight
        }

        let phaseOffset = inGameNote.count - 2
        let cycle = phaseOffset / 3 + 1

        switch phaseOffset % 3 {
        case 0:
            return .day(cycle)
        case 1:
            return .nomination(cycle)
        default:
            return .night(cycle)
        }
    }

    var currentPhaseTitle: String {
        currentPhase?.title ?? L10n.tr("Setup")
    }

    var nextPhaseTitle: String {
        currentPhase?.nextTitle ?? L10n.tr("First Night")
    }

    var isDayPhase: Bool {
        if case .day = currentPhase {
            return true
        }
        return false
    }

    var isNominationPhase: Bool {
        if case .nomination = currentPhase {
            return true
        }
        return false
    }

    mutating func startChronicleIfNeeded() {
        guard inGameNote.isEmpty else { return }
        numOfDay = 0
        inGameNote = [""]
    }

    mutating func advancePhase() {
        switch currentPhase {
        case .none:
            startChronicleIfNeeded()
        case .firstNight:
            numOfDay = 1
            inGameNote.append("")
        case .day:
            inGameNote.append("")
        case .nomination:
            inGameNote.append("")
        case .night:
            numOfDay += 1
            inGameNote.append("")
        }
    }

    mutating func updateCurrentPhaseNote(_ note: String) {
        if inGameNote.isEmpty {
            startChronicleIfNeeded()
        }

        guard let index = inGameNote.indices.last else { return }
        inGameNote[index] = note
    }

    mutating func appendCurrentPhaseEvent(_ event: String) {
        if inGameNote.isEmpty {
            startChronicleIfNeeded()
        }

        guard let index = inGameNote.indices.last else { return }
        let trimmedNote = inGameNote[index].trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedNote.isEmpty {
            inGameNote[index] = event
        } else {
            inGameNote[index] += "\n\(event)"
        }
    }

    func currentPhaseNote() -> String {
        inGameNote.last ?? ""
    }

    func phaseTimeline() -> [(phase: TurnPhase, title: String, note: String)] {
        inGameNote.enumerated().map { index, note in
            if index == 0 {
                return (.firstNight, L10n.tr("First Night"), note)
            }

            let phaseOffset = index - 1
            let cycle = phaseOffset / 3 + 1

            switch phaseOffset % 3 {
            case 0:
                return (.day(cycle), L10n.tr("Day %lld", Int64(cycle)), note)
            case 1:
                return (.nomination(cycle), L10n.tr("Nomination %lld", Int64(cycle)), note)
            default:
                return (.night(cycle), L10n.tr("Night %lld", Int64(cycle)), note)
            }
        }
    }
}

private extension Seat {
    var isResolvedForGameCompletion: Bool {
        if player.revealedCharacter != nil {
            return true
        }

        guard let claimedCharacter = player.character else {
            return false
        }

        switch claimedCharacter.type {
        case .townsfolk, .outsider:
            return true
        case .minion, .demon:
            return false
        }
    }
}
