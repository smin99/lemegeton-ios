//
//  SideView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import SwiftUI

struct SeatSnapGuide {
    var verticalX: CGFloat?
    var horizontalY: CGFloat?
    var circleRadius: CGFloat?
    
    var isEmpty: Bool {
        verticalX == nil && horizontalY == nil && circleRadius == nil
    }
}

struct SeatsCanvas: View {
    @StateObject var boardVM: BoardViewModel
    @State private var activeGuide = SeatSnapGuide()
    
    private var boardSize: CGSize {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            .map { window in
                window.bounds.inset(by: window.safeAreaInsets).size
            } ?? .zero
    }

    var body: some View {
        let boardCenter = CGPoint(x: boardSize.width / 2, y: boardSize.height / 2)
        
        GeometryReader { proxy in
            VStack {
                ZStack {
                    if !activeGuide.isEmpty {
                        SnapGuideOverlay(
                            guide: activeGuide,
                            boardSize: boardSize,
                            boardCenter: boardCenter
                        )
                        .allowsHitTesting(false)
                        .zIndex(0)
                    }
                    
                    ForEach($boardVM.currentGame.seats) { $seat in
                        SeatView(
                            seat: $seat,
                            boardVM: boardVM,
                            boardSize: boardSize,
                            allSeats: boardVM.currentGame.seats,
                            onSnapGuideChanged: { guide in
                                activeGuide = guide
                            }
                        )
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
        .frame(width: boardSize.width, height: boardSize.height)
    }
}
private struct SnapGuideOverlay: View {
    let guide: SeatSnapGuide
    let boardSize: CGSize
    let boardCenter: CGPoint
    
    var body: some View {
        ZStack {
            if let verticalX = guide.verticalX {
                Path { path in
                    path.move(to: CGPoint(x: verticalX, y: 0))
                    path.addLine(to: CGPoint(x: verticalX, y: boardSize.height))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .foregroundStyle(Color.themePrimary.opacity(0.45))
            }
            
            if let horizontalY = guide.horizontalY {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: horizontalY))
                    path.addLine(to: CGPoint(x: boardSize.width, y: horizontalY))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .foregroundStyle(Color.themePrimary.opacity(0.45))
            }
            
            if let circleRadius = guide.circleRadius {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [8, 6]))
                    .foregroundStyle(Color.themePrimary.opacity(0.35))
                    .frame(width: circleRadius * 2, height: circleRadius * 2)
                    .position(boardCenter)
            }
        }
        .frame(width: boardSize.width, height: boardSize.height)
    }
}

