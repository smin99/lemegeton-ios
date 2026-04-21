//
//  SeatMenuView.swift
//  lemegeton
//
//  Created by Min Hwang on 10/21/25.
//

import SwiftUI

private let SEAT_SIZE: CGFloat = 60

struct SeatView: View {
    @Binding var seat: Seat
    @StateObject var boardVM: BoardViewModel
    var boardSize: CGSize = .zero
    var allSeats: [Seat] = []
    var onSnapGuideChanged: (SeatSnapGuide) -> Void = { _ in }
    
    @State private var showNoteEditor = false
    @State private var showCharacterList = false
    @State private var showRevealedCharacterList = false
    @State private var showEditNameSheet = false
    @State private var activeAbilitySheet: SupportedAbility?
    
    var body: some View {
        if boardVM.currentGame.gameState == .set_up {
            SetupSeatView(
                seat: $seat,
                boardVM: boardVM,
                boardSize: boardSize,
                allSeats: allSeats,
                onSnapGuideChanged: onSnapGuideChanged
            )
        } else {
            VStack(spacing: 4) {
                ZStack {
                    Group {
                        if boardVM.currentGame.gameState == .in_game && boardVM.currentGame.isNominationPhase {
                            Button {
                                boardVM.handleNominationSeatTap(seat)
                            } label: {
                                CircleImageView(
                                    character: $seat.player.character,
                                    isDead: $seat.player.isDead
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Menu {
                                Button(action: {
                                    showCharacterList = true
                                }) {
                                    Label(
                                        "Claimed Role",
                                        systemImage: "person.fill.questionmark"
                                    )
                                }
                                if boardVM.currentGame.gameState == .role_reveal {
                                    Button(action: {
                                        showRevealedCharacterList = true
                                    }) {
                                        Label(
                                            "Revealed Role",
                                            systemImage: "person.fill.checkmark"
                                        )
                                    }
                                    if let claimedCharacter = seat.player.character {
                                        Button(action: {
                                            boardVM.updateRevealedRole(seat: seat, character: claimedCharacter)
                                        }) {
                                            Label(
                                                "Reveal Same as Claim",
                                                systemImage: "checkmark.circle"
                                            )
                                        }
                                    }
                                }
                                if let ability = seat.player.character?.supportedAbility {
                                    Button(action: {
                                        activeAbilitySheet = ability
                                    }) {
                                        Label(
                                            abilityMenuTitle(for: ability),
                                            systemImage: abilitySystemImage(for: ability)
                                        )
                                    }
                                }
                                Button(action: {
                                    boardVM.deathUpon(seat: seat)
                                }) {
                                    Label(
                                        seat.player.isDead ? "Revive!" : "Dead",
                                        systemImage: seat.player.isDead
                                        ? "sparkles"
                                        : "person.slash.fill"
                                    )
                                }
                                Button(action: {
                                    showEditNameSheet = true
                                }) {
                                    Label("Edit Name", systemImage: "pencil.line")
                                }
                                Button(action: {
                                    showNoteEditor = true
                                }) {
                                    Label("Write Note", systemImage: "note.text")
                                }
                            } label: {
                                CircleImageView(
                                    character: $seat.player.character,
                                    isDead: $seat.player.isDead
                                )
                            }
                        }
                    }
                    .frame(width: SEAT_SIZE, height: SEAT_SIZE)
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $showEditNameSheet) {
                        EditNameSheetView(
                            onComplete: { newName in
                                boardVM.editSeatName(
                                    seat: seat,
                                    newName: newName
                                )
                                showEditNameSheet = false
                            },
                            playerName: seat.player.name
                        )
                    }
                    .sheet(isPresented: $showNoteEditor) {
                        NoteTakeView(
                            title: L10n.tr("%@'s Note", seat.player.name),
                            onComplete: { note in
                                boardVM.updatePlayerNote(seat: seat, note: note)
                                showNoteEditor = false
                            },
                            buttonTitle: L10n.tr("Done"),
                            placeholder: L10n.tr("Write a private note"),
                            note: seat.player.note
                        )
                    }
                    .sheet(isPresented: $showCharacterList) {
                        CharacterListView(
                            titleText: L10n.tr("Guess %@'s role", seat.player.name),
                            onComplete: { characters in
                                boardVM.updateClaimedRole(
                                    seat: seat,
                                    character: Array(characters).first
                                )
                                showCharacterList = false
                            },
                            allCharacters: boardVM.currentGame.inGameCharacters
                                .sorted(by: {
                                    if $0.type < $1.type {
                                        true
                                    } else {
                                        $0.id < $1.id
                                    }
                                }),
                            includeScenario: false,
                            maxSelectionCount: 1,
                            selectedCharacters: Set(
                                seat.player.character.map { [$0] } ?? []
                            )
                        )
                    }
                    .sheet(isPresented: $showRevealedCharacterList) {
                        CharacterListView(
                            titleText: L10n.tr("Reveal %@'s role", seat.player.name),
                            onComplete: { characters in
                                boardVM.updateRevealedRole(
                                    seat: seat,
                                    character: Array(characters).first
                                )
                                showRevealedCharacterList = false
                            },
                            allCharacters: boardVM.currentGame.inGameCharacters
                                .sorted(by: {
                                    if $0.type < $1.type {
                                        true
                                    } else {
                                        $0.id < $1.id
                                    }
                                }),
                            includeScenario: false,
                            maxSelectionCount: 1,
                            selectedCharacters: Set(
                                seat.player.revealedCharacter.map { [$0] } ?? []
                            )
                        )
                    }
                    .sheet(item: $activeAbilitySheet) { ability in
                        AbilityActionSheet(
                            ability: ability,
                            sourceSeat: seat,
                            seats: availableTargets(for: ability),
                            characters: availableCharacters(for: ability),
                            selectedSeatIDs: ability == .monkProtect ? boardVM.activeAbilityTarget(for: seat).map { [$0.id] } ?? [] : [],
                            onSubmit: { selection in
                                handleAbilitySelection(ability, selection: selection)
                                activeAbilitySheet = nil
                            }
                        ) 
                    }
                }

                if boardVM.currentGame.gameState == .in_game && boardVM.currentGame.isNominationPhase {
                    NominationSeatStatusView(
                        isNominator: boardVM.isNominationNominator(seat),
                        isNominee: boardVM.isNominationNominee(seat),
                        isVoter: boardVM.isNominationVoter(seat)
                    )
                    .frame(width: 96)
                }
                
                HStack {
                    if seat.player.isCharacterConfirmed {
                        // show check mark
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(
                                seat.player.character?.type
                                == CharacterType.townsfolk
                                || seat.player.character?.type
                                == CharacterType.outsider
                                ? .blue : .red
                            )
                    }
                    
                    Text(seat.player.name)
                        .frame(width: SEAT_SIZE)
                        .foregroundStyle(seat.player.isDead ? .gray : .themeOnSurface)
                        .strikethrough(seat.player.isDead, color: .themeTertiary)
                }

                if let learnedRoleName = seat.player.learnedCharacter?.localizedName {
                    Text(L10n.tr("Learned: %@.", learnedRoleName))
                        .font(.caption2)
                        .frame(width: 96)
                        .foregroundStyle(.themePrimary.opacity(0.88))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }

                if let revealedRoleName = seat.player.revealedCharacter?.localizedName {
                    Text(L10n.tr("Revealed: %@.", revealedRoleName))
                        .font(.caption2)
                        .frame(width: 96)
                        .foregroundStyle(.themeOnSurface.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
            .position(x: seat.x, y: seat.y)
        }
    }

    private func abilityMenuTitle(for ability: SupportedAbility) -> String {
        switch ability {
        case .monkProtect:
            if let target = boardVM.activeAbilityTarget(for: seat) {
                let targetName = target.player.name.isEmpty ? L10n.tr("Unnamed player") : target.player.name
                return L10n.tr("Protected: %@", targetName)
            }
            return L10n.tr("Protected")
        default:
            return ability.menuTitle
        }
    }

    private func abilitySystemImage(for ability: SupportedAbility) -> String {
        switch ability {
        case .monkProtect:
            return "shield.lefthalf.filled"
        default:
            return ability.defaultSystemImage
        }
    }

    private func availableTargets(for ability: SupportedAbility) -> [Seat] {
        switch ability.input {
        case let .players(_, _, excludeSelf, aliveOnly, deadOnly),
                let .playersAndYesNo(_, excludeSelf, aliveOnly, deadOnly, _),
                let .playerAndCharacter(excludeSelf, aliveOnly, deadOnly, _),
                let .playersAndCharacter(_, excludeSelf, aliveOnly, deadOnly, _),
                let .playerAndTwoCharacters(excludeSelf, aliveOnly, deadOnly, _, _),
                let .multiplePlayerAndCharacter(_, excludeSelf, aliveOnly, deadOnly, _):
            return boardVM.currentGame.seats.filter { targetSeat in
                if excludeSelf && targetSeat.id == seat.id {
                    return false
                }
                if aliveOnly && targetSeat.player.isDead {
                    return false
                }
                if deadOnly && !targetSeat.player.isDead {
                    return false
                }
                return true
            }
        case .text, .number, .yesNo, .character:
            return []
        }
    }

    private func availableCharacters(for ability: SupportedAbility) -> [Character] {
        let sortedCharacters = boardVM.currentGame.inGameCharacters.sorted(by: {
            if $0.type < $1.type {
                return true
            }
            return $0.id < $1.id
        })

        switch ability.input {
        case let .playerAndCharacter(_, _, _, characterScope),
             let .playersAndCharacter(_, _, _, _, characterScope),
             let .multiplePlayerAndCharacter(_, _, _, _, characterScope),
             let .character(characterScope):
            return sortedCharacters.filter(characterScope.includes(_:))
        case let .playerAndTwoCharacters(_, _, _, firstCharacterScope, secondCharacterScope):
            return sortedCharacters.filter { firstCharacterScope.includes($0) || secondCharacterScope.includes($0) }
        case .text, .number, .yesNo, .players, .playersAndYesNo:
            return sortedCharacters
        }
    }

    private func handleAbilitySelection(_ ability: SupportedAbility, selection: AbilitySelection) {
        if ability == .monkProtect, case let .players(seats) = selection {
            boardVM.updateAbilityTarget(for: seat, targetSeat: seats.first)
            return
        }

        switch (ability, selection) {
        case let (.undertakerInfo, .playerAndCharacter(player, character)),
             let (.ravenkeeperCheck, .playerAndCharacter(player, character)),
             let (.grandmotherInfo, .playerAndCharacter(player, character)):
            boardVM.updateLearnedRole(seat: player, character: character)
        default:
            break
        }

        let actorName = seat.player.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? L10n.tr("Unnamed player") : seat.player.name
        guard let summary = ability.chronicleSummary(actorName: actorName, selection: selection) else {
            return
        }

        boardVM.recordClaimedAbility(seat: seat, summary: summary)

        switch (ability, selection) {
        case let (.slayerShot, .playersAndYesNo(players, true)),
             let (.virginTrigger, .playersAndYesNo(players, true)):
            if let target = players.first,
               let targetIndex = boardVM.currentGame.seats.firstIndex(where: { $0.id == target.id }),
               !boardVM.currentGame.seats[targetIndex].player.isDead {
                boardVM.currentGame.seats[targetIndex].player.isDead = true
                boardVM.saveState()
            }
        default:
            break
        }
    }
}

private struct NominationSeatStatusView: View {
    let isNominator: Bool
    let isNominee: Bool
    let isVoter: Bool

    var body: some View {
        HStack(spacing: 4) {
            if isNominator {
                nominationTag("N", color: .themePrimary)
            }

            if isNominee {
                nominationTag("T", color: .orange)
            }

            if isVoter {
                nominationTag("V", color: .green)
            }
        }
        .frame(height: 18)
    }

    private func nominationTag(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color.opacity(0.16))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.45), lineWidth: 1)
            )
    }
}

