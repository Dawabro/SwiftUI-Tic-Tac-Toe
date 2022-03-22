//
//  GridIndexGenerator.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/22/22.
//

import Foundation

final class GridIndexGenerator {
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
