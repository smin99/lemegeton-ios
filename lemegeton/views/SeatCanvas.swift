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

                        if !boardVM.currentGame.seats.isEmpty {
                            VStack {
                                HStack(spacing: 12) {
                                    SeatLayoutButton(shape: .circle) {
                                        withAnimation(.easeInOut(duration: 0.35)) {
                                            boardVM.arrangeSeatsInCircle(boardSize: boardSize)
                                        }
                                    }
                                    SeatLayoutButton(shape: .square) {
                                        withAnimation(.easeInOut(duration: 0.35)) {
                                            boardVM.arrangeSeatsInSquare(boardSize: boardSize)
                                        }
                                    }
                                    SeatLayoutButton(shape: .uShape) {
                                        withAnimation(.easeInOut(duration: 0.35)) {
                                            boardVM.arrangeSeatsInUShape(boardSize: boardSize)
                                        }
                                    }
                                }
                                .padding(.top, 12)
                                Spacer()
                            }
                            .zIndex(2)
                        }
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
private enum SeatLayoutShape {
    case circle, square, uShape
}

private struct SeatLayoutButton: View {
    let shape: SeatLayoutShape
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.themeSurface)
                Circle()
                    .stroke(Color.themePrimary.opacity(0.5), lineWidth: 1.5)
                shapeIcon
            }
            .frame(width: 40, height: 40)
        }
    }

    @ViewBuilder
    private var shapeIcon: some View {
        switch shape {
        case .circle:
            Circle()
                .stroke(Color.themePrimary, lineWidth: 1.5)
                .frame(width: 18, height: 18)
        case .square:
            Rectangle()
                .stroke(Color.themePrimary, lineWidth: 1.5)
                .frame(width: 16, height: 16)
        case .uShape:
            UShapePath()
                .stroke(Color.themePrimary, lineWidth: 1.5)
                .frame(width: 16, height: 16)
        }
    }
}

private struct UShapePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
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

