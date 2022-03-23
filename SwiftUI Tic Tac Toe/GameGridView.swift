//
//  GameGridView.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/17/22.
//

import SwiftUI

struct GameGridView: View {
    @StateObject private var model = GameModel()
    private let columns = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            WinStats(stats: model.winPercentage)
            ResultView(gameResult: model.gameResult)
                .padding(.vertical, 30)
            GameGrid(model: model)
            Spacer()
            ResetButton(action: model.resetGame, isShown: model.gameResult != nil)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Subviews

struct WinStats: View {
    var stats: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(stats)
                .font(.caption)
                .padding(.horizontal)
        }
    }
}

struct ResultView: View {
    var gameResult: GameResult?
    
    var body: some View {
        VStack(spacing: 0) {
            Text(emoji)
                .font(.system(size: 50))
            Text(message)
                .font(.system(size: 50))
                .opacity(gameResult != nil ? 1 : 0)
        }
    }
    
    private var message: String {
        switch gameResult {
        case .x:
            return "X Wins "
        case .o:
            return "O Wins"
        case .cat:
            return "CAT"
        default:
            return " "
        }
    }
    
    private var emoji: String {
        switch gameResult {
        case .x:
            let winEmoji: Set<String> = ["🥳", "😌", "😎", "🤓", "😜"]
            return winEmoji.randomElement() ?? "🥳"
        case .o:
            let loseEmoji: Set<String> = ["😩", "😵", "👿", "🤬", "🖕"]
            return loseEmoji.randomElement() ?? "😩"
        case .cat:
            return "🐈💨"
        default:
            return " "
        }
    }
}

struct GameGrid: View {
    @ObservedObject var model: GameModel
    private let columns = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(model.markGrid) { mark in
                MarkCell(mark: mark)
            }
        }
        .disabled(model.gameResult != nil)
        .environmentObject(model)
    }
}

struct ResetButton: View {
    let action: () -> Void
    var isShown: Bool
    
    var body: some View {
        Button(action: {
            action()
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
        .opacity(isShown ? 1 : 0)
    }
}

struct GameGridView_Previews: PreviewProvider {
    
    static var previews: some View {
        GameGridView()
        
        ResultView(gameResult: .x)
            .previewLayout(.sizeThatFits)
        
        ResultView(gameResult: .o)
            .previewLayout(.sizeThatFits)
        
        ResultView(gameResult: .cat)
            .previewLayout(.sizeThatFits)
    }
}
