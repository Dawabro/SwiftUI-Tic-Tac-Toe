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
            Text("🐈")
                .font(.system(size: 80))
                .padding(.vertical, 40)
                .opacity(model.gameOverMan && model.winningMark == nil ? 1 : 0)
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
