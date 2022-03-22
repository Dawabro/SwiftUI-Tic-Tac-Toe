//
//  MarkCell.swift
//  SwiftUI Tic Tac Toe
//
//  Created by David W. Brown on 3/17/22.
//

import SwiftUI

enum MarkType: String {
    case x = "xmark"
    case o = "circle"
}

struct MarkCell: View {
    let mark: Mark
    private let minSize: CGFloat = 90
    @EnvironmentObject private var model: GameModel
    
    var body: some View {
        Button(action: {
            model.tapped(mark)
        }, label: {
            Image(systemName: mark.type == .x ? "xmark" : "circle")
                .font(.system(size: 50))
                .padding()
                .opacity(mark.type != nil ? 1 : 0)
        })
        .allowsHitTesting(mark.type == nil)
        .frame(maxWidth: .infinity, minHeight: 90)
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .frame(minHeight: minSize)
                .foregroundColor(mark.inWinningSequence ? .green : .blue)
                .opacity(mark.inWinningSequence ? 0.8 : 0.5))
    }
}

struct MarkCell_Previews: PreviewProvider {
    static let model = GameModel()
    
    static var previews: some View {
        MarkCell(mark: Mark(type: nil, inWinningSequence: false))
            .previewLayout(.fixed(width: 100, height: 100))
            .environmentObject(model)
        
        MarkCell(mark: Mark(type: .x, inWinningSequence: false))
            .previewLayout(.fixed(width: 100, height: 100))
            .environmentObject(model)
        
        MarkCell(mark: Mark(type: .o, inWinningSequence: false))
            .previewLayout(.fixed(width: 100, height: 100))
            .environmentObject(model)
        
        MarkCell(mark: Mark(type: .o, inWinningSequence: true))
            .previewLayout(.fixed(width: 100, height: 100))
            .environmentObject(model)
    }
}