private struct SetupSeatView: View {
    @Binding var seat: Seat
    @StateObject var boardVM: BoardViewModel
    let boardSize: CGSize
    let allSeats: [Seat]
    let onSnapGuideChanged: (SeatSnapGuide) -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    private let alignmentThreshold: CGFloat = 18
    private let circleThreshold: CGFloat = 22
    private let seatPadding: CGFloat = SEAT_SIZE / 2
    private let seatSpacing: CGFloat = 8
    private let nameFieldHeight: CGFloat = 30
    
    var body: some View {
        VStack(spacing: seatSpacing) {
            ZStack(alignment: .topTrailing) {
                CircleImageView(character: $seat.player.character, isDead: $seat.player.isDead)

                Button {
                    boardVM.removeSeat(seat: seat)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.themePrimary, Color(.themeSurface))
                        .background(Color(.themeSurface))
                        .clipShape(Circle())
                }
                .offset(x: 8, y: -8)
            }
            
            TextField(
                "",
                text: $seat.player.name,
                prompt: Text("Name").foregroundStyle(.gray.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.themePrimary, lineWidth: 1)
            )
            .foregroundStyle(.themeOnSurface)
            .background(Color.themeSurface)
            .frame(width: SEAT_SIZE, height: nameFieldHeight)
            .keyboardShortcut(.defaultAction)
            .multilineTextAlignment(.center)
        }
        .position(x: seat.x + dragOffset.width, y: seat.y + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let snapped = snappedResult(for: CGPoint(
                        x: seat.x + value.translation.width,
                        y: seat.y + value.translation.height
                    ))
                    dragOffset = CGSize(
                        width: snapped.position.x - seat.x,
                        height: snapped.position.y - seat.y
                    )
                    onSnapGuideChanged(snapped.guide)
                }
                .onEnded { value in
                    let snapped = snappedResult(for: CGPoint(
                        x: seat.x + value.translation.width,
                        y: seat.y + value.translation.height
                    ))
                    seat.x = snapped.position.x
                    seat.y = snapped.position.y
                    dragOffset = .zero
                    onSnapGuideChanged(SeatSnapGuide())
                }
        )
    }
    
    private func snappedResult(for rawPosition: CGPoint) -> (position: CGPoint, guide: SeatSnapGuide) {
        let rawCircleCenter = CGPoint(
            x: rawPosition.x,
            y: rawPosition.y + circleCenterYOffset
        )
        var clampedCircleCenter = CGPoint(
            x: min(max(rawCircleCenter.x, seatPadding), max(boardSize.width - seatPadding, seatPadding)),
            y: min(max(rawCircleCenter.y, seatPadding), max(boardSize.height - seatPadding, seatPadding))
        )
        
        let neighboringSeats = allSeats.filter { $0.id != seat.id }
        let snappedX = nearestCoordinate(
            to: clampedCircleCenter.x,
            candidates: neighboringSeats.map(\.x),
            threshold: alignmentThreshold
        )
        let snappedY = nearestCoordinate(
            to: clampedCircleCenter.y,
            candidates: neighboringSeats.map { $0.y + circleCenterYOffset },
            threshold: alignmentThreshold
        )
        
        clampedCircleCenter.x = snappedX ?? clampedCircleCenter.x
        clampedCircleCenter.y = snappedY ?? clampedCircleCenter.y
        var guide = SeatSnapGuide(
            verticalX: snappedX,
            horizontalY: snappedY,
            circleRadius: nil
        )
        
        if snappedX == nil && snappedY == nil,
           let radius = nearestCircleRadius(
            to: clampedCircleCenter,
            neighboringSeats: neighboringSeats,
            center: boardCenter,
            threshold: circleThreshold
           ) {
            let angle = atan2(clampedCircleCenter.y - boardCenter.y, clampedCircleCenter.x - boardCenter.x)
            clampedCircleCenter = CGPoint(
                x: boardCenter.x + cos(angle) * radius,
                y: boardCenter.y + sin(angle) * radius
            )
            clampedCircleCenter.x = min(max(clampedCircleCenter.x, seatPadding), max(boardSize.width - seatPadding, seatPadding))
            clampedCircleCenter.y = min(max(clampedCircleCenter.y, seatPadding), max(boardSize.height - seatPadding, seatPadding))
            guide.circleRadius = radius
        }
        
        let snappedPosition = CGPoint(
            x: clampedCircleCenter.x,
            y: clampedCircleCenter.y - circleCenterYOffset
        )
        
        return (snappedPosition, guide)
    }
    
    private func nearestCoordinate(to value: CGFloat, candidates: [CGFloat], threshold: CGFloat) -> CGFloat? {
        candidates
            .map { candidate in (candidate: candidate, distance: abs(candidate - value)) }
            .filter { $0.distance <= threshold }
            .min(by: { $0.distance < $1.distance })?
            .candidate
    }
    
    private func nearestCircleRadius(
        to position: CGPoint,
        neighboringSeats: [Seat],
        center: CGPoint,
        threshold: CGFloat
    ) -> CGFloat? {
        let positionRadius = hypot(position.x - center.x, position.y - center.y)
        return neighboringSeats
            .map { neighboringSeat in
                hypot(neighboringSeat.x - center.x, neighboringSeat.y - center.y)
            }
            .map { radius in (radius: radius, distance: abs(radius - positionRadius)) }
            .filter { $0.distance <= threshold }
            .min(by: { $0.distance < $1.distance })?
            .radius
    }
    
    private var boardCenter: CGPoint {
        CGPoint(x: boardSize.width / 2, y: boardSize.height / 2)
    }
    
    private var circleCenterYOffset: CGFloat {
        -((seatSpacing + nameFieldHeight) / 2)
    }
}

