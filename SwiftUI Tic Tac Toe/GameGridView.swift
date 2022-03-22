//
//  GameGridView.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/17/22.
//

import SwiftUI

final class MarkModel: ObservableObject {
    var type: MarkType?
    var inWinningSequence = false
    
    init(type: MarkType?) {
        self.type = type
    }
    
    convenience init() {
        self.init(type: nil)
    }
}

struct Mark: Identifiable {
    let id: UUID
    let type: MarkType?
    let inWinningSequence: Bool
    
    init(type: MarkType?, inWinningSequence: Bool) {
        self.id = UUID()
        self.type = type
        self.inWinningSequence = inWinningSequence
    }
    
    init() {
        self.init(type: nil, inWinningSequence: false)
    }
}

final class GridIndexes {
    private let columnCount: Int
    private let rowCount: Int
    private let totalItems: Int
    private(set) var rowIndexes = [[Int]]()
    private(set) var columnIndexes = [[Int]]()
    private(set) var diagnalIndexes = [[Int]]()
    
    init(columns: Int, rows: Int) {
        self.columnCount = columns
        self.rowCount = rows
        self.totalItems = (columns * rows)
        calculateIndicies()
    }
    
    private func calculateIndicies() {
        calculateRows()
        calculateColumns()
        calculateDiagnals()
    }
    
    private func calculateRows() {
        rowIndexes = stride(from: 0, to: totalItems, by: columnCount).map {
            Array([$0..<Swift.min($0 + columnCount, totalItems)]).flatMap { $0.map { $0 } }
        }
    }
    
    private func calculateColumns() {
        columnIndexes = []
        
        for c in 0..<columnCount {
            let columns = stride(from: c, to: totalItems, by: columnCount).map { $0 }
            var newColumn = [Int]()
            columns.forEach { index in
                newColumn.append(index)
            }
            columnIndexes.append(newColumn)
        }
    }
    
    private func calculateDiagnals() {
        let leftToRightDiagnal = stride(from: 0, to: totalItems, by: (columnCount + 1)).map { $0 }
        let rightToLeftDiagnal = stride(from: (totalItems - columnCount), to: 0, by: -(columnCount - 1)).map { $0 }.sorted()
        diagnalIndexes = [leftToRightDiagnal, rightToLeftDiagnal]
    }
}

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
        let indicies = GridIndexes(columns: 3, rows: 3)
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
