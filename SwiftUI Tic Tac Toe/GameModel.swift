//
//  GameModel.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/22/22.
//

import Combine
import Foundation

enum GameResult {
    case x
    case o
    case cat
}

final class GameModel: ObservableObject {
    @Published var markGrid: [Mark]
    @Published var gameResult: GameResult?
    @Published var winPercentage = ""
    private var gameGridModel: [MarkModel] = [MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel()]
    private var rows = [[MarkModel]]()
    private var columns = [[MarkModel]]()
    private var diagnals = [[MarkModel]]()
    private var playersTurn = true
    private var aiThinking = false
    private let aiThinkTime = 0.4...0.75
    private var rateLimiter = RateLimiter(maxRefreshRate: 0.25)
    private var gameStats = GameStats()
    private var subscriptions = Set<AnyCancellable>()
    private let winPercentageFormatter = NumberFormatter()
    
    init() {
        self.markGrid = gameGridModel.map { Mark(type: $0.type, inWinningSequence: $0.inWinningSequence, modelID: $0.id) }
        self.winPercentageFormatter.numberStyle = .percent
        populateSequences()
        self.setupPublishers()
    }
    
    private func setupPublishers() {
        $gameResult.sink { newResult in
            self.updateStats(newResult)
        }.store(in: &subscriptions)
    }
    
    func tapped(_ mark: Mark) {
        guard !aiThinking else { return }
        rateLimiter.execute { playerMove(on: mark.id) }
        
        guard gameResult == nil else { return }
        if hasOpenMarks {
            makeAIMove()
        } else {
            gameResult = .cat
        }
    }
    
    private func playerMove(on id: UUID) {
        guard playersTurn else { return }
        makeMove(on: id)
    }
    
    private func makeAIMove() {
        aiThinking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + randomAIThinkTime, execute: aiMove)
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
        let aiBrain = AIBrain(grid: markGrid, sequences: [rows, columns, diagnals], myMark: .o)
        guard let aiMarkID = aiBrain.moveID() else { return }
        makeMove(on: aiMarkID)
        aiThinking = false
    }
    
    func resetGame() {
        gameGridModel = [MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel()]
        populateSequences()
        gameResult = nil
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
        guard checkForWinningSequence(rows) || checkForWinningSequence(columns) || checkForWinningSequence(diagnals) else { return }
        gameResult = playersTurn ? .x : .o
    }
    
    private func checkForWinningSequence(_ array: [[MarkModel]]) -> Bool {
        for markSequence in array {
            if hasWin(markSequence) {
                markWinningSequence(markSequence)
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
    
    private func updateStats(_ result: GameResult?) {
        guard let result = result else { return }
        switch result {
        case .x:
            gameStats.addWin()
        case .o:
            gameStats.addLose()
        case .cat:
            self.gameStats.addTie()
        }
        
        winPercentage = winPercentageFormatter.string(from: NSNumber(value: gameStats.winPercentage)) ?? "%0.0"
    }
}
