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
    private var gameGridModel: [MarkModel] = [MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel()]
    private var rows = [[MarkModel]]()
    private var columns = [[MarkModel]]()
    private var diagnals = [[MarkModel]]()
    private var playersTurn = true
    
    init() {
        self.markGrid = gameGridModel.map { Mark(type: $0.type, inWinningSequence: $0.inWinningSequence) }
        populateSequences()
    }
    
    func tapped(_ mark: Mark) {
        guard let index = markGrid.firstIndex(where: { $0.id == mark.id }) else { return }
        print(index)
        gameGridModel[index].type = .x
        checkForWin()
        updateMarkGrid()
    }
    
    func resetGame() {
        gameGridModel = [MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel(), MarkModel()]
        populateSequences()
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
}

struct GameGridView: View {
    @StateObject private var model = GameModel()
    private let columns = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            Spacer()
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
