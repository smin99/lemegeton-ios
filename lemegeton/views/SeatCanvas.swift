//
//  SideView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import SwiftUI

struct SeatsCanvas: View {
    @StateObject var boardVM: BoardViewModel

    var body: some View {
        GeometryReader { proxy in
            VStack {
                ZStack {
                    ForEach($boardVM.currentGame.seats) { $seat in
                        SeatView(seat: $seat, boardVM: boardVM)
                            .zIndex(1)
                    }
                    
                    if boardVM.currentGame.gameState == .set_up {
                        Button {
                            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                            boardVM.addSeat(at: center)
                        } label: {
                            Image(systemName: "plus.circle.dashed")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.themePrimary)
                                .clipShape(Circle())
                        }
                        .padding()
                        .zIndex(0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.themeSurface))
        }
    }
}
