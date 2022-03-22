//
//  GameGridView.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/17/22.
//

import SwiftUI

final class GameModel: ObservableObject {
    @Published var markGrid: [Mark]
    @Published var gameOverMan = false
    @Published var winningMark: MarkType? = nil
    private var gameGridModel: [MarkModel] = [MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel()]
    private var rows = [[MarkModel]]()
    private var columns = [[MarkModel]]()
    private var diagnals = [[MarkModel]]()
    private var playersTurn = true
    private var rateLimiter = RateLimiter(maxRefreshRate: 0.25)
    
    init() {
        self.markGrid = gameGridModel.map { Mark(type: $0.type, inWinningSequence: $0.inWinningSequence) }
        populateSequences()
    }
    
    func tapped(_ mark: Mark) {
        rateLimiter.execute { playerMove(on: mark.id) }
    }
    
    private func playerMove(on id: UUID) {
        guard playersTurn else { return }
        makeMove(on: id)
        
        if hasOpenMarks {
            aiMove()
        } else {
            gameOverMan = true
        }
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
        guard let randomID = randomOpenMarkID else { return }
        makeMove(on: randomID)
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
        let newGrid = gameGridModel.map { Mark(type: $0.type, inWinningSequence: $0.inWinningSequence) }
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

struct GameGridView: View {
    @StateObject private var model = GameModel()
    private let columns = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            Text("🐈")
                .font(.system(size: 80))
                .padding(.vertical, 40)
                .opacity(model.gameOverMan && model.winningMark == nil ? 1 : 0)
            LazyVGrid(columns: columns) {
                ForEach(model.markGrid) { mark in
                    MarkCell(mark: mark)
                }
            }
            .disabled(model.gameOverMan)
            .environmentObject(model)
            
            Spacer()
            
            Button(action: {
                model.resetGame()
            }, label: {
                Label("Reset", systemImage: "gobackward")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.orange)
                            .opacity(0.8)
                    )
            })
            .padding(.bottom)
            .opacity(model.gameOverMan ? 1 : 0)
        }
        .padding(.horizontal, 4)
    }
}

struct GameGridView_Previews: PreviewProvider {
    
    static var previews: some View {
        GameGridView()
    }
}
