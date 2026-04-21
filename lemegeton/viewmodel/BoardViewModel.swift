//
//  BoardViewModel.swift
//  lemegeton
//
//  Created by Min Hwang on 10/5/25.
//

import Foundation
import Combine
import CoreGraphics

enum NominationSelectionMode {
    case nominator
    case nominee
    case voters

    var title: String {
        switch self {
        case .nominator:
            return L10n.tr("Choose Nominator")
        case .nominee:
            return L10n.tr("Choose Nominee")
        case .voters:
            return L10n.tr("Mark Voters")
        }
    }

    var instruction: String {
        switch self {
        case .nominator:
            return L10n.tr("Tap the player who made the nomination.")
        case .nominee:
            return L10n.tr("Tap the player who was nominated.")
        case .voters:
            return L10n.tr("Tap each player who voted. Tap again to remove a vote.")
        }
    }
}

class BoardViewModel: ObservableObject {
    
    private let repo = GameRepo.shared
    private let maxUndoCount = 30
    
    @Published var currentGame: Game
    @Published var pastGames: [Game]
    @Published var allCharacters: [Character]
    @Published var nominationSelectionMode: NominationSelectionMode = .nominator
    @Published var nominationNominatorSeatID: UUID?
    @Published var nominationNomineeSeatID: UUID?
    @Published var nominationVoterSeatIDs: Set<UUID> = []
    
    private var undoStack: [Game] = []
    
