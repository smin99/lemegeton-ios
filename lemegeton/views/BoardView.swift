//
//  ContentView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/4/25.
//

import SwiftUI
import Combine

struct BoardView: View {
    @StateObject var boardVM: BoardViewModel = BoardViewModel()
    
    enum ActiveAlert: Identifiable {
        case resetBoard, cannotStartGame, cannotEndGame, beginRoleReveal, cannotCompleteGame, resetAfterCompleteGame
        var id: Int { hashValue }
        
        var title: String {
            switch self {
            case .resetBoard:
                L10n.tr("Reset the Grimoire?")
            case .cannotStartGame:
                L10n.tr("Cannot begin the chronicle")
            case .cannotEndGame:
                L10n.tr("Finish the game?")
            case .beginRoleReveal:
                L10n.tr("Begin final reveal?")
            case .cannotCompleteGame:
                L10n.tr("Cannot complete the game")
            case .resetAfterCompleteGame:
                L10n.tr("Restart with same board?")
            }
        }
        
        var message: String {
            switch self {
            case .resetBoard:
                L10n.tr("This will clear all player seats and roles. This action cannot be undone.")
            case .cannotStartGame:
                L10n.tr("Select at least as many characters as there are seats before starting the game.")
            case .cannotEndGame:
                L10n.tr("The game has not ended. Please record all player's characters and update their death state.")
            case .beginRoleReveal:
                L10n.tr("This will move the game into the final reveal stage so you can record each player's actual role.")
            case .cannotCompleteGame:
                L10n.tr("Record every player's revealed role before completing the game.")
            case .resetAfterCompleteGame:
                L10n.tr("Restart will keep the current board setup including player name and seats.")
            }
        }
    }
    @State private var activeAlert: ActiveAlert?
    
    @State private var showMenu = false
    @State private var showCharacterSheet: Bool = false
    @State private var showPhaseNoteSheet: Bool = false
    @State private var showChronicle = false
    @State private var showPlayerExplanations = false
    @State private var isChronicleSummaryExpanded = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeSurface
                    .ignoresSafeArea()

