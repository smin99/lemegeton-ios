//
//  Seat.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Foundation
import CoreGraphics

// 🪑 Struct to represent a single seat on the board.
struct Seat: Codable, Identifiable {
    var id = UUID() // Unique identifier
    var player: Player // which player is seating on the seat
    var x: CGFloat // x position on board canvas
    var y: CGFloat // y position on board canvas

    init(id: UUID = UUID(), player: Player, x: CGFloat = 0, y: CGFloat = 0) {
        self.id = id
        self.player = player
        self.x = x
        self.y = y
    }
}