private struct CircleImageView: View {
    @Binding var character: Character?
    @Binding var isDead: Bool
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: SEAT_SIZE, height: SEAT_SIZE)
            .overlay(content: {
                if character != nil {
                    Image(character!.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: SEAT_SIZE, height: SEAT_SIZE)
                        .clipShape(Circle())
                }
                
                if isDead {
                    ZStack {
                        Circle()
                            .fill(.red.opacity(0.68))
                        
                        Text("R.I.P.")
                            .foregroundStyle(.white)
                    }
                }
            })
    }
}

private struct AbilityActionSheet: View {
    let ability: SupportedAbility
    let sourceSeat: Seat
    let seats: [Seat]
    let characters: [Character]
    let selectedSeatIDs: [UUID]
    let onSubmit: (AbilitySelection) -> Void

    var body: some View {
        switch ability.input {
        case let .text(placeholder):
            NoteTakeView(
                title: sheetTitle,
                onComplete: { text in
                    onSubmit(.text(text))
                },
                buttonTitle: L10n.tr("Record"),
                placeholder: placeholder,
                note: ""
            )
        case let .number(placeholder):
            NumberTakeView(
                title: sheetTitle,
                onComplete: { value in
                    onSubmit(.number(value))
                },
                buttonTitle: L10n.tr("Record"),
                placeholder: placeholder
            )
        case let .yesNo(prompt):
            YesNoAbilityView(
                title: sheetTitle,
                prompt: prompt,
                onSubmit: { value in
                    onSubmit(.yesNo(value))
                }
            )
        case let .players(minSelectionCount, maxSelectionCount, _, _, _):
            PlayerSelectionAbilityView(
                title: sheetTitle,
                seats: seats,
                minSelectionCount: minSelectionCount,
                maxSelectionCount: maxSelectionCount,
                selectedSeatIDs: selectedSeatIDs,
                onSubmit: { selectedSeats in
                    onSubmit(.players(selectedSeats))
                }
            )
        case let .playersAndYesNo(playerCount, _, _, _, prompt):
            PlayersAndYesNoAbilityView(
                title: sheetTitle,
                prompt: prompt,
                seats: seats,
                playerCount: playerCount,
                onSubmit: { selectedSeats, value in
                    onSubmit(.playersAndYesNo(players: selectedSeats, value: value))
                }
            )
        case .playerAndCharacter:
            PlayerAndCharacterAbilityView(
                title: sheetTitle,
                seats: seats,
                characters: characters,
                onSubmit: { targetSeat, character in
                    onSubmit(.playerAndCharacter(player: targetSeat, character: character))
                }
            )
        case let .playersAndCharacter(playerCount, _, _, _, characterScope):
            PlayersAndCharacterAbilityView(
                title: sheetTitle,
                seats: seats,
                characters: characters.filter(characterScope.includes(_:)),
                playerCount: playerCount,
                onSubmit: { selectedSeats, character in
                    onSubmit(.playersAndCharacter(players: selectedSeats, character: character))
                }
            )
        case let .playerAndTwoCharacters(_, _, _, firstCharacterScope, secondCharacterScope):
            PlayerAndTwoCharactersAbilityView(
                title: sheetTitle,
                seats: seats,
                firstCharacters: characters.filter(firstCharacterScope.includes(_:)),
                secondCharacters: characters.filter(secondCharacterScope.includes(_:)),
                onSubmit: { targetSeat, firstCharacter, secondCharacter in
                    onSubmit(.playerAndTwoCharacters(player: targetSeat, firstCharacter: firstCharacter, secondCharacter: secondCharacter))
                }
            )
        case let .multiplePlayerAndCharacter(maxSelectionCount, _, _, _, characterScope):
            MultiplePlayerCharacterGuessesView(
                title: sheetTitle,
                seats: seats,
                characters: characters.filter(characterScope.includes(_:)),
                maxSelectionCount: maxSelectionCount,
                onSubmit: { guesses in
                    onSubmit(.multiplePlayerAndCharacter(guesses))
                }
            )
        case .character:
            CharacterAbilityView(
                title: sheetTitle,
                characters: characters,
                onSubmit: { character in
                    onSubmit(.character(character))
                }
            )
        }
    }