                    ZStack(alignment: .topLeading) {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                Color.clear
                                    .frame(height: boardTopInset)

                                SeatsCanvas(boardVM: boardVM)
                            }
                        }

                        if boardVM.currentGame.gameState != .set_up {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isChronicleSummaryExpanded.toggle()
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(boardVM.currentGame.currentPhaseTitle)
                                            .grimoireBoldStyle(size: 20)
                                            .foregroundStyle(.themeOnSurface)

                                        Spacer()

                                        Image(systemName: isChronicleSummaryExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundStyle(.themePrimary)
                                    }

                                    if isChronicleSummaryExpanded {
                                        Text(boardVM.currentGame.currentPhaseNote().isEmpty ? "No chronicle note yet." : boardVM.currentGame.currentPhaseNote())
                                            .grimoireStyle(size: 14, italic: false)
                                            .foregroundStyle(.themePrimary.opacity(0.9))
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.themeSurface.opacity(0.94))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                        }

                        if boardVM.currentGame.gameState == .in_game && boardVM.currentGame.isNominationPhase {
                            NominationPhaseControlsView(boardVM: boardVM)
                                .padding(.top, isChronicleSummaryExpanded ? 132 : 84)
                                .padding(.horizontal, 16)
                        }

                        // The Custom "Menu" (Dropdown)
                        if showMenu {
                            VStack(alignment: .leading, spacing: 12) {
                                if (boardVM.currentGame.gameState == .set_up) {
                                    Button() {
                                        self.showCharacterSheet = true
                                    } label: {
                                        Label("Scenario & Roles", systemImage: "theatermasks")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())

                                    Divider()
                                        .background(Color(.themeTertiary))

                                    NavigationLink {
                                        PastGamesView(boardVM: boardVM)
                                    } label: {
                                        Label("Previous Games", systemImage: "clock.arrow.circlepath")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())

                                    Divider()
                                        .background(Color(.themeTertiary))

                                    Button(role: .confirm) {
                                        if boardVM.canStartGame() {
                                            boardVM.updateSetup()
                                        } else {
                                            activeAlert = .cannotStartGame
                                        }
                                    } label: {
                                        Label("Begin Chronicle", systemImage: "play.circle.fill")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())

                                    Divider()
                                        .background(Color(.themeTertiary))

                                    // Reset the board
                                    Button(role: .destructive) {
                                        activeAlert = .resetBoard
                                    } label: {
                                        Label("Clear Grimoire", systemImage: "arrow.uturn.backward.circle")
                                    }
                                    .buttonStyle(GrimoireButtonStyle(isDestructive: true))

                                } else if boardVM.currentGame.gameState == .in_game {
                                Button {
                                    showPhaseNoteSheet = true
                                } label: {
                                    Label(boardVM.currentGame.currentPhaseTitle, systemImage: "book.closed")
                                }
                                .buttonStyle(GrimoireButtonStyle())

                                Divider()
                                    .background(Color(.themeTertiary))
                                
                                Button {
                                    showPlayerExplanations = true
                                } label: {
                                    Label("Contradictions", systemImage: "exclamationmark.bubble")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))

                                // Finish the game
                                Button {
                                    activeAlert = boardVM.canEndGame() ? .beginRoleReveal : .cannotEndGame
                                } label: {
                                        Label("End Game", systemImage: "flag.checkered")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())

                                    Divider()
                                        .background(Color(.themeTertiary))

                                    NavigationLink {
                                        PastGamesView(boardVM: boardVM)
                                    } label: {
                                        Label("Previous Games", systemImage: "clock.arrow.circlepath")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())

                                    Divider()
                                        .background(Color(.themeTertiary))

                                    // Move back to set up state
                                    Button {
                                        boardVM.updateSetup()
                                    } label: {
                                        Label("Arrange Seating", systemImage: "slider.horizontal.3")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())
                                } else {
                                    NavigationLink {
                                        PastGamesView(boardVM: boardVM)
                                    } label: {
                                        Label("Previous Games", systemImage: "clock.arrow.circlepath")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())

                                    Divider()
                                        .background(Color(.themeTertiary))

                                    Button {
                                        activeAlert = boardVM.canCompleteGameAfterReveal() ? .resetAfterCompleteGame : .cannotCompleteGame
                                    } label: {
                                        Label("Complete Game", systemImage: "checkmark.seal")
                                    }
                                    .buttonStyle(GrimoireButtonStyle())
                                }
                            }
                            .padding()
                            .background(.themeSurface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1)))
                            .frame(width: 250)
                            .transition(.scale(scale: 0.9, anchor: .topLeading).combined(with: .opacity))
                            .zIndex(1) // Ensure it stays on top
                        }
                    }
            }
            .onTapGesture {
                if showMenu {
                    withAnimation {
                        showMenu.toggle()
                    }
                }
            }
            .sheet(isPresented: $showCharacterSheet) {
                CharacterListView(titleText: L10n.tr("Add characters in game"), onComplete: { characters in
                    boardVM.setUpCharacters(characters: Array(characters).sorted(by: { $0.type.rawValue < $1.type.rawValue }))
                    showCharacterSheet = false
                }, allCharacters: boardVM.allCharacters, includeScenario: true, maxSelectionCount: nil, selectedCharacters: Set(boardVM.currentGame.inGameCharacters))
            }
            .sheet(isPresented: $showPhaseNoteSheet) {
                NoteTakeView(
                    title: boardVM.currentGame.currentPhaseTitle,
                    onComplete: { note in
                        boardVM.updateCurrentPhaseNote(note)
                        showPhaseNoteSheet = false
                    },
                    buttonTitle: L10n.tr("Save Note"),
                    placeholder: L10n.tr("Write what happened during this phase"),
                    note: boardVM.currentGame.currentPhaseNote()
                )
            }
            .sheet(isPresented: $showPlayerExplanations) {
                PlayerExplanationView(game: boardVM.currentGame)
            }
            .navigationDestination(isPresented: $showChronicle) {
                ChronicleView(boardVM: boardVM)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.themeSurface, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color.themeSurface, for: .tabBar)
            .toolbarBackgroundVisibility(.visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(toolbarTitle)
                        .grimoireBoldStyle(size: 18)
                        .tracking(2)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.spring()) {
                            showMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.themePrimary)
                    }
                }
                .sharedBackgroundVisibility(.hidden)
                
                ToolbarItem(placement: .topBarTrailing) {
                    if boardVM.currentGame.gameState != .set_up {
                        Button {
                            boardVM.undoLastRecord()
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .foregroundColor(.themePrimary)
                        }
                        .disabled(!boardVM.canUndoLastRecord)
                    }
                }
                .sharedBackgroundVisibility(.hidden)
                
                ToolbarItem(placement: .topBarTrailing) {
                    if boardVM.currentGame.gameState != .set_up {
                        Button {
                            showChronicle = true
                        } label: {
                            Image(systemName: "book.pages")
                                .foregroundColor(.themePrimary)
                        }
                    }
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .topBarTrailing) {
                    if boardVM.currentGame.gameState == .in_game {
                        Button {
                            boardVM.advancePhase()
                        } label: {
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.themePrimary)
                        }
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            }
            
            // MARK: Alerts
            .alert(item: $activeAlert) { alert in
                var primaryButton: Alert.Button?
                var secondaryButton: Alert.Button?
                switch alert {
                case .resetBoard:
                    primaryButton = .destructive(Text("Reset")) {
                        boardVM.resetBoard()
                    }
                    secondaryButton = .cancel(Text("Cancel"))
                case .cannotEndGame:
                    return Alert(
                        title: Text(alert.title),
                        message: Text(alert.message),
                        dismissButton: .default(Text("OK"))
                    )
                case .cannotStartGame:
                    return Alert(
                        title: Text(alert.title),
                        message: Text(alert.message),
                        dismissButton: .default(Text("OK"))
                    )
                case .beginRoleReveal:
                    primaryButton = .default(Text("Begin")) {
                        boardVM.beginRoleReveal()
                    }
                    secondaryButton = .cancel(Text("Cancel"))
                case .cannotCompleteGame:
                    return Alert(
                        title: Text(alert.title),
                        message: Text(alert.message),
                        dismissButton: .default(Text("OK"))
                    )
                case .resetAfterCompleteGame:
                    primaryButton = .default(Text("Restart")) {
                        boardVM.endGame(resetGame: false)
                    }
                    secondaryButton = .destructive(Text("Clear Grimorie")) {
                        boardVM.endGame(resetGame: true)
                    }
                }
                
                return Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    primaryButton: primaryButton!,
                    secondaryButton: secondaryButton!)
            }
        }
    }

    private var toolbarTitle: String {
        switch boardVM.currentGame.gameState {
        case .set_up:
            return L10n.tr("Set up the Grimoire")
        case .in_game:
            return L10n.tr("%lld Alive", Int64(boardVM.currentGame.numAliveCharacters()))
        case .role_reveal:
            return L10n.tr("Final Reveal")
        case .game_over:
            return L10n.tr("Game Complete")
        }
    }

    private var boardTopInset: CGFloat {
        guard boardVM.currentGame.gameState != .set_up else {
            return 0
        }

        var inset: CGFloat = isChronicleSummaryExpanded ? 132 : 84

        if boardVM.currentGame.gameState == .in_game && boardVM.currentGame.isNominationPhase {
            inset += 180
        }

        return inset
    }
}

