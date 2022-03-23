//
//  AIBrain.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/22/22.
//

import Foundation

struct AIBrain {
    let grid: [Mark]
    let sequences: [[[MarkModel]]]
    
    func moveID() -> UUID? {
        [winMoveID, bestBlockMoveID, randomOpenMarkID].compactMap({ $0 }).first
    }
    
    private var winMoveID: UUID? {
        let winID = sequences.flatMap { winMoves(for: .o, in: $0) }.randomElement()?.id
        return markIDFrom(modelID: winID)
    }
    
    private var bestBlockMoveID: UUID? {
        let availableBlockMoves = sequences.flatMap { winMoves(for: .x, in: $0) }
        
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
        return grid.first { $0.modelID == modelID }?.id
    }
    
    private func winMoves(for markType: MarkType, in sequence: [[MarkModel]]) -> [MarkModel] {
        return sequence.compactMap { openWinMove(for: markType, in: $0) }
    }
    
    private func openWinMove(for markType: MarkType, in sequence: [MarkModel]) -> MarkModel? {
        guard sequence.filter({ $0.type == markType }).count == 2 else { return nil }
        return sequence.filter({ $0.type == nil }).first
    }
    
    private var randomOpenMarkID: UUID? {
        let openMarks = grid.filter { $0.type == nil }
        return openMarks.randomElement()?.id
    }
}