    private var sheetTitle: String {
        sourceSeat.player.name.isEmpty ? ability.menuTitle : L10n.tr("%@: %@", sourceSeat.player.name, ability.menuTitle)
    }
}

private struct NumberTakeView: View {
    let title: String
    let onComplete: (Int) -> Void
    let buttonTitle: String
    let placeholder: String

    @State private var numberText = ""
    @FocusState private var keyboardFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .grimoireBoldStyle(size: 20)
                    .foregroundStyle(.themeOnSurface)

                TextField(placeholder, text: $numberText)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.numberPad)
                    .foregroundStyle(.themeOnSurface)
                    .tint(.themePrimary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.themeSurface.opacity(0.94))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.themePrimary.opacity(0.18), lineWidth: 1)
                    )
                    .overlay(alignment: .leading) {
                        if numberText.isEmpty {
                            Text(placeholder)
                                .foregroundStyle(.themeOnSurface.opacity(0.58))
                                .padding(.horizontal, 16)
                                .allowsHitTesting(false)
                        }
                    }
                    .focused($keyboardFocused)
                    .onChange(of: numberText) { _, newValue in
                        numberText = newValue.filter(\.isNumber)
                    }

                Spacer()
            }
            .padding()
            .background(Color.themeSurface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(buttonTitle) {
                        guard let value = Int(numberText) else {
                            return
                        }
                        onComplete(value)
                    }
                    .disabled(Int(numberText) == nil)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    keyboardFocused = true
                }
            }
        }
    }
}