private struct NominationPhaseControlsView: View {
    @StateObject var boardVM: BoardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(boardVM.nominationSelectionMode.instruction)
                .grimoireStyle(size: 14, italic: false)
                .foregroundStyle(.themePrimary.opacity(0.92))

            HStack(spacing: 8) {
                nominationModeButton(.nominator, systemImage: "person.badge.plus")
                nominationModeButton(.nominee, systemImage: "person.crop.circle.badge.questionmark")
                nominationModeButton(.voters, systemImage: "checkmark.circle")
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.tr("Nominator: %@", displayName(for: boardVM.nominationNominator)))
                Text(L10n.tr("Nominee: %@", displayName(for: boardVM.nominationNominee)))
                Text(L10n.tr("Voters: %@", voterSummary))
            }
            .font(.caption)
            .foregroundStyle(.themeOnSurface.opacity(0.84))

            HStack(spacing: 10) {
                Button {
                    boardVM.recordNominationDraft()
                } label: {
                    Label("Record Nomination", systemImage: "square.and.pencil")
                }
                .buttonStyle(GlowButtonStyle())
                .disabled(!boardVM.canRecordNominationDraft)

                Button {
                    boardVM.resetNominationDraft()
                } label: {
                    Label("Clear Selection", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(GrimoireButtonStyle())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.themeSurface.opacity(0.96))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var voterSummary: String {
        let voters = boardVM.nominationVoters
        if voters.isEmpty {
            return L10n.tr("no-one")
        }
        return voters.map(displayName(for:)).joined(separator: ", ")
    }

    private func nominationModeButton(_ mode: NominationSelectionMode, systemImage: String) -> some View {
        Button {
            boardVM.setNominationSelectionMode(mode)
        } label: {
            Label(mode.title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(boardVM.nominationSelectionMode == mode ? Color.themePrimary.opacity(0.22) : Color.themeSurface.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(boardVM.nominationSelectionMode == mode ? Color.themePrimary : Color.themePrimary.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .foregroundStyle(boardVM.nominationSelectionMode == mode ? .themePrimary : .themeOnSurface)
    }

    private func displayName(for seat: Seat?) -> String {
        guard let seat else {
            return L10n.tr("Not selected")
        }
        let trimmed = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.tr("Unnamed player") : trimmed
    }
}

private struct PlayerExplanationView: View {
    let game: Game

    private var contradictions: [ContradictionEntry] {
        ContradictionAnalyzer(game: game).entries
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("This view lists concrete contradiction points between claims, recorded actions, learned information, and final revealed roles.")
                        .grimoireStyle(size: 15, italic: false)
                        .foregroundStyle(.themePrimary.opacity(0.88))

                    if contradictions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("No strong contradictions found yet.")
                                .grimoireBoldStyle(size: 18)
                                .foregroundStyle(.themeOnSurface)

                            Text("That does not prove the game state is coherent. It only means the chronicle does not yet contain an obvious conflict under the current claims and reveals.")
                                .grimoireStyle(size: 15, italic: false)
                                .foregroundStyle(.themePrimary.opacity(0.88))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.themeSurface.opacity(0.94))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
                        )
                    } else {
                        ForEach(contradictions) { contradiction in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(contradiction.title)
                                            .grimoireBoldStyle(size: 18)
                                            .foregroundStyle(.themeOnSurface)
                                        if let subtitle = contradiction.subtitle {
                                            Text(subtitle)
                                                .grimoireStyle(size: 14, italic: false)
                                                .foregroundStyle(.themePrimary)
                                        }
                                    }
                                    Spacer()
                                    Text(contradiction.severityLabel)
                                        .font(.caption.bold())
                                        .foregroundStyle(contradiction.severityColor)
                                }

                                Text(contradiction.message)
                                    .grimoireStyle(size: 15, italic: false)
                                    .foregroundStyle(.themePrimary.opacity(0.88))

                                if let implication = contradiction.implication {
                                    Text(implication)
                                        .font(.caption)
                                        .foregroundStyle(.themeOnSurface.opacity(0.82))
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.themeSurface.opacity(0.94))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.themeSurface.ignoresSafeArea())
            .navigationTitle("Contradictions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.themeSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

private struct ContradictionEntry: Identifiable {
    enum Severity {
        case strong
        case medium

        var label: String {
            switch self {
            case .strong:
                return L10n.tr("Strong")
            case .medium:
                return L10n.tr("Medium")
            }
        }

        var color: Color {
            switch self {
            case .strong:
                return .red
            case .medium:
                return .orange
            }
        }
    }

    let id = UUID()
    let title: String
    let subtitle: String?
    let message: String
    let implication: String?
    let severity: Severity

    var severityLabel: String { severity.label }
    var severityColor: Color { severity.color }
}

private struct ContradictionAnalyzer {
    let game: Game

    var entries: [ContradictionEntry] {
        var results: [ContradictionEntry] = []
        results.append(contentsOf: duplicateClaimContradictions())
        results.append(contentsOf: revealContradictions())
        results.append(contentsOf: abilityCadenceContradictions())
        results.append(contentsOf: virginContradictions())
        results.append(contentsOf: slayerContradictions())
        results.append(contentsOf: fortuneTellerContradictions())
        results.append(contentsOf: seamstressContradictions())
        results.append(contentsOf: flowergirlContradictions())
        results.append(contentsOf: townCrierContradictions())
        results.append(contentsOf: learnedInfoContradictions())
        return results
    }

    private var namedSeats: [Seat] {
        game.seats.filter { !$0.player.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var nominationEvents: [NominationEvent] {
        game.phaseTimeline().enumerated().flatMap { phaseIndex, entry in
            entry.note
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .compactMap { line in
                    parseNominationEvent(line: line, phaseIndex: phaseIndex)
                }
        }
    }

    private var contradictionWeightsBySeatID: [UUID: Int] {
        var weights: [UUID: Int] = [:]

        for seat in game.seats {
            guard let claimed = seat.player.character,
                  let revealed = seat.player.revealedCharacter,
                  claimed.id != revealed.id else {
                continue
            }
            weights[seat.id, default: 0] += 3
        }

        for seat in game.seats {
            guard let claimed = seat.player.character,
                  let ability = claimed.supportedAbility else {
                continue
            }
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            if PlayerRoleRule.oncePerGameAbilities.contains(ability), evidence.actorEvents.count > 1 {
                weights[seat.id, default: 0] += 3
            }

            if PlayerRoleRule.deathTriggeredAbilities.contains(ability), !evidence.actorEvents.isEmpty {
                if evidence.firstDeathPhaseIndex == nil {
                    weights[seat.id, default: 0] += 3
                } else if let earliestUse = evidence.actorEvents.map(\.phaseIndex).min(),
                          let firstDeathPhaseIndex = evidence.firstDeathPhaseIndex,
                          earliestUse < firstDeathPhaseIndex {
                    weights[seat.id, default: 0] += 3
                }
            }

            if ability == .professorResurrect, evidence.invalidProfessorTargetName != nil {
                weights[seat.id, default: 0] += 2
            }
        }

        for seat in game.seats where seat.player.character?.supportedAbility == .virginTrigger {
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)
            for event in evidence.actorEvents where event.line.contains("an execution happened") {
                guard let nominator = targetSeat(in: event.line, excluding: seat.id),
                      nominator.player.character?.type == .townsfolk else {
                    continue
                }
                weights[seat.id, default: 0] += 2
                weights[nominator.id, default: 0] += 2
            }
        }

        for seat in game.seats where seat.player.character?.supportedAbility == .slayerShot {
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)
            for event in evidence.actorEvents where event.line.contains("an execution happened") {
                guard let target = targetSeat(in: event.line, excluding: seat.id),
                      let revealed = target.player.revealedCharacter,
                      revealed.type != .demon else {
                    continue
                }
                weights[seat.id, default: 0] += 3
            }
        }

        for seat in game.seats where seat.player.character?.supportedAbility == .fortuneTellerCheck {
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)
            for event in evidence.actorEvents where event.line.contains(" checked ") && event.line.contains(" learned No") {
                let targets = targetSeats(in: event.line, excluding: seat.id)
                guard targets.count == 2,
                      let firstReveal = targets[0].player.revealedCharacter,
                      let secondReveal = targets[1].player.revealedCharacter,
                      firstReveal.type == .demon || secondReveal.type == .demon else {
                    continue
                }
                weights[seat.id, default: 0] += 2
            }
        }

        for seat in game.seats where seat.player.character?.supportedAbility == .seamstressCheck {
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)
            for event in evidence.actorEvents where event.line.contains(" checked ") {
                let targets = targetSeats(in: event.line, excluding: seat.id)
                guard targets.count == 2,
                      let firstReveal = targets[0].player.revealedCharacter,
                      let secondReveal = targets[1].player.revealedCharacter else {
                    continue
                }
                let sameAlignment = firstReveal.type.isGood == secondReveal.type.isGood
                if (event.line.contains(" learned Yes") && !sameAlignment) || (event.line.contains(" learned No") && sameAlignment) {
                    weights[seat.id, default: 0] += 2
                }
            }
        }

        for seat in game.seats where seat.player.character?.supportedAbility == .flowergirlInfo {
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)
            for event in evidence.actorEvents {
                guard let dayPhaseIndex = referencedDayPhaseIndex(for: event) else { continue }
                let demonVoted = nominationEvents
                    .filter { $0.phaseIndex == dayPhaseIndex }
                    .flatMap(\.voters)
                    .contains { $0.player.revealedCharacter?.type == .demon }

                if (event.line.contains(" said: Yes") && !demonVoted) || (event.line.contains(" said: No") && demonVoted) {
                    weights[seat.id, default: 0] += 2
                }
            }
        }

        for seat in game.seats where seat.player.character?.supportedAbility == .townCrierInfo {
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)
            for event in evidence.actorEvents {
                guard let dayPhaseIndex = referencedDayPhaseIndex(for: event) else { continue }
                let minionNominated = nominationEvents
                    .filter { $0.phaseIndex == dayPhaseIndex }
                    .contains { $0.nominator.player.revealedCharacter?.type == .minion }

                if (event.line.contains(" said: Yes") && !minionNominated) || (event.line.contains(" said: No") && minionNominated) {
                    weights[seat.id, default: 0] += 2
                }
            }
        }

        for seat in game.seats {
            if let learned = seat.player.learnedCharacter,
               let revealed = seat.player.revealedCharacter,
               learned.id != revealed.id {
                weights[seat.id, default: 0] += 2
            }
        }

        return weights
    }

    private func duplicateClaimContradictions() -> [ContradictionEntry] {
        let grouped = Dictionary(grouping: game.seats.compactMap { seat -> (Character, Seat)? in
            guard let claimed = seat.player.character else { return nil }
            return (claimed, seat)
        }, by: { $0.0.id })

        return grouped.values.compactMap { entries in
            guard entries.count > 1 else { return nil }

            let character = entries[0].0
            let seats = entries.map(\.1)
            let sortedSeats = seats.sorted { suspicionScore(for: $0) > suspicionScore(for: $1) }
            let ranked = sortedSeats.map { seat in
                L10n.tr("%@ (%lld)", displayName(for: seat), Int64(suspicionScore(for: seat)))
            }.joined(separator: ", ")

            let suspicionText: String
            if let mostSuspicious = sortedSeats.first, suspicionScore(for: mostSuspicious) > 0 {
                suspicionText = L10n.tr("%@ currently looks more suspicious by logical cross-checks.", displayName(for: mostSuspicious))
            } else {
                suspicionText = L10n.tr("The current contradiction data does not clearly separate which of these claimants is more suspicious yet.")
            }

            return ContradictionEntry(
                title: character.localizedName,
                subtitle: L10n.tr("Multiple claimants"),
                message: L10n.tr("Several players are claiming the same role: %@.", seatNames(seats)),
                implication: L10n.tr("Suspicion score from current contradiction checks: %@. %@", ranked, suspicionText),
                severity: .medium
            )
        }
    }

    private func revealContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard let claimed = seat.player.character,
                  let revealed = seat.player.revealedCharacter,
                  claimed.id != revealed.id else {
                return nil
            }

            return ContradictionEntry(
                title: displayName(for: seat),
                subtitle: L10n.tr("Claimed %@ · Revealed %@", claimed.localizedName, revealed.localizedName),
                message: L10n.tr("This seat’s final revealed role does not match the public claim."),
                implication: L10n.tr("If the reveal is trusted, the claim was false. If the reveal is not trusted, the contradiction remains unresolved."),
                severity: .strong
            )
        }
    }

    private func abilityCadenceContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard let claimed = seat.player.character,
                  let ability = claimed.supportedAbility else {
                return nil
            }

            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            if PlayerRoleRule.oncePerGameAbilities.contains(ability), evidence.actorEvents.count > 1 {
                return ContradictionEntry(
                    title: displayName(for: seat),
                    subtitle: L10n.tr("Claimed %@", claimed.localizedName),
                    message: L10n.tr("%@ is effectively a one-use claim here, but the chronicle logs %lld separate claimed uses.", claimed.localizedName, Int64(evidence.actorEvents.count)),
                    implication: L10n.tr("Either the claim is false, the record contains duplicate entries, or another explanation such as role change is missing."),
                    severity: .strong
                )
            }

            if PlayerRoleRule.deathTriggeredAbilities.contains(ability), !evidence.actorEvents.isEmpty {
                guard let firstDeathPhaseIndex = evidence.firstDeathPhaseIndex else {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed %@", claimed.localizedName),
                        message: L10n.tr("%@ normally needs the player to die before acting, but the chronicle shows a claimed use without any recorded death.", claimed.localizedName),
                        implication: L10n.tr("Either the claim is false or the death state in the chronicle is incomplete."),
                        severity: .strong
                    )
                }

                if let earliestUse = evidence.actorEvents.map(\.phaseIndex).min(), earliestUse < firstDeathPhaseIndex {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed %@", claimed.localizedName),
                        message: L10n.tr("The chronicle shows the claimed %@ action before this player’s recorded death.", claimed.localizedName),
                        implication: L10n.tr("Either the claim is false or the timing record is wrong."),
                        severity: .strong
                    )
                }
            }

            if ability == .professorResurrect, let invalidTarget = evidence.invalidProfessorTargetName {
                return ContradictionEntry(
                    title: displayName(for: seat),
                    subtitle: L10n.tr("Claimed %@", claimed.localizedName),
                    message: L10n.tr("The claimed Professor resurrected %@, but that player was not recorded as dead earlier in the chronicle.", invalidTarget),
                    implication: L10n.tr("Either the resurrection story is false or earlier death logging is missing."),
                    severity: .medium
                )
            }

            return nil
        }
    }

    private func virginContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard seat.player.character?.supportedAbility == .virginTrigger else { return nil }
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            for event in evidence.actorEvents where event.line.contains("an execution happened") {
                guard let nominator = targetSeat(in: event.line, excluding: seat.id) else { continue }
                if nominator.player.character?.type == .townsfolk {
                    return ContradictionEntry(
                        title: L10n.tr("%@ and %@", displayName(for: seat), displayName(for: nominator)),
                        subtitle: L10n.tr("Virgin trigger"),
                        message: L10n.tr("The claimed Virgin says %@ was nominated by claimed Townsfolk %@ and an execution happened.", displayName(for: seat), displayName(for: nominator)),
                        implication: L10n.tr("If the Virgin ability really triggered, at least one of those public claims is false."),
                        severity: .strong
                    )
                }
            }

            return nil
        }
    }

    private func slayerContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard seat.player.character?.supportedAbility == .slayerShot else { return nil }
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            for event in evidence.actorEvents where event.line.contains("an execution happened") {
                guard let target = targetSeat(in: event.line, excluding: seat.id),
                      let revealed = target.player.revealedCharacter,
                      revealed.type != .demon else {
                    continue
                }

                return ContradictionEntry(
                    title: L10n.tr("%@ shot %@", displayName(for: seat), displayName(for: target)),
                    subtitle: L10n.tr("Slayer execution"),
                    message: L10n.tr("The claimed Slayer says the shot caused an execution, but %@ was finally revealed as %@, not a Demon.", displayName(for: target), revealed.localizedName),
                    implication: L10n.tr("If the final reveal is trusted, either the Slayer story is false or the final reveal is wrong."),
                    severity: .strong
                )
            }

            return nil
        }
    }

    private func fortuneTellerContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard seat.player.character?.supportedAbility == .fortuneTellerCheck else { return nil }
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            for event in evidence.actorEvents where event.line.contains(" checked ") && event.line.contains(" learned No") {
                let targets = targetSeats(in: event.line, excluding: seat.id)
                guard targets.count == 2,
                      let firstReveal = targets[0].player.revealedCharacter,
                      let secondReveal = targets[1].player.revealedCharacter,
                      firstReveal.type == .demon || secondReveal.type == .demon else {
                    continue
                }

                return ContradictionEntry(
                    title: displayName(for: seat),
                    subtitle: L10n.tr("Claimed Fortune Teller"),
                    message: L10n.tr("The claimed Fortune Teller recorded a No on %@ and %@, but one of those players was finally revealed as a Demon.", displayName(for: targets[0]), displayName(for: targets[1])),
                    implication: L10n.tr("This can still be explained by poisoning, drunkenness, or a bad final reveal, but under a straightforward reading it is a contradiction."),
                    severity: .medium
                )
            }

            return nil
        }
    }

    private func seamstressContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard seat.player.character?.supportedAbility == .seamstressCheck else { return nil }
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            for event in evidence.actorEvents where event.line.contains(" checked ") {
                let targets = targetSeats(in: event.line, excluding: seat.id)
                guard targets.count == 2,
                      let firstReveal = targets[0].player.revealedCharacter,
                      let secondReveal = targets[1].player.revealedCharacter else {
                    continue
                }

                let sameAlignment = firstReveal.type.isGood == secondReveal.type.isGood

                if event.line.contains(" learned Yes"), !sameAlignment {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed Seamstress"),
                        message: L10n.tr("The claimed Seamstress said %@ and %@ were the same alignment, but the final reveals put them on opposite teams.", displayName(for: targets[0]), displayName(for: targets[1])),
                        implication: L10n.tr("Either the seamstress information is false, the final reveal is wrong, or some other record in the chain is missing."),
                        severity: .medium
                    )
                }

                if event.line.contains(" learned No"), sameAlignment {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed Seamstress"),
                        message: L10n.tr("The claimed Seamstress said %@ and %@ were different alignments, but the final reveals put them on the same team.", displayName(for: targets[0]), displayName(for: targets[1])),
                        implication: L10n.tr("Either the seamstress information is false, the final reveal is wrong, or some other record in the chain is missing."),
                        severity: .medium
                    )
                }
            }

            return nil
        }
    }

    private func flowergirlContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard seat.player.character?.supportedAbility == .flowergirlInfo else { return nil }
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            for event in evidence.actorEvents {
                guard let dayPhaseIndex = referencedDayPhaseIndex(for: event) else { continue }
                guard let nominationPhaseIndex = nominationPhaseIndex(for: dayPhaseIndex) else { continue }
                let dayTitle = game.phaseTimeline()[dayPhaseIndex].title
                let demonVoters = nominationEvents
                    .filter { $0.phaseIndex == nominationPhaseIndex }
                    .flatMap(\.voters)
                    .filter { $0.player.revealedCharacter?.type == .demon }

                if event.line.contains(" said: Yes"), demonVoters.isEmpty {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed Flowergirl"),
                        message: L10n.tr("The claimed Flowergirl said the Demon voted on %@, but no recorded voter from that day was finally revealed as a Demon.", dayTitle),
                        implication: L10n.tr("Either the Flowergirl information is false, the nomination/vote log is incomplete, or the final reveal is wrong."),
                        severity: .medium
                    )
                }

                if event.line.contains(" said: No"), !demonVoters.isEmpty {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed Flowergirl"),
                        message: L10n.tr("The claimed Flowergirl said the Demon did not vote on %@, but %@ is recorded voting and was finally revealed as a Demon.", dayTitle, displayName(for: demonVoters[0])),
                        implication: L10n.tr("Either the Flowergirl information is false, the nomination/vote log is incomplete, or the final reveal is wrong."),
                        severity: .medium
                    )
                }
            }

            return nil
        }
    }

    private func townCrierContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard seat.player.character?.supportedAbility == .townCrierInfo else { return nil }
            let evidence = PlayerChronicleEvidence(game: game, seat: seat)

            for event in evidence.actorEvents {
                guard let dayPhaseIndex = referencedDayPhaseIndex(for: event) else { continue }
                guard let nominationPhaseIndex = nominationPhaseIndex(for: dayPhaseIndex) else { continue }
                let dayTitle = game.phaseTimeline()[dayPhaseIndex].title
                let minionNominators = nominationEvents
                    .filter { $0.phaseIndex == nominationPhaseIndex }
                    .map(\.nominator)
                    .filter { $0.player.revealedCharacter?.type == .minion }

                if event.line.contains(" said: Yes"), minionNominators.isEmpty {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed Town Crier"),
                        message: L10n.tr("The claimed Town Crier said a Minion nominated on %@, but no recorded nominator from that day was finally revealed as a Minion.", dayTitle),
                        implication: L10n.tr("Either the Town Crier information is false, the nomination log is incomplete, or the final reveal is wrong."),
                        severity: .medium
                    )
                }

                if event.line.contains(" said: No"), !minionNominators.isEmpty {
                    return ContradictionEntry(
                        title: displayName(for: seat),
                        subtitle: L10n.tr("Claimed Town Crier"),
                        message: L10n.tr("The claimed Town Crier said no Minion nominated on %@, but %@ is recorded nominating and was finally revealed as a Minion.", dayTitle, displayName(for: minionNominators[0])),
                        implication: L10n.tr("Either the Town Crier information is false, the nomination log is incomplete, or the final reveal is wrong."),
                        severity: .medium
                    )
                }
            }

            return nil
        }
    }

    private func learnedInfoContradictions() -> [ContradictionEntry] {
        game.seats.compactMap { seat in
            guard let claimedAbility = seat.player.character?.supportedAbility,
                  [.undertakerInfo, .ravenkeeperCheck, .grandmotherInfo].contains(claimedAbility) else { return nil }

            let mismatchedTargets = game.seats.compactMap { targetSeat -> String? in
                guard let learned = targetSeat.player.learnedCharacter,
                      let revealed = targetSeat.player.revealedCharacter,
                      learned.id != revealed.id else {
                    return nil
                }
                return L10n.tr("%@ learned as %@ but revealed as %@", displayName(for: targetSeat), learned.localizedName, revealed.localizedName)
            }

            guard !mismatchedTargets.isEmpty else { return nil }

            let subtitle: String
            switch claimedAbility {
            case .undertakerInfo:
                subtitle = L10n.tr("Claimed Undertaker")
            case .ravenkeeperCheck:
                subtitle = L10n.tr("Claimed Ravenkeeper")
            case .grandmotherInfo:
                subtitle = L10n.tr("Claimed Grandmother")
            default:
                subtitle = ""
            }

            return ContradictionEntry(
                title: displayName(for: seat),
                subtitle: subtitle,
                message: mismatchedTargets.joined(separator: " · "),
                implication: L10n.tr("At least one of the learned information, the final reveal, or the surrounding drunkenness/poisoning story is wrong."),
                severity: .medium
            )
        }
    }

    private func displayName(for seat: Seat) -> String {
        let trimmed = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.tr("Unnamed player") : trimmed
    }

    private func suspicionScore(for seat: Seat) -> Int {
        contradictionWeightsBySeatID[seat.id, default: 0]
    }

    private func targetSeat(in line: String, excluding seatID: UUID) -> Seat? {
        namedSeats.first { seat in
            guard seat.id != seatID else { return false }
            let name = displayName(for: seat)
            return line.contains(name)
        }
    }

    private func targetSeats(in line: String, excluding seatID: UUID) -> [Seat] {
        namedSeats.filter { seat in
            guard seat.id != seatID else { return false }
            let name = displayName(for: seat)
            return line.contains(name)
        }
    }

    private func referencedDayPhaseIndex(for event: PhaseEntry) -> Int? {
        switch event.phase {
        case .firstNight:
            return nil
        case .day:
            return event.phaseIndex
        case .nomination:
            return event.phaseIndex - 1
        case .night:
            let priorDay = event.phaseIndex - 2
            return priorDay >= 0 ? priorDay : nil
        }
    }

    private func nominationPhaseIndex(for dayPhaseIndex: Int) -> Int? {
        let nominationIndex = dayPhaseIndex + 1
        guard game.phaseTimeline().indices.contains(nominationIndex) else {
            return nil
        }

        if case .nomination = game.phaseTimeline()[nominationIndex].phase {
            return nominationIndex
        }

        return nil
    }

    private func parseNominationEvent(line: String, phaseIndex: Int) -> NominationEvent? {
        guard line.contains(" nominated "), line.contains(". Votes: ") else {
            return nil
        }

        guard let nominator = namedSeats.first(where: { line.hasPrefix("\(displayName(for: $0)) nominated ") }) else {
            return nil
        }

        let remaining = line.dropFirst(displayName(for: nominator).count + " nominated ".count)
        guard let nominee = namedSeats.first(where: { remaining.contains("\(displayName(for: $0)). Votes: ") }) else {
            return nil
        }

        let votersSection = line.components(separatedBy: ". Votes: ").last?.replacingOccurrences(of: ".", with: "") ?? ""
        let voters = namedSeats.filter { seat in
            votersSection.contains(displayName(for: seat))
        }

        return NominationEvent(phaseIndex: phaseIndex, nominator: nominator, nominee: nominee, voters: voters)
    }

    private func seatNames(_ seats: [Seat]) -> String {
        let names = seats.map(displayName(for:))
        switch names.count {
        case 0:
            return L10n.tr("no-one")
        case 1:
            return names[0]
        case 2:
            return L10n.tr("%@ and %@", names[0], names[1])
        default:
            return L10n.tr("%@, and %@", names.dropLast().joined(separator: ", "), names.last ?? "")
        }
    }
}

