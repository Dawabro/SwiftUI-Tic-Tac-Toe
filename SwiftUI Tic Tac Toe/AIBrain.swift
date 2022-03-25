//
//  AIBrain.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/22/22.
//

import Foundation

struct AIBrain {
    typealias MarkSequence = [MarkModel]
    
    let sequences: [[MarkSequence]]
    let myMark: MarkType
    
    func moveID() -> UUID? {
        [winMoveID, blockMoveID, opponentIntersectionID, middleMarkID, randomOpenMarkID].compactMap({ $0 }).first
    }
    
    private var winMoveID: UUID? {
        sequences.flatMap { winMoves(for: myMark, in: $0) }.randomElement()?.id
    }
    
    private var blockMoveID: UUID? {
        let availableBlockMoves = sequences.flatMap { winMoves(for: oppenentsMark, in: $0) }
        
        switch availableBlockMoves.count {
        case 0:
            return nil
        case 1:
            return availableBlockMoves.first?.id
        default:
            // Currently picking random block move, update to choose "best" block move (i.e. can I block two lines)
            return availableBlockMoves.randomElement()?.id
        }
    }
    
    private var opponentIntersectionID: UUID? {
        let liveOpponentSequencesWithOpenMoves = liveSequencesOccupiedByOpponent.filter { hasOpenMoves($0) }
        let intersections = allIntersectionsIn(sequences: liveOpponentSequencesWithOpenMoves)
        let openIntersectionMoves = openMoveIDs(fromIDs: intersections)
        guard !openIntersectionMoves.isEmpty else { return nil }
        return mostCommonID(in: openIntersectionMoves)
    }
    
    private func allIntersectionsIn(sequences: [MarkSequence]) -> [UUID] {
        var resultIDs = [UUID]()
        
        sequences.forEach { sequence in
            resultIDs.append(contentsOf: allIntersectionsBetween(sequence: sequence, comparisonSequences: sequences))
        }
        
        return resultIDs
    }
    
    private func allIntersectionsBetween(sequence: MarkSequence, comparisonSequences: [MarkSequence]) -> [UUID] {
        var comparisonSequences = comparisonSequences
        comparisonSequences.removeAll(where: { $0 == sequence })
        var resultIDs = [UUID]()
        
        comparisonSequences.forEach { comparisonSequence in
            resultIDs.append(contentsOf: idsOfIntersectionsBetween(sequenceA: sequence, sequenceB: comparisonSequence))
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
    
    private var middleMarkID: UUID? {
        let allBlockIDs = allMarkModels.map { $0.id }
        let middleModelID = mostCommonID(in: allBlockIDs)
        guard let middleModel = markModel(withID: middleModelID), middleModel.type == nil else { return nil }
        return middleModelID
    }
    
    private var randomOpenMarkID: UUID? {
        let openMarks = sequences.flatMap { $0.flatMap { openMoves($0) } }
        return openMarks.randomElement()?.id
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
    
    private func openMoveIDs(fromIDs ids: [UUID]) -> [UUID] {
        let models = sequences.flatMap { $0 }.flatMap{ $0 }.filter { ids.contains($0.id) }
        return openMoves(models).map { $0.id }
    }
    
    private func markTypesIn(_ sequence: MarkSequence) -> Set<MarkType> {
        Set(sequence.compactMap { $0.type })
    }
    
    private func idsOfIntersectionsBetween(sequenceA: MarkSequence, sequenceB: MarkSequence) -> [UUID] {
        let intersections = Set(sequenceA.map { $0.id }).intersection(sequenceB.map { $0.id })
        return Array(intersections)
    }
    
    private func mostCommonID(in ids: [UUID]) -> UUID? {
        let countedSet = NSCountedSet(array: ids)
        return countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) } as? UUID
    }
    
    private func markModel(withID id: UUID?) -> MarkModel? {
        allMarkModels.first { $0.id == id }
    }
    
    private var allMarkModels: [MarkModel] {
        sequences.flatMap { $0.flatMap { $0.map { $0 } } }
    }
}
