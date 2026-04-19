//
//  Game.swift
//  lemegeton
//
//  Created by 승민 on 2/17/26.
//

import Foundation

struct Game: Codable {
    static let FINAL_ALIVE_CHARACTER = 2

    enum TurnPhase: Equatable {
        case firstNight
        case day(Int)
        case night(Int)

        var title: String {
            switch self {
            case .firstNight:
                return L10n.tr("First Night")
            case .day(let number):
                return L10n.tr("Day %lld", Int64(number))
            case .night(let number):
                return L10n.tr("Night %lld", Int64(number))
            }
        }

        var nextTitle: String {
            switch self {
            case .firstNight:
                return L10n.tr("Day 1")
            case .day(let number):
                return L10n.tr("Night %lld", Int64(number + 1))
            case .night(let number):
                return L10n.tr("Day %lld", Int64(number))
            }
        }
    }
    
    enum GameState: Codable {
        case set_up, in_game, game_over
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
    
    init() {
        self.mdate = Date()
        self.isCompleted = false
        self.gameLogs = []
        self.seats = []
        self.numOfDay = 0
        self.inGameNote = []
        self.gameState = .set_up
        self.inGameCharacters = []
    }
    
    func isScriptSelected() -> Bool {
        return !inGameCharacters.isEmpty
    }
    
    func numAliveCharacters() -> Int {
        return seats.map( { $0.player.isDead ? 0 : 1 }).reduce(0, +)
    }
    
    func isAllCharacterConfirmed() -> Bool {
        return seats.map(\.player.character).allSatisfy { $0 != nil }
    }
    
    func didAllDemonDie() -> Bool {
        return seats.map(\.player).filter { $0.character != nil && $0.character!.type == .demon }.allSatisfy { $0.isDead }
    }
    
    func didEvilWin() -> Bool {
        return (numAliveCharacters() < Game.FINAL_ALIVE_CHARACTER || isOnlyEvilAlive()) && !didAllDemonDie()
    }

    func isOnlyEvilAlive() -> Bool {
        let alivePlayers = seats.map(\.player).filter { !$0.isDead }
        guard !alivePlayers.isEmpty else { return false }

        return alivePlayers.allSatisfy {
            guard let character = $0.character else { return false }
            return character.type == .minion || character.type == .demon
        }
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
    }

    var currentPhase: TurnPhase? {
        guard !inGameNote.isEmpty else { return nil }

        if inGameNote.count == 1 {
            return .firstNight
        }

        if inGameNote.count.isMultiple(of: 2) {
            return .day(numOfDay)
        }

        return .night(numOfDay + 1)
    }

    var currentPhaseTitle: String {
        currentPhase?.title ?? L10n.tr("Setup")
    }

    var nextPhaseTitle: String {
        currentPhase?.nextTitle ?? L10n.tr("First Night")
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

    func phaseTimeline() -> [(title: String, note: String)] {
        inGameNote.enumerated().map { index, note in
            if index == 0 {
                return (L10n.tr("First Night"), note)
            }

            if (index + 1).isMultiple(of: 2) {
                return (L10n.tr("Day %lld", Int64(index / 2 + 1)), note)
            }

            return (L10n.tr("Night %lld", Int64(index / 2 + 2)), note)
        }
    }
}
