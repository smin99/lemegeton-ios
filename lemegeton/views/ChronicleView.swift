//
//  ChronicleView.swift
//  lemegeton
//
//  Created by Codex on 10/06/25.
//

import SwiftUI

struct ChronicleView: View {
    @ObservedObject var boardVM: BoardViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if boardVM.currentGame.inGameNote.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundStyle(.themePrimary)

                        Text("No Chronicle Yet")
                            .grimoireBoldStyle(size: 24)

                        Text("Begin the chronicle to track each day and night.")
                            .grimoireStyle(size: 16, italic: false)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.themePrimary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                } else {
                    ForEach(Array(boardVM.currentGame.phaseTimeline().enumerated()), id: \.offset) { _, entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.title)
                                .grimoireBoldStyle(size: 20)

                            Text(entry.note.isEmpty ? "No note recorded." : entry.note)
                                .grimoireStyle(size: 15, italic: false)
                                .foregroundStyle(.themePrimary.opacity(0.88))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.themeSurface).opacity(0.92))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .padding()
        }
        .background(Color(.themeSurface).ignoresSafeArea())
        .navigationTitle("Chronicle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChronicleView(boardVM: BoardViewModel())
    }
}
