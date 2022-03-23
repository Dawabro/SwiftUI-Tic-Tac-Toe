//
//  GameStats.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/23/22.
//

import Foundation

struct GameStats {
    var gamesPlayed: Double
    var wins: Double
    var loses: Double
    
    init() {
        self.gamesPlayed = 0
        self.wins = 0
        self.loses = 0
    }
    
    var winPercentage: Double {
        guard gamesPlayedWithoutTie > 0 else { return 0.0 }
        return wins / gamesPlayedWithoutTie
    }
    
    private var gamesPlayedWithoutTie: Double {
        gamesPlayed - numOfTies
    }
    
    private var numOfTies: Double {
        gamesPlayed - (wins + loses)
    }
    
    mutating func addWin() {
        gamesPlayed += 1
        wins += 1
    }
    
    mutating func addLose() {
        gamesPlayed += 1
        loses += 1
    }
    
    mutating func addTie() {
        gamesPlayed += 1
    }
}