private struct YesNoAbilityView: View {
    let title: String
    let prompt: String
    let onSubmit: (Bool) -> Void

    @State private var value = true

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .grimoireBoldStyle(size: 20)
                    .foregroundStyle(.themeOnSurface)

                Text(prompt)
                    .font(.caption)
                    .foregroundStyle(.themeOnSurface)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.themeSurface.opacity(0.94))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.themePrimary.opacity(0.18), lineWidth: 1)
                    )

                Picker("", selection: $value) {
                    Text(L10n.tr("Yes")).tag(true)
                    Text(L10n.tr("No")).tag(false)
                }
                .pickerStyle(.segmented)

                Spacer()
            }
            .padding()
            .background(Color.themeSurface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.tr("Record")) {
                        onSubmit(value)
                    }
                }
            }
        }
    }
}

private struct PlayersAndYesNoAbilityView: View {
    let title: String
    let prompt: String
    let seats: [Seat]
    let playerCount: Int
    let onSubmit: ([Seat], Bool) -> Void

    @State private var selectedSeatIDs: Set<UUID> = []
    @State private var value = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(prompt)
                        .font(.caption)
                        .foregroundStyle(.themeOnSurface)
                        .padding(.vertical, 4)
                        .listRowBackground(Color(.themeSurface).opacity(0.92))

