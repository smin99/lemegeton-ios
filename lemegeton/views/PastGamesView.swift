//
//  PastGamesView.swift
//  lemegeton
//
//  Created by Codex on 10/06/25.
//

import SwiftUI

struct PastGamesView: View {
    @ObservedObject var boardVM: BoardViewModel

    private static let gameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            Color(.themeSurface)
                .ignoresSafeArea()

            if boardVM.pastGames.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.themePrimary)

                    Text("No Past Games")
                        .grimoireBoldStyle(size: 24)

                    Text("Finished games will appear here once a chronicle ends.")
                        .grimoireStyle(size: 16, italic: false)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.themePrimary.opacity(0.8))
                }
                .padding(24)
            } else {
                List(boardVM.pastGames.indices, id: \.self) { index in
                    let game = boardVM.pastGames[index]

                    HStack(spacing: 12) {
                        NavigationLink {
                            PastGameDetailView(game: game)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(L10n.tr("Game %lld", Int64(boardVM.pastGames.count - index)))
                                    .grimoireBoldStyle(size: 20)

                                Label(Self.gameDateFormatter.string(from: game.mdate), systemImage: "calendar")
                                    .grimoireStyle(size: 16, italic: false)

                                Label(game.didEvilWin() ? "Evil won" : "Good won", systemImage: game.didEvilWin() ? "moon.stars.fill" : "sun.max.fill")
                                    .grimoireStyle(size: 16, italic: false)
                                    .foregroundStyle(game.didEvilWin() ? Color.red : Color.green)

                                Label(L10n.tr("%lld players", Int64(game.seats.count)), systemImage: "person.3.fill")
                                    .grimoireStyle(size: 16, italic: false)
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button {
                            boardVM.replayPastGame(game)
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.themePrimary)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowBackground(Color(.themeSurface).opacity(0.92))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            boardVM.removePastGames(atOffsets: IndexSet(integer: index))
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .navigationTitle("Past Games")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            boardVM.refreshPastGames()
        }
    }
}

#Preview {
    NavigationView {
        PastGamesView(boardVM: BoardViewModel())
    }
}
private struct PastGameDetailView: View {
    let game: Game

    private static let gameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(PastGameDetailView.gameDateFormatter.string(from: game.mdate))
                        .grimoireBoldStyle(size: 24)

                    Label(game.didEvilWin() ? "Evil won" : "Good won", systemImage: game.didEvilWin() ? "moon.stars.fill" : "sun.max.fill")
                        .grimoireStyle(size: 16, italic: false)
                        .foregroundStyle(game.didEvilWin() ? Color.red : Color.green)

                    Label(L10n.tr("%lld players", Int64(game.seats.count)), systemImage: "person.3.fill")
                        .grimoireStyle(size: 16, italic: false)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.themeSurface).opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                if game.seats.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.dashed")
                            .font(.system(size: 40))
                            .foregroundColor(.themePrimary)

                        Text("No Board State Saved")
                            .grimoireBoldStyle(size: 22)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                } else {
                    ReadOnlyBoardView(game: game)
                        .frame(height: 420)
                }

                if !game.inGameNote.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chronicle")
                            .grimoireBoldStyle(size: 22)

                        ForEach(Array(game.phaseTimeline().enumerated()), id: \.offset) { _, entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.title)
                                    .grimoireBoldStyle(size: 18)

                                Text(entry.note.isEmpty ? "No note recorded." : entry.note)
                                    .grimoireStyle(size: 15, italic: false)
                                    .foregroundStyle(.themePrimary.opacity(0.88))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color(.themeSurface).opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.themeSurface).ignoresSafeArea())
        .navigationTitle("Past Game")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ReadOnlyBoardView: View {
    let game: Game

    private let seatSize: CGFloat = 60
    private let nameHeight: CGFloat = 28
    private let boardPadding: CGFloat = 48

    private var seatBounds: CGRect {
        guard let firstSeat = game.seats.first else {
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        }

        let minX = game.seats.map(\.x).min() ?? firstSeat.x
        let maxX = game.seats.map(\.x).max() ?? firstSeat.x
        let minY = game.seats.map(\.y).min() ?? firstSeat.y
        let maxY = game.seats.map(\.y).max() ?? firstSeat.y

        return CGRect(
            x: minX,
            y: minY,
            width: max(maxX - minX, 1),
            height: max(maxY - minY, 1)
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - boardPadding * 2, 1)
            let availableHeight = max(proxy.size.height - boardPadding * 2, 1)
            let contentWidth = seatBounds.width + seatSize
            let contentHeight = seatBounds.height + seatSize + nameHeight
            let scale = min(availableWidth / contentWidth, availableHeight / contentHeight)
            let scaledWidth = contentWidth * scale
            let scaledHeight = contentHeight * scale
            let offsetX = (proxy.size.width - scaledWidth) / 2
            let offsetY = (proxy.size.height - scaledHeight) / 2

            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.themeSurface).opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
                    )

                ForEach(game.seats) { seat in
                    ReadOnlySeatView(seat: seat)
                        .scaleEffect(scale, anchor: .topLeading)
                        .position(
                            x: offsetX + ((seat.x - seatBounds.minX) + seatSize / 2) * scale,
                            y: offsetY + ((seat.y - seatBounds.minY) + (seatSize + nameHeight) / 2) * scale
                        )
                }
            }
        }
    }
}

private struct ReadOnlySeatView: View {
    let seat: Seat

    private let seatSize: CGFloat = 60

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(Color.white)
                .frame(width: seatSize, height: seatSize)
                .overlay {
                    if let character = seat.player.character {
                        Image(character.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: seatSize, height: seatSize)
                            .clipShape(Circle())
                    }

                    if seat.player.isDead {
                        ZStack {
                            Circle()
                                .fill(.red.opacity(0.68))

                            Text("R.I.P.")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    }
                }

            HStack(spacing: 4) {
                if seat.player.isCharacterConfirmed {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(
                            seat.player.character?.type == .townsfolk || seat.player.character?.type == .outsider
                            ? .blue : .red
                        )
                }

                Text(seat.player.name)
                    .frame(width: seatSize)
                    .font(.caption)
                    .foregroundStyle(seat.player.isDead ? .gray : .themeOnSurface)
                    .strikethrough(seat.player.isDead, color: .themeTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            if let learnedRoleName = seat.player.learnedCharacter?.localizedName {
                Text(L10n.tr("Learned: %@.", learnedRoleName))
                    .frame(width: seatSize + 24)
                    .font(.caption2)
                    .foregroundStyle(.themePrimary.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            if let revealedRoleName = seat.player.revealedCharacter?.localizedName {
                Text(L10n.tr("Revealed: %@.", revealedRoleName))
                    .frame(width: seatSize + 24)
                    .font(.caption2)
                    .foregroundStyle(.themeOnSurface.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(width: seatSize + 24, height: seatSize + 72)
    }
}