private extension CharacterType {
    var isGood: Bool {
        self == .townsfolk || self == .outsider
    }
}

private struct NominationEvent {
    let phaseIndex: Int
    let nominator: Seat
    let nominee: Seat
    let voters: [Seat]
}

private struct PlayerRoleRule {
    static let nightlyAbilities: Set<SupportedAbility> = [
        .empathInfo, .fortuneTellerCheck, .undertakerInfo, .monkProtect,
        .poisonerPoison, .impKill, .sailorChoose, .chambermaidCheck,
        .exorcistBlock, .innkeeperProtect, .gossipStatement, .devilsAdvocateProtect,
        .pukkaPoison, .shabalothKill, .poAttack, .flowergirlInfo, .townCrierInfo,
        .oracleInfo, .mathematicianInfo, .snakeCharmerCheck, .witchCurse,
        .fangGuAttack, .vigormortisAttack, .noDashiiAttack, .vortoxAttack
    ]
    
    static let oncePerGameAbilities: Set<SupportedAbility> = [
        .slayerShot, .courtierChooseCharacter, .professorResurrect,
        .artistQuestion, .jugglerInfo, .seamstressCheck, .philosopherChoose
    ]
    
    static let deathTriggeredAbilities: Set<SupportedAbility> = [
        .ravenkeeperCheck
    ]
    