                    Picker("", selection: $value) {
                        Text(L10n.tr("Yes")).tag(true)
                        Text(L10n.tr("No")).tag(false)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color(.themeSurface).opacity(0.92))
                }

                Section {
                    ForEach(seats) { targetSeat in
                        Button {
                            toggle(targetSeat)
                        } label: {
                            AbilitySeatRow(
                                seat: targetSeat,
                                isSelected: selectedSeatIDs.contains(targetSeat.id)
                            )
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                } header: {
                    Text(L10n.tr("Players"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.themeSurface))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.tr("Record")) {
                        let selectedSeats = seats.filter { selectedSeatIDs.contains($0.id) }
                        onSubmit(selectedSeats, value)
                    }
                    .disabled(selectedSeatIDs.count != playerCount)
                }
            }
        }
    }

    private func toggle(_ seat: Seat) {
        if selectedSeatIDs.contains(seat.id) {
            selectedSeatIDs.remove(seat.id)
            return
        }

        if selectedSeatIDs.count < playerCount {
            selectedSeatIDs.insert(seat.id)
        }
    }
}

private struct PlayerSelectionAbilityView: View {
    let title: String
    let seats: [Seat]
    let minSelectionCount: Int
    let maxSelectionCount: Int
    let onSubmit: ([Seat]) -> Void

    @State private var selectedSeatIDs: Set<UUID>

    init(title: String, seats: [Seat], minSelectionCount: Int, maxSelectionCount: Int, selectedSeatIDs: [UUID] = [], onSubmit: @escaping ([Seat]) -> Void) {
        self.title = title
        self.seats = seats
        self.minSelectionCount = minSelectionCount
        self.maxSelectionCount = maxSelectionCount
        self.onSubmit = onSubmit
        _selectedSeatIDs = State(initialValue: Set(selectedSeatIDs))
    }

    var body: some View {
        NavigationStack {
            List(seats) { targetSeat in
                Button {
                    toggle(targetSeat)
                } label: {
                    AbilitySeatRow(
                        seat: targetSeat,
                        isSelected: selectedSeatIDs.contains(targetSeat.id)
                    )
                }
                .listRowBackground(Color(.themeSurface).opacity(0.92))
            }
            .scrollContentBackground(.hidden)
            .background(Color(.themeSurface))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Record") {
                        onSubmit(seats.filter { selectedSeatIDs.contains($0.id) })
                    }
                    .disabled(!isSelectionValid)
                }
            }
        }
    }

    private var isSelectionValid: Bool {
        selectedSeatIDs.count >= minSelectionCount && selectedSeatIDs.count <= maxSelectionCount
    }

    private func toggle(_ seat: Seat) {
        if selectedSeatIDs.contains(seat.id) {
            selectedSeatIDs.remove(seat.id)
            return
        }

        if maxSelectionCount == 1 {
            selectedSeatIDs = [seat.id]
        } else if selectedSeatIDs.count < maxSelectionCount {
            selectedSeatIDs.insert(seat.id)
        }
    }
}

