//
//  GameModel.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/22/22.
//

import Foundation

final class GameModel: ObservableObject {
    @Published var markGrid: [Mark]
    @Published var gameOverMan = false
    @Published var winningMark: MarkType? = nil
    private var gameGridModel: [MarkModel] = [MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel()]
    private var rows = [[MarkModel]]()
    private var columns = [[MarkModel]]()
    private var diagnals = [[MarkModel]]()
    private var playersTurn = true
    private var aiThinking = false
    private let aiThinkTime = 0.4...0.75
    private var rateLimiter = RateLimiter(maxRefreshRate: 0.25)
    
    init() {
        self.markGrid = gameGridModel.map { Mark(type: $0.type, inWinningSequence: $0.inWinningSequence, modelID: $0.id) }
        populateSequences()
    }
    
    func tapped(_ mark: Mark) {
        guard !aiThinking else { return }
        rateLimiter.execute { playerMove(on: mark.id) }
    }
    
    private func playerMove(on id: UUID) {
        guard playersTurn else { return }
        makeMove(on: id)
        
        if hasOpenMarks && !gameOverMan {
            aiThinking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + randomAIThinkTime, execute: aiMove)
        } else {
            gameOverMan = true
        }
    }
    
    private var randomAIThinkTime: Double {
        Double.random(in: aiThinkTime)
    }
    
    private func makeMove(on id: UUID) {
        guard let index = markGrid.firstIndex(where: { $0.id == id }) else { return }
        print("\(playersTurn ? "Player" : "AI") choses: \(index)")
        gameGridModel[index].type = playersTurn ? .x : .o
        checkForWin()
        updateMarkGrid()
        playersTurn.toggle()
    }
    
    private func aiMove() {
        if let blockMoveID = bestBlockMoveID {
            makeMove(on: blockMoveID)
        } else {
            guard let randomID = randomOpenMarkID else { return }
            makeMove(on: randomID)
        }
        aiThinking = false
    }
    
    private var bestBlockMoveID: UUID? {
        let sequences = [rows, columns, diagnals]
        let availableBlockMoves = sequences.flatMap { blockMoves($0) }
        
        switch availableBlockMoves.count {
        case 0:
            return nil
        case 1:
            let modelID = availableBlockMoves.first?.id
            return markIDFrom(modelID: modelID)
        default:
            // Currently picking random block move, update to choose "best" block move
            let modelID = availableBlockMoves.randomElement()?.id
            return markIDFrom(modelID: modelID)
        }
    }
    
    private func markIDFrom(modelID: UUID?) -> UUID? {
        guard let modelID = modelID else { return nil }
        return markGrid.first { $0.modelID == modelID }?.id
    }
    
    private func blockMoves(_ array: [[MarkModel]]) -> [MarkModel] {
        let markToBlock: MarkType = .x // make dynamic based on which mark player is using
        return array.compactMap { availableBlockMove($0, markTypeToBlock: markToBlock) }
    }
    
    private func availableBlockMove(_ array: [MarkModel], markTypeToBlock markType: MarkType) -> MarkModel? {
        guard array.filter({ $0.type == markType }).count == 2 else { return nil }
        return array.filter({ $0.type == nil }).first
    }
    
    private var randomOpenMarkID: UUID? {
        let openMarks = markGrid.filter { $0.type == nil }
        return openMarks.randomElement()?.id
    }
    
    func resetGame() {
        gameGridModel = [MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel()]
        populateSequences()
        winningMark = nil
        gameOverMan = false
        updateMarkGrid()
        playersTurn = true
    }
    
    private func populateSequences() {
        let indicies = GridIndexGenerator(columns: 3, rows: 3)
        self.rows = indicies.rowIndexes.map { $0.map { gameGridModel[$0] } }
        self.columns = indicies.columnIndexes.map { $0.map { gameGridModel[$0] } }
        self.diagnals = indicies.diagnalIndexes.map { $0.map { gameGridModel[$0] } }
    }
    
    private func updateMarkGrid() {
        let newGrid = gameGridModel.map { Mark(type: $0.type, inWinningSequence: $0.inWinningSequence, modelID: $0.id) }
        markGrid = newGrid
    }
    
    private func checkForWin() {
        gameOverMan = checkForWinningSequence(rows) || checkForWinningSequence(columns) || checkForWinningSequence(diagnals)
    }
    
    private func checkForWinningSequence(_ array: [[MarkModel]]) -> Bool {
        for markSequence in array {
            if hasWin(markSequence) {
                markWinningSequence(markSequence)
                winningMark = playersTurn ? .x : .o
                return true
            }
        }
        return false
    }
    
    private func markWinningSequence(_ markSequence: [MarkModel]) {
        markSequence.forEach { $0.inWinningSequence = true }
    }
    
    private func hasWin(_ array: [MarkModel]) -> Bool {
        var arrayToCheck = array
        guard let firstMarkType = arrayToCheck.removeFirst().type else { return false }
        return arrayToCheck.reduce(true) { $0 && $1.type == firstMarkType }
    }
    
    private var hasOpenMarks: Bool {
        markGrid.filter { $0.type == nil }.isEmpty == false
    }
}