    static let attackAbilities: Set<SupportedAbility> = [
        .impKill, .godfatherKill, .assassinKill, .zombuulKill, .shabalothKill,
        .poAttack, .fangGuAttack, .vigormortisAttack, .noDashiiAttack, .vortoxAttack
    ]
    
    static let protectionAbilities: Set<SupportedAbility> = [
        .monkProtect, .innkeeperProtect, .devilsAdvocateProtect
    ]
}

private struct PlayerChronicleEvidence {
    let game: Game
    let seat: Seat
    
    private var playerName: String {
        let trimmed = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.tr("Unnamed player") : trimmed
    }
    
    private var phaseEntries: [PhaseEntry] {
        game.phaseTimeline().enumerated().flatMap { index, entry in
            let lines = entry.note
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if lines.isEmpty {
                return [PhaseEntry(phaseIndex: index, phase: entry.phase, phaseTitle: entry.title, line: "")]
            }
            
            return lines.map { line in
                PhaseEntry(phaseIndex: index, phase: entry.phase, phaseTitle: entry.title, line: line)
            }
        }
    }
    
    var actorEvents: [PhaseEntry] {
        phaseEntries.filter { $0.line.hasPrefix("\(playerName), the claimed ") }
    }
    
    var nightActionCount: Int {
        actorEvents.filter(\.isNightPhase).count
    }
    