private struct PlayerAndCharacterAbilityView: View {
    let title: String
    let seats: [Seat]
    let characters: [Character]
    let onSubmit: (Seat, Character) -> Void

    @State private var selectedSeatID: UUID?
    @State private var selectedCharacterID: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Player") {
                    ForEach(seats) { targetSeat in
                        Button {
                            selectedSeatID = targetSeat.id
                        } label: {
                            AbilitySeatRow(
                                seat: targetSeat,
                                isSelected: selectedSeatID == targetSeat.id
                            )
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                }

                Section("Character") {
                    ForEach(characters) { character in
                        Button {
                            selectedCharacterID = character.id
                        } label: {
                            CharacterSelectionRow(
                                character: character,
                                isSelected: selectedCharacterID == character.id
                            )
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.themeSurface))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Record") {
                        if let selectedSeat = seats.first(where: { $0.id == selectedSeatID }),
                           let selectedCharacter = characters.first(where: { $0.id == selectedCharacterID }) {
                            onSubmit(selectedSeat, selectedCharacter)
                        }
                    }
                    .disabled(selectedSeatID == nil || selectedCharacterID == nil)
                }
            }
        }
    }
}

private struct PlayersAndCharacterAbilityView: View {
    let title: String
    let seats: [Seat]
    let characters: [Character]
    let playerCount: Int
    let onSubmit: ([Seat], Character) -> Void

    @State private var selectedSeatIDs: Set<UUID> = []
    @State private var selectedCharacterID: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Players") {
                    ForEach(seats) { targetSeat in
                        Button {
                            toggleSeat(targetSeat)
                        } label: {
                            AbilitySeatRow(seat: targetSeat, isSelected: selectedSeatIDs.contains(targetSeat.id))
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                }

                Section("Character") {
                    ForEach(characters) { character in
                        Button {
                            selectedCharacterID = character.id
                        } label: {
                            CharacterSelectionRow(character: character, isSelected: selectedCharacterID == character.id)
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.themeSurface))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Record") {
                        if let character = characters.first(where: { $0.id == selectedCharacterID }) {
                            onSubmit(seats.filter { selectedSeatIDs.contains($0.id) }, character)
                        }
                    }
                    .disabled(selectedSeatIDs.count != playerCount || selectedCharacterID == nil)
                }
            }
        }
    }

    private func toggleSeat(_ seat: Seat) {
        if selectedSeatIDs.contains(seat.id) {
            selectedSeatIDs.remove(seat.id)
            return
        }

        if selectedSeatIDs.count < playerCount {
            selectedSeatIDs.insert(seat.id)
        }
    }
}

private struct PlayerAndTwoCharactersAbilityView: View {
    let title: String
    let seats: [Seat]
    let firstCharacters: [Character]
    let secondCharacters: [Character]
    let onSubmit: (Seat, Character, Character) -> Void

    @State private var selectedSeatID: UUID?
    @State private var firstCharacterID: String?
    @State private var secondCharacterID: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Player") {
                    ForEach(seats) { targetSeat in
                        Button {
                            selectedSeatID = targetSeat.id
                        } label: {
                            AbilitySeatRow(seat: targetSeat, isSelected: selectedSeatID == targetSeat.id)
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                }

                Section("Good Character") {
                    ForEach(firstCharacters) { character in
                        Button {
                            firstCharacterID = character.id
                        } label: {
                            CharacterSelectionRow(character: character, isSelected: firstCharacterID == character.id)
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                }

                Section("Evil Character") {
                    ForEach(secondCharacters) { character in
                        Button {
                            secondCharacterID = character.id
                        } label: {
                            CharacterSelectionRow(character: character, isSelected: secondCharacterID == character.id)
                        }
                        .listRowBackground(Color(.themeSurface).opacity(0.92))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.themeSurface))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Record") {
                        if let seat = seats.first(where: { $0.id == selectedSeatID }),
                           let firstCharacter = firstCharacters.first(where: { $0.id == firstCharacterID }),
                           let secondCharacter = secondCharacters.first(where: { $0.id == secondCharacterID }) {
                            onSubmit(seat, firstCharacter, secondCharacter)
                        }
                    }
                    .disabled(selectedSeatID == nil || firstCharacterID == nil || secondCharacterID == nil)
                }
            }
        }
    }
}