    private let characterSaveFileName = "characterState.json"
    private let saveFileName = "gameState.json"
    // The file URL for the document directory
    private var saveURL: URL {
        // Use the documents directory, which is appropriate for user-generated or critical data.
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot access documents directory.")
        }
        return documentDirectory
    }
    
    init() {
        // Sync from GameRepo if available
        repo.loadCurrentGame()
        
        // Initialize repo-backed game if none exists
        if repo.currentGame == nil {
            repo.startNewGame()
            currentGame = repo.currentGame!
        } else {
            currentGame = repo.currentGame!
        }
        pastGames = repo.pastGames
        allCharacters = CharacterService.availableCharacters
    }
    
    
    // MARK: - Dropdown Menu Actions
    
    /** Set up character  */
    func setUpCharacters(characters: [Character]) {
        currentGame.inGameCharacters = characters
        saveState()
    }
    
    func updateSetup() {
        currentGame.gameState = currentGame.gameState == .set_up ? .in_game : .set_up
        undoStack.removeAll()
        resetNominationDraft()
        if currentGame.gameState == .in_game {
            currentGame.startChronicleIfNeeded()
        }
        repo.saveCurrentGame(currentGame: currentGame)
    }
    
    func canStartGame() -> Bool {
        let seatCount = currentGame.seats.count
        return seatCount > 0 && currentGame.inGameCharacters.count >= seatCount
    }
    
    
    // Reset the entire board
    func resetBoard() {
        repo.startNewGame()
        currentGame = repo.currentGame!
        undoStack.removeAll()
        resetNominationDraft()
    }
    
    func canEndGame() -> Bool {
        return currentGame.isAllCharacterConfirmed() &&
        (currentGame.didAllDemonDie()
         || currentGame.numAliveCharacters() < Game.FINAL_ALIVE_CHARACTER
         || currentGame.isOnlyEvilAlive())
    }

    func beginRoleReveal() {
        saveUndoSnapshotIfNeeded()
        currentGame.gameState = .role_reveal
        resetNominationDraft()
        saveState()
    }

    func canCompleteGameAfterReveal() -> Bool {
        currentGame.isAllRevealedCharacterRecorded()
    }
    
    func endGame(resetGame: Bool) {
        undoStack.removeAll()
        currentGame.gameState = .game_over
        resetNominationDraft()
        repo.saveCurrentGame(currentGame: currentGame)
        repo.endCurrentGame()
        refreshPastGames()
        
        if (resetGame) {
            repo.startNewGame()
            currentGame = repo.currentGame!
        } else {
            currentGame.clearGameState()
        }
    }
    
    // MARK: - Set Up Board Actions
    
    func addSeat(at point: CGPoint) {
        currentGame.seats.append(Seat(player: Player(name: "", inGameCharacters: currentGame.inGameCharacters), x: point.x, y: point.y))
        saveState()
    }
    
    func removeSeat(seat: Seat) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            currentGame.seats.remove(at: idx)
            saveState()
        }
    }
    
    func deathUpon(seat: Seat) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            saveUndoSnapshotIfNeeded()
            currentGame.seats[idx].player.isDead = !currentGame.seats[idx].player.isDead
            let playerName = currentGame.seats[idx].player.name.isEmpty ? L10n.tr("Unnamed player") : currentGame.seats[idx].player.name
            let event = currentGame.seats[idx].player.isDead
            ? L10n.tr("%@ died.", playerName)
            : L10n.tr("%@ was revived.", playerName)
            currentGame.appendCurrentPhaseEvent(event)
            saveState()
        }
    }
    
    func editSeatName(seat: Seat, newName: String) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            saveUndoSnapshotIfNeeded()
            currentGame.seats[idx].player.editName(newName: newName)
            saveState()
        }
    }
    
    func updatePlayerNote(seat: Seat, note: String) {
        if let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) {
            saveUndoSnapshotIfNeeded()
            currentGame.seats[idx].player.updateNote(newNote: note)
            saveState()
        }
    }

    func updateClaimedRole(seat: Seat, character: Character?) {
        guard let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) else {
            return
        }
        
        saveUndoSnapshotIfNeeded()

        let playerName = currentGame.seats[idx].player.name.isEmpty ? L10n.tr("Unnamed player") : currentGame.seats[idx].player.name
        let previousClaim = currentGame.seats[idx].player.character

        currentGame.seats[idx].player.character = character
        currentGame.seats[idx].player.possibleCharacters = character.map { [$0] } ?? []
        currentGame.seats[idx].player.activeAbilityTargetSeatID = nil

        if let character {
            if let previousClaim, previousClaim.id != character.id {
                currentGame.appendCurrentPhaseEvent(L10n.tr("%@ changed their claimed role from %@ to %@.", playerName, previousClaim.localizedName, character.localizedName))
            } else if previousClaim == nil {
                currentGame.appendCurrentPhaseEvent(L10n.tr("%@ claimed %@.", playerName, character.localizedName))
            }
        }

        saveState()
    }

    func updateRevealedRole(seat: Seat, character: Character?) {
        guard let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) else {
            return
        }

        saveUndoSnapshotIfNeeded()
        currentGame.seats[idx].player.revealedCharacter = character
        saveState()
    }

    func updateLearnedRole(seat: Seat, character: Character?) {
        guard let idx = currentGame.seats.firstIndex(where: { $0.id == seat.id }) else {
            return
        }

        currentGame.seats[idx].player.learnedCharacter = character
        saveState()
    }

    func updateAbilityTarget(for seat: Seat, targetSeat: Seat?) {
        guard let sourceIndex = currentGame.seats.firstIndex(where: { $0.id == seat.id }),
              let character = currentGame.seats[sourceIndex].player.character,
              let ability = character.supportedAbility else {
            return
        }
        
        saveUndoSnapshotIfNeeded()

        currentGame.seats[sourceIndex].player.activeAbilityTargetSeatID = targetSeat?.id

        switch ability {
        case .monkProtect:
            if let targetSeat {
                let sourceName = currentGame.seats[sourceIndex].player.name.isEmpty ? L10n.tr("Unnamed player") : currentGame.seats[sourceIndex].player.name
                let targetName = targetSeat.player.name.isEmpty ? L10n.tr("Unnamed player") : targetSeat.player.name
                currentGame.appendCurrentPhaseEvent(L10n.tr("%@, the claimed Monk has said to protect %@.", sourceName, targetName))
            }
        default:
            break
        }

        saveState()
    }

    func recordClaimedAbility(seat: Seat, summary: String) {
        guard currentGame.seats.contains(where: { $0.id == seat.id }) else {
            return
        }
        
        saveUndoSnapshotIfNeeded()
        currentGame.appendCurrentPhaseEvent(summary)
        saveState()
    }

    func recordNomination(nominator: Seat, nominee: Seat, voters: [Seat]) {
        guard currentGame.seats.contains(where: { $0.id == nominator.id }),
              currentGame.seats.contains(where: { $0.id == nominee.id }) else {
            return
        }

        saveUndoSnapshotIfNeeded()

        let voterSummary: String
        if voters.isEmpty {
            voterSummary = L10n.tr("no-one")
        } else {
            voterSummary = voters.map(displayName(for:)).joined(separator: ", ")
        }

        currentGame.appendCurrentPhaseEvent(
            L10n.tr(
                "%@ nominated %@. Votes: %@.",
                displayName(for: nominator),
                displayName(for: nominee),
                voterSummary
            )
        )
        saveState()
    }

    var nominationNominator: Seat? {
        seat(withID: nominationNominatorSeatID)
    }

    var nominationNominee: Seat? {
        seat(withID: nominationNomineeSeatID)
    }

    var nominationVoters: [Seat] {
        currentGame.seats.filter { nominationVoterSeatIDs.contains($0.id) }
    }

    var canRecordNominationDraft: Bool {
        guard let nominator = nominationNominator,
              let nominee = nominationNominee else {
            return false
        }
        return nominator.id != nominee.id
    }

    func setNominationSelectionMode(_ mode: NominationSelectionMode) {
        nominationSelectionMode = mode
    }

    func handleNominationSeatTap(_ seat: Seat) {
        guard currentGame.isNominationPhase else { return }

        switch nominationSelectionMode {
        case .nominator:
            nominationNominatorSeatID = seat.id
            if nominationNomineeSeatID == seat.id {
                nominationNomineeSeatID = nil
            }
            nominationSelectionMode = .nominee
        case .nominee:
            guard nominationNominatorSeatID != seat.id else { return }
            nominationNomineeSeatID = seat.id
            nominationSelectionMode = .voters
        case .voters:
            if nominationVoterSeatIDs.contains(seat.id) {
                nominationVoterSeatIDs.remove(seat.id)
            } else {
                nominationVoterSeatIDs.insert(seat.id)
            }
        }
    }

    func recordNominationDraft() {
        guard let nominator = nominationNominator,
              let nominee = nominationNominee,
              nominator.id != nominee.id else {
            return
        }

        recordNomination(nominator: nominator, nominee: nominee, voters: nominationVoters)
        resetNominationDraft()
    }

    func resetNominationDraft() {
        nominationSelectionMode = .nominator
        nominationNominatorSeatID = nil
        nominationNomineeSeatID = nil
        nominationVoterSeatIDs.removeAll()
    }

    func isNominationNominator(_ seat: Seat) -> Bool {
        nominationNominatorSeatID == seat.id
    }

    func isNominationNominee(_ seat: Seat) -> Bool {
        nominationNomineeSeatID == seat.id
    }

    func isNominationVoter(_ seat: Seat) -> Bool {
        nominationVoterSeatIDs.contains(seat.id)
    }

    func activeAbilityTarget(for seat: Seat) -> Seat? {
        guard let sourceIndex = currentGame.seats.firstIndex(where: { $0.id == seat.id }),
              let targetID = currentGame.seats[sourceIndex].player.activeAbilityTargetSeatID else {
            return nil
        }

        return currentGame.seats.first(where: { $0.id == targetID })
    }

    func updateCurrentPhaseNote(_ note: String) {
        saveUndoSnapshotIfNeeded()
        currentGame.updateCurrentPhaseNote(note)
        saveState()
    }

    func advancePhase() {
        saveUndoSnapshotIfNeeded()
        currentGame.advancePhase()
        resetNominationDraft()
        saveState()
    }
    
    var canUndoLastRecord: Bool {
        currentGame.gameState != .set_up && !undoStack.isEmpty
    }
    
    func undoLastRecord() {
        guard canUndoLastRecord, let previousGame = undoStack.popLast() else {
            return
        }
        currentGame = previousGame
        saveState()
    }
    
    // MARK: - Private Repo Caller
    
    func saveState() {
        repo.saveCurrentGame(currentGame: currentGame)
    }
    
    func refreshPastGames() {
        repo.loadPastGames()
        pastGames = repo.pastGames
    }
    
    func removePastGames(atOffsets offsets: IndexSet) {
        repo.removePastGames(atOffsets: offsets)
        pastGames = repo.pastGames
    }
    
    func replayPastGame(_ game: Game) {
        var replayGame = game
        replayGame.mdate = Date()
        replayGame.isCompleted = false
        replayGame.gameState = .set_up
        
        currentGame = replayGame
        undoStack.removeAll()
        saveState()
    }
    
    private func saveUndoSnapshotIfNeeded() {
        guard currentGame.gameState != .set_up else { return }
        undoStack.append(currentGame)
        if undoStack.count > maxUndoCount {
            undoStack.removeFirst(undoStack.count - maxUndoCount)
        }
    }

    private func displayName(for seat: Seat) -> String {
        let trimmed = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.tr("Unnamed player") : trimmed
    }

    private func seat(withID id: UUID?) -> Seat? {
        guard let id else { return nil }
        return currentGame.seats.first(where: { $0.id == id })
    }
}