    var firstDeathPhaseIndex: Int? {
        phaseEntries.first(where: { $0.line == "\(playerName) died." })?.phaseIndex
    }
    
    var deathContext: String? {
        guard let death = phaseEntries.first(where: { $0.line == "\(playerName) died." }) else {
            return nil
        }
        return L10n.tr("their death was recorded during %@", death.phaseTitle)
    }
    
    var eligibleNightCount: Int {
        var alive = true
        var count = 0
        
        for (index, entry) in game.phaseTimeline().enumerated() {
            let isNightPhase: Bool
            switch entry.phase {
            case .firstNight, .night:
                isNightPhase = true
            case .day, .nomination:
                isNightPhase = false
            }

            if isNightPhase {
                if alive {
                    count += 1
                }
            }
            
            let lines = phaseEntries
                .filter { $0.phaseIndex == index }
                .map(\.line)
            
            for line in lines {
                if line == "\(playerName) died." {
                    alive = false
                } else if line == "\(playerName) was revived." {
                    alive = true
                }
            }
        }
        
        return count
    }
    
    var hasInvalidProfessorResurrection: Bool {
        invalidProfessorTargetName != nil
    }
    
    var invalidProfessorTargetName: String? {
        for event in actorEvents where event.line.contains(" resurrected ") {
            let targets = namedTargets(in: event.line)
            for target in targets {
                if !wasDeadBefore(name: target, phaseIndex: event.phaseIndex) {
                    return target
                }
            }
        }
        return nil
    }
    
