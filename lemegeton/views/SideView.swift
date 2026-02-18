//
//  SideView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import SwiftUI

struct SideView: View {
    var boardSide: BoardSide
    @StateObject var boardVM: BoardViewModel

    var body: some View {
        ZStack {
            if (isVertical(boardSide: boardSide)) {
                VStack {
                    Seats(boardSide: boardSide, boardVM: boardVM)
                }
            } else {
                HStack {
                    Seats(boardSide: boardSide, boardVM: boardVM)
                }
            }
        }
    }
}

struct Seats: View {
    var boardSide: BoardSide
    @StateObject var boardVM: BoardViewModel
    @State private var showSeatMenu = false
    @State private var seatMenuIndex = 0
    
    var body: some View {
        Spacer()
        
        ForEach(boardVM.sides[boardSide]!.seats) { seat in
            SeatView(boardSide: boardSide, seat: seat, boardVM: boardVM)
            Spacer()
        }
        
        if (boardVM.isSettingUp) {
            Button {
                boardVM.addSeatToSide(boardSide: boardSide, seat: Seat(player: Player(name: "", inGameCharacters: boardVM.inGameCharacters)))
            } label: {
                Image(systemName: "plus.circle.dashed")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.themePrimary)
                    .clipShape(Circle())
            }
            
            Spacer()
        }
    }
}

#Preview {
    SideView(boardSide: .top, boardVM: BoardViewModel())
}