private struct MultiplePlayerCharacterGuessesView: View {
    let title: String
    let seats: [Seat]
    let characters: [Character]
    let maxSelectionCount: Int
    let onSubmit: ([(Seat, Character)]) -> Void

    @State private var guesses: [PlayerCharacterGuess] = [PlayerCharacterGuess()]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(guesses.enumerated()), id: \.element.id) { index, _ in
                    Section(L10n.tr("Guess %lld", Int64(index + 1))) {
                        Picker("Player", selection: bindingForSeat(at: index)) {
                            Text("Select player").tag(UUID?.none)
                            ForEach(seats) { targetSeat in
                                Text(targetSeat.player.name.isEmpty ? L10n.tr("Unnamed player") : targetSeat.player.name)
                                    .tag(Optional(targetSeat.id))
                            }
                        }

                        Picker("Character", selection: bindingForCharacter(at: index)) {
                            Text("Select character").tag(String?.none)
                            ForEach(characters) { character in
                                Text(character.localizedName)
                                    .tag(Optional(character.id))
                            }
                        }
                    }
                }

                if guesses.count < maxSelectionCount {
                    Button("Add Guess") {
                        guesses.append(PlayerCharacterGuess())
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.themeSurface))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Record") {
                        onSubmit(compactGuesses)
                    }
                    .disabled(compactGuesses.isEmpty)
                }
            }
        }
    }

    private var compactGuesses: [(Seat, Character)] {
        guesses.compactMap { guess in
            guard let seatID = guess.seatID,
                  let characterID = guess.characterID,
                  let seat = seats.first(where: { $0.id == seatID }),
                  let character = characters.first(where: { $0.id == characterID }) else {
                return nil
            }
            return (seat, character)
        }
    }

    private func bindingForSeat(at index: Int) -> Binding<UUID?> {
        Binding(
            get: { guesses[index].seatID },
            set: { guesses[index].seatID = $0 }
        )
    }

    private func bindingForCharacter(at index: Int) -> Binding<String?> {
        Binding(
            get: { guesses[index].characterID },
            set: { guesses[index].characterID = $0 }
        )
    }
}

private struct CharacterAbilityView: View {
    let title: String
    let characters: [Character]
    let onSubmit: (Character) -> Void

    @State private var selectedCharacterID: String?

    var body: some View {
        NavigationStack {
            List(characters) { character in
                Button {
                    selectedCharacterID = character.id
                } label: {
                    HStack {
                        Text(character.localizedName)
                            .foregroundStyle(.themeOnSurface)
                        Spacer()
                        if selectedCharacterID == character.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.themePrimary)
                        }
                    }
                }
                .listRowBackground(Color(.themeSurface).opacity(0.92))
            }
            .scrollContentBackground(.hidden)
            .background(Color(.themeSurface))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Record") {
                        if let selectedCharacter = characters.first(where: { $0.id == selectedCharacterID }) {
                            onSubmit(selectedCharacter)
                        }
                    }
                    .disabled(selectedCharacterID == nil)
                }
            }
        }
    }
}

private struct CharacterSelectionRow: View {
    let character: Character
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(character.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }

            Text(character.localizedName)
                .foregroundStyle(.themeOnSurface)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.themePrimary)
            }
        }
    }
}

private struct PlayerCharacterGuess: Identifiable {
    let id = UUID()
    var seatID: UUID?
    var characterID: String?
}
private struct AbilitySeatRow: View {
    let seat: Seat
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .overlay {
                    if let character = seat.player.character {
                        Image(character.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(seat.player.name.isEmpty ? L10n.tr("Unnamed player") : seat.player.name)
                    .foregroundStyle(.themeOnSurface)

                if let roleName = seat.player.character?.localizedName {
                    Text(L10n.tr("Claim: %@.", roleName))
                        .font(.caption)
                        .foregroundStyle(.themePrimary.opacity(0.75))
                }

                if let learnedRoleName = seat.player.learnedCharacter?.localizedName {
                    Text(L10n.tr("Learned: %@.", learnedRoleName))
                        .font(.caption)
                        .foregroundStyle(.themePrimary.opacity(0.72))
                }

                if let revealedRoleName = seat.player.revealedCharacter?.localizedName {
                    Text(L10n.tr("Revealed: %@.", revealedRoleName))
                        .font(.caption)
                        .foregroundStyle(.themeOnSurface.opacity(0.72))
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.themePrimary)
            }
        }
    }
}
