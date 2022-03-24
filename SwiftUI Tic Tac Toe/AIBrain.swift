//
//  AIBrain.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/22/22.
//

import Foundation

struct AIBrain {
    typealias MarkSequence = [MarkModel]
    
    let grid: [Mark]
    let sequences: [[MarkSequence]]
    let myMark: MarkType
    
    func moveID() -> UUID? {
        [winMoveID, blockMoveID, opponentIntersectionID, randomOpenMarkID].compactMap({ $0 }).first
    }
    
    private var winMoveID: UUID? {
        let winID = sequences.flatMap { winMoves(for: myMark, in: $0) }.randomElement()?.id
        return markIDFrom(modelID: winID)
    }
    
    private var blockMoveID: UUID? {
        let availableBlockMoves = sequences.flatMap { winMoves(for: oppenentsMark, in: $0) }
        
        switch availableBlockMoves.count {
        case 0:
            return nil
        case 1:
            let modelID = availableBlockMoves.first?.id
            return markIDFrom(modelID: modelID)
        default:
            // Currently picking random block move, update to choose "best" block move (i.e. can I block two lines)
            let modelID = availableBlockMoves.randomElement()?.id
            return markIDFrom(modelID: modelID)
        }
    }
    
    private var opponentIntersectionID: UUID? {
        let liveOpponentSequencesWithOpenMoves = liveSequencesOccupiedByOpponent.filter { hasOpenMoves($0) }
        let intersections = allIntersectionsIn(sequences: liveOpponentSequencesWithOpenMoves)
        let openIntersectionMoves = openMoveIDs(fromIDs: intersections)
        guard !openIntersectionMoves.isEmpty else { return nil }
        let modelID = mostCommonID(in: openIntersectionMoves)
        return markIDFrom(modelID: modelID)
    }
    
    private func allIntersectionsIn(sequences: [MarkSequence]) -> Set<UUID> {
        var resultIDs = Set<UUID>()
        
        sequences.forEach { sequence in
            resultIDs = resultIDs.union(allIntersectionsBetween(sequence: sequence, comparisonSequences: sequences))
        }
        
        return resultIDs
    }
    
    private func allIntersectionsBetween(sequence: MarkSequence, comparisonSequences: [MarkSequence]) -> Set<UUID> {
        var comparisonSequences = comparisonSequences
        comparisonSequences.removeAll(where: { $0 == sequence })
        var resultIDs = Set<UUID>()
        
        comparisonSequences.forEach { comparisonSequence in
            resultIDs = resultIDs.union(idsOfIntersectionsBetween(sequenceA: sequence, sequenceB: comparisonSequence))
        }
        
        return resultIDs
    }
    
    private var liveSequencesOccupiedByOpponent: [MarkSequence] {
        let oppenentSequences = sequences.flatMap { $0 }.filter { markTypesIn($0).contains(oppenentsMark) }
        return oppenentSequences.filter { isLiveSequence($0) }
    }
    
    private func isLiveSequence(_ sequence: MarkSequence) -> Bool {
        guard !sequence.isEmpty else { return false }
        return markTypesIn(sequence).count == 1
    }
    
    private var randomOpenMarkID: UUID? {
        let openMarks = grid.filter { $0.type == nil }
        return openMarks.randomElement()?.id
    }
    
    // TODO: - Refactor so that AIBrain returns modelIDs (this funtion should be removed)
    private func markIDFrom(modelID: UUID?) -> UUID? {
        guard let modelID = modelID else { return nil }
        return grid.first { $0.modelID == modelID }?.id
    }
    
    private func winMoves(for markType: MarkType, in sequences: [MarkSequence]) -> [MarkModel] {
        return sequences.compactMap { openWinMove(for: markType, in: $0) }
    }
    
    private func openWinMove(for markType: MarkType, in sequence: MarkSequence) -> MarkModel? {
        guard sequence.filter({ $0.type == markType }).count == 2 else { return nil }
        return openMoves(sequence).first
    }
    
    // MARK: - Helpers
    
    private var oppenentsMark: MarkType {
        myMark == .x ? .o : .x
    }
    
    private func hasOpenMoves(_ sequence: MarkSequence) -> Bool {
        !openMoves(sequence).isEmpty
    }
    
    private func openMoves(_ sequence: MarkSequence) -> [MarkModel] {
        sequence.filter { $0.type == nil }
    }
    
    private func openMoveIDs(fromIDs ids: Set<UUID>) -> Set<UUID> {
        let models = sequences.flatMap { $0 }.flatMap{ $0 }.filter { ids.contains($0.id) }
        return Set(openMoves(models).map { $0.id })
    }
    
    private func markTypesIn(_ sequence: MarkSequence) -> Set<MarkType> {
        Set(sequence.compactMap { $0.type })
    }
    
    private func idsOfIntersectionsBetween(sequenceA: MarkSequence, sequenceB: MarkSequence) -> Set<UUID> {
        Set(sequenceA.map { $0.id }).intersection(sequenceB.map { $0.id })
    }
    
    private func mostCommonID(in ids: Set<UUID>) -> UUID? {
        let countedSet = NSCountedSet(set: ids)
        return countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) } as? UUID
    }
}
