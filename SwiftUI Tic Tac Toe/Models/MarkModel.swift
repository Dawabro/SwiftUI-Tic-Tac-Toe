//
//  MarkModel.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/22/22.
//

import Foundation

enum MarkType: String {
    case x = "xmark"
    case o = "circle"
}

final class MarkModel: Equatable, ObservableObject {
    let id: UUID
    var type: MarkType?
    var inWinningSequence = false
    
    init(type: MarkType?) {
        self.id = UUID()
        self.type = type
    }
    
    convenience init() {
        self.init(type: nil)
    }
    
    static func == (lhs: MarkModel, rhs: MarkModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct Mark: Identifiable {
    let id: UUID
    let type: MarkType?
    let inWinningSequence: Bool
    let modelID: UUID?
    
    init(type: MarkType?, inWinningSequence: Bool, modelID: UUID? = nil) {
        self.id = UUID()
        self.type = type
        self.inWinningSequence = inWinningSequence
        self.modelID = modelID
    }
    
    init() {
        self.init(type: nil, inWinningSequence: false)
    }
}
