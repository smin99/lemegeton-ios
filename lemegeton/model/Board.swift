//
//  Seat.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Foundation

// 🎲 Enum to represent the four sides of the board.
enum BoardSide: CaseIterable, Codable {
    case top, bottom, left, right
}

func isVertical(boardSide: BoardSide) -> Bool {
    return boardSide == .left || boardSide == .right
}

struct Side: Codable, Identifiable {
    var id = UUID() // Unique identifier
    
    var seats: [Seat] // seats that are on this side
    
    init(seats: [Seat] = []) {
        self.seats = seats
    }
    
    mutating func addSeat(seat: Seat) {
    seats.append(seat)
    }
}

// 🪑 Struct to represent a single seat on the board.
struct Seat: Codable, Identifiable {
    var id = UUID() // Unique identifier
    var player: Player // which player is seating on the seat
}
