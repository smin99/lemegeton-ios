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
        case resetBoard, cannotStartGame, cannotEndGame, completeGame, resetAfterCompleteGame
        var id: Int { hashValue }
        
        var title: String {
            switch self {
            case .resetBoard:
                "Reset the Grimoire?"
            case .cannotStartGame:
                "Cannot begin the chronicle"
            case .cannotEndGame,
                    .completeGame:
                "Finish the game?"
            case .resetAfterCompleteGame:
                "Restart with same board?"
            }
        }
        
        var message: String {
            switch self {
            case .resetBoard:
                "This will clear all player seats and roles. This action cannot be undone."
            case .cannotStartGame:
                "Select at least as many characters as there are seats before starting the game."
            case .cannotEndGame:
                "The game has not ended. Please record all player's characters and update their death state."
            case .completeGame:
                "This will end the game. Ended game cannot be started again."
            case .resetAfterCompleteGame:
                "Restart will keep the current board setup including player name and seats."
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
                            SeatsCanvas(boardVM: boardVM)
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

                                } else {
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
                                    Label("Player Logic", systemImage: "wand.and.stars")
                                }
                                .buttonStyle(GrimoireButtonStyle())
                                
                                Divider()
                                    .background(Color(.themeTertiary))

                                // Finish the game
                                Button {
                                    activeAlert = boardVM.canEndGame() ? .completeGame : .cannotEndGame
                                } label: {
                                        Label("Final Verdict", systemImage: "flag.checkered")
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
                CharacterListView(titleText: "Add characters in game", onComplete: { characters in
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
                    buttonTitle: "Save Note",
                    placeholder: "Write what happened during this phase",
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
                    Text(boardVM.currentGame.gameState == .set_up ? "Set up the Grimoire" : "\(boardVM.currentGame.numAliveCharacters()) Alive")
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
                    if boardVM.currentGame.gameState != .set_up {
                        Button {
                            boardVM.advancePhase()
                        } label: {
                            Image(systemName: "moonphase.waning.crescent")
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
                case .completeGame:
                    primaryButton = .default(Text("Complete")) {
                        activeAlert = .resetAfterCompleteGame
                    }
                    secondaryButton = .cancel(Text("Cancel"))
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
}

private struct PlayerExplanationView: View {
    let game: Game
    
    private var sortedSeats: [Seat] {
        game.seats.sorted { lhs, rhs in
            let leftName = lhs.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let rightName = rhs.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if leftName.isEmpty != rightName.isEmpty {
                return !leftName.isEmpty
            }
            return leftName.localizedCaseInsensitiveCompare(rightName) == .orderedAscending
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("These suggestions are heuristics, not a solver. They use the current script, each player’s claim, death state, notes, and recorded ability usage to build plausible story explanations.")
                        .grimoireStyle(size: 15, italic: false)
                        .foregroundStyle(.themePrimary.opacity(0.88))
                    
                    ForEach(sortedSeats) { seat in
                        let explanation = PlayerExplanation(seat: seat, game: game)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(explanation.playerName)
                                        .grimoireBoldStyle(size: 18)
                                        .foregroundStyle(.themeOnSurface)
                                    Text(explanation.claimSummary)
                                        .grimoireStyle(size: 14, italic: false)
                                        .foregroundStyle(.themePrimary)
                                }
                                Spacer()
                                if seat.player.isDead {
                                    Text("Dead")
                                        .font(.caption.bold())
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            Text(explanation.primaryExplanation)
                                .grimoireStyle(size: 15, italic: false)
                                .foregroundStyle(.themePrimary.opacity(0.88))
                            
                            if let support = explanation.supportingDetail {
                                Text(support)
                                    .font(.caption)
                                    .foregroundStyle(.themeOnSurface.opacity(0.82))
                            }
                            
                            if let alternatives = explanation.alternativeRolesText {
                                Text(alternatives)
                                    .font(.caption)
                                    .foregroundStyle(.themeOnSurface.opacity(0.72))
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
                .padding(16)
            }
            .background(Color.themeSurface.ignoresSafeArea())
            .navigationTitle("Player Logic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.themeSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

private struct PlayerExplanation {
    let seat: Seat
    let game: Game
    
    private var evidence: PlayerChronicleEvidence {
        PlayerChronicleEvidence(game: game, seat: seat)
    }
    
    var playerName: String {
        let trimmed = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unnamed player" : trimmed
    }
    
    var claimSummary: String {
        guard let claimed = seat.player.character else {
            return "No claimed role recorded"
        }
        if evidence.actorEvents.isEmpty {
            return "Claiming \(claimed.name)"
        }
        return "Claiming \(claimed.name) · \(evidence.actorEvents.count) logged action\(evidence.actorEvents.count == 1 ? "" : "s")"
    }
    
    var primaryExplanation: String {
        guard let claimed = seat.player.character else {
            if let deathContext = evidence.deathContext {
                return "This player has no recorded claim. The chronicle shows \(deathContext), which still fits a hidden good role, an Outsider avoiding attention, or an evil player who never had to settle on a public bluff."
            }
            if seat.player.isDead {
                return "This player has no recorded claim and is already dead, which can still fit a hidden information role, an Outsider staying quiet, or an evil player who never needed to publicly settle on a bluff."
            }
            return "This player has no recorded claim yet. In Blood on the Clocktower, that can still make sense for cautious information roles, Outsiders who prefer to hide, or evil players delaying a bluff."
        }
        
        if let contradiction = contradictionSummary(for: claimed) {
            return contradiction
        }
        
        if let support = strongSupportSummary(for: claimed) {
            return support
        }
        
        switch claimed.type {
        case .townsfolk:
            return "A Townsfolk explanation is still possible, but it currently relies more on social read than on a fully consistent action trail in the chronicle."
        case .outsider:
            return "An Outsider explanation remains plausible because Outsider stories often look messy or incomplete, but the chronicle does not yet strongly anchor this player to one specific outcome."
        case .minion:
            return "A Minion explanation stays open if this claim looks more like pressure or misinformation than a truthful public role, especially if the action trail is thin."
        case .demon:
            return "A Demon explanation is only moderately supported right now. It becomes stronger if the kill pattern, pressure, and bluff line keep pointing back to this seat."
        }
    }
    
    var supportingDetail: String? {
        var details: [String] = []
        
        if let claimed = seat.player.character {
            if seat.player.isCharacterConfirmed {
                details.append("This seat is already marked confirmed as \(claimed.name).")
            }
            
            if let cadence = cadenceDetail(for: claimed) {
                details.append(cadence)
            }
            
            if let targetCrossCheck = targetCrossCheckDetail(for: claimed) {
                details.append(targetCrossCheck)
            }
            
            if claimed.supportedAbility != nil, seat.player.activeAbilityTargetSeatID != nil, evidence.actorEvents.isEmpty {
                details.append("A target is stored on this seat, but the chronicle does not yet include a matching public action record.")
            }
        }
        
        if !seat.player.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            details.append("There is a private note on this player, which may support or weaken the claim depending on what you recorded.")
        }
        
        if let deathContext = evidence.deathContext {
            details.append("Chronicle timing: \(deathContext).")
        }
        
        if seat.player.isDead, let claimed = seat.player.character {
            switch claimed.type {
            case .townsfolk, .outsider:
                details.append("Death does not hurt this explanation by itself; dangerous good roles and harmful Outsiders often die early.")
            case .minion, .demon:
                details.append("Death could still fit a frame job, a spent evil role, or a bluff collapsing under pressure rather than proving the evil claim.")
            }
        }
        
        if evidence.targetedByAttacksAfterClaims > 0 {
            details.append("Other players' logged actions point at this seat \(evidence.targetedByAttacksAfterClaims) time\(evidence.targetedByAttacksAfterClaims == 1 ? "" : "s"), which can matter when evaluating whether this player was attracting night attention.")
        }
        
        return details.isEmpty ? nil : details.joined(separator: " ")
    }
    
    var alternativeRolesText: String? {
        guard let claimed = seat.player.character else { return nil }
        
        let alternatives = game.inGameCharacters
            .filter { $0.type == claimed.type && $0.id != claimed.id }
            .prefix(3)
            .map(\.name)
        
        guard !alternatives.isEmpty else { return nil }
        return "Other same-type explanations in this script: \(alternatives.joined(separator: ", "))."
    }
    
    private func contradictionSummary(for claimed: Character) -> String? {
        guard let ability = claimed.supportedAbility else { return nil }
        
        if PlayerRoleRule.oncePerGameAbilities.contains(ability), evidence.actorEvents.count > 1 {
            return "This explanation is weak because \(claimed.name) is effectively a one-use claim here, but the chronicle logs \(evidence.actorEvents.count) separate claimed uses."
        }
        
        if PlayerRoleRule.deathTriggeredAbilities.contains(ability), !evidence.actorEvents.isEmpty {
            guard let firstDeathPhaseIndex = evidence.firstDeathPhaseIndex else {
                return "This explanation is weak because \(claimed.name) normally needs the player to die before acting, but the chronicle shows a claimed use without any recorded death."
            }
            
            if let earliestUse = evidence.actorEvents.map(\.phaseIndex).min(), earliestUse < firstDeathPhaseIndex {
                return "This explanation is weak because the chronicle shows the claimed \(claimed.name) action before this player’s recorded death."
            }
        }
        
        if ability == .professorResurrect, evidence.hasInvalidProfessorResurrection {
            return "This explanation is weak because the claimed Professor resurrected a player who was not recorded as dead earlier in the chronicle."
        }
        
        return nil
    }
    
    private func strongSupportSummary(for claimed: Character) -> String? {
        guard let ability = claimed.supportedAbility else {
            if claimed.type == .outsider {
                return "An Outsider explanation is logical here because Outsider stories often stay incomplete, and the absence of a strong action trail is not itself suspicious."
            }
            return nil
        }
        
        if PlayerRoleRule.nightlyAbilities.contains(ability),
           evidence.eligibleNightCount >= 2,
           evidence.nightActionCount >= max(1, evidence.eligibleNightCount - 1) {
            return "This explanation is fairly strong because the chronicle shows a repeated \(claimed.name) action pattern across the nights this player stayed alive."
        }
        
        if PlayerRoleRule.oncePerGameAbilities.contains(ability), evidence.actorEvents.count == 1 {
            return "This explanation is fairly strong because the chronicle shows a single claimed \(claimed.name) use, which matches the expected once-per-game pattern."
        }
        
        if PlayerRoleRule.deathTriggeredAbilities.contains(ability),
           evidence.actorEvents.count == 1,
           let firstDeathPhaseIndex = evidence.firstDeathPhaseIndex,
           let usePhaseIndex = evidence.actorEvents.first?.phaseIndex,
           usePhaseIndex >= firstDeathPhaseIndex {
            return "This explanation is fairly strong because the chronicle shows the claimed \(claimed.name) action only after this player’s recorded death."
        }
        
        if ability == .monkProtect || ability == .innkeeperProtect || ability == .devilsAdvocateProtect,
           evidence.actorEvents.count > 0 {
            return "This explanation is reasonably logical because the chronicle contains a concrete protection story for this player instead of only a bare role claim."
        }
        
        return nil
    }
    
    private func cadenceDetail(for claimed: Character) -> String? {
        guard let ability = claimed.supportedAbility else { return nil }
        
        if PlayerRoleRule.nightlyAbilities.contains(ability), evidence.eligibleNightCount >= 2 {
            if evidence.nightActionCount == 0 {
                return "Chronicle cross-check: this claim usually wants recurring night entries, but none were logged across \(evidence.eligibleNightCount) eligible night\(evidence.eligibleNightCount == 1 ? "" : "s")."
            }
            if evidence.nightActionCount < evidence.eligibleNightCount - 1 {
                return "Chronicle cross-check: only \(evidence.nightActionCount) night action\(evidence.nightActionCount == 1 ? "" : "s") were logged across \(evidence.eligibleNightCount) eligible night\(evidence.eligibleNightCount == 1 ? "" : "s"), so the action trail is incomplete."
            }
        }
        
        if PlayerRoleRule.oncePerGameAbilities.contains(ability), evidence.actorEvents.isEmpty {
            return "Chronicle cross-check: there is not yet any logged use for this one-shot claim, so it remains mostly social rather than mechanical."
        }
        
        return nil
    }
    
    private func targetCrossCheckDetail(for claimed: Character) -> String? {
        guard let ability = claimed.supportedAbility else { return nil }
        
        if ability == .professorResurrect, let invalidTarget = evidence.invalidProfessorTargetName {
            return "Target cross-check: the claimed resurrection of \(invalidTarget) does not line up with an earlier recorded death."
        }
        
        if PlayerRoleRule.protectionAbilities.contains(ability), evidence.protectedTargetsThatLaterDied.count > 0 {
            let targets = evidence.protectedTargetsThatLaterDied.joined(separator: ", ")
            return "Target cross-check: protected target\(evidence.protectedTargetsThatLaterDied.count == 1 ? "" : "s") \(targets) later died in the chronicle, so this story needs poisoning, drunkenness, a bypass, or a false claim to stay coherent."
        }
        
        if PlayerRoleRule.attackAbilities.contains(ability), evidence.attackTargetsWithNoLaterDeath.count > 0 {
            let targets = evidence.attackTargetsWithNoLaterDeath.prefix(2).joined(separator: ", ")
            return "Target cross-check: claimed attack target\(evidence.attackTargetsWithNoLaterDeath.count == 1 ? "" : "s") \(targets) have no later recorded death, which does not disprove the claim but does weaken a straightforward kill story."
        }
        
        return nil
    }
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
        return trimmed.isEmpty ? "Unnamed player" : trimmed
    }
    
    private var phaseEntries: [PhaseEntry] {
        game.phaseTimeline().enumerated().flatMap { index, entry in
            let lines = entry.note
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if lines.isEmpty {
                return [PhaseEntry(phaseIndex: index, phaseTitle: entry.title, line: "")]
            }
            
            return lines.map { line in
                PhaseEntry(phaseIndex: index, phaseTitle: entry.title, line: line)
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
        return "their death was recorded during \(death.phaseTitle)"
    }
    
    var eligibleNightCount: Int {
        var alive = true
        var count = 0
        
        for index in game.phaseTimeline().indices {
            let title = game.phaseTimeline()[index].title
            if title == "First Night" || title.hasPrefix("Night ") {
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
    let phaseTitle: String
    let line: String
    
    var isNightPhase: Bool {
        phaseTitle == "First Night" || phaseTitle.hasPrefix("Night ")
    }
}