    var protectedTargetsThatLaterDied: [String] {
        actorEvents
            .filter { $0.line.contains(" protected ") }
            .flatMap { event in
                namedTargets(in: event.line).filter { target in
                    diedAfter(name: target, phaseIndex: event.phaseIndex)
                }
            }
    }
    
    var attackTargetsWithNoLaterDeath: [String] {
        actorEvents
            .filter { $0.line.contains(" attacked ") || $0.line.contains(" shot ") }
            .flatMap { event in
                namedTargets(in: event.line).filter { target in
                    !diedAfter(name: target, phaseIndex: event.phaseIndex)
                }
            }
    }
    
    var targetedByAttacksAfterClaims: Int {
        phaseEntries.filter { entry in
            !entry.line.hasPrefix("\(playerName), the claimed ")
            && (entry.line.contains(" attacked \(playerName)") || entry.line.contains(" poisoned \(playerName)") || entry.line.contains(" protected \(playerName)") || entry.line.contains(" cursed \(playerName)") || entry.line.contains(" chose \(playerName)"))
        }.count
    }
    
    private func namedTargets(in line: String) -> [String] {
        game.seats.compactMap { seat in
            let name = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, name != playerName else { return nil }
            return line.contains(name) ? name : nil
        }
    }
    
    private func wasDeadBefore(name: String, phaseIndex: Int) -> Bool {
        phaseEntries.contains { entry in
            entry.phaseIndex < phaseIndex && entry.line == "\(name) died."
        }
    }
    
    private func diedAfter(name: String, phaseIndex: Int) -> Bool {
        phaseEntries.contains { entry in
            entry.phaseIndex > phaseIndex && entry.line == "\(name) died."
        }
    }
}

private struct PhaseEntry {
    let phaseIndex: Int
    let phase: Game.TurnPhase
    let phaseTitle: String
    let line: String
    
    var isNightPhase: Bool {
        if phase == .firstNight {
            return true
        }

        if case .night = phase {
            return true
        }

        return false
    }
}
