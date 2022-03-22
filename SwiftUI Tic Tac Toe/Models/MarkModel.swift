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
