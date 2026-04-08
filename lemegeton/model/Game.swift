//
//  Game.swift
//  lemegeton
//
//  Created by 승민 on 2/17/26.
//

import Foundation

struct Game: Codable {
    static let FINAL_ALIVE_CHARACTER = 2
    
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
        return numAliveCharacters() < Game.FINAL_ALIVE_CHARACTER && !didAllDemonDie()
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
}
