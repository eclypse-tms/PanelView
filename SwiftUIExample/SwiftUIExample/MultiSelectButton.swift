//
//  MultiSelectButton.swift
//  SwiftUIExample
//
//  Created by Nessa Kucuk, Turker on 8/25/24.
//

import SwiftUI
import Combine

struct MultiSelectButton: View {
    @State private var selectedButtons: Set<Int>
    private let buttonTitles: [String]
    private let actions: (ButtonInfo) -> Void
    
    
    init(buttonTitles: [String],
         initialSelections: [Int] = [], // nothing is selected by default
         actions: @escaping (ButtonInfo) -> Void) {
        self.buttonTitles = buttonTitles
        self.actions = actions
        
        selectedButtons = (Set().union(initialSelections))
    }
    
    var body: some View {
        let numberOfButtons: Range<Int> = 0..<buttonTitles.count
        
        HStack(spacing: 2) {
            ForEach(numberOfButtons, id: \.self, content: { index in
                let buttonTitle = "\(buttonTitles[index])"
                Button(action: {
                    if selectedButtons.contains(index) {
                        selectedButtons.remove(index)
                        actions(ButtonInfo(index: index, title: buttonTitle, state: .unselected))
                    } else {
                        selectedButtons.insert(index)
                        actions(ButtonInfo(index: index, title: buttonTitle, state: .selected))
                    }
                }, label: {
                    if selectedButtons.contains(index) {
                        Text(buttonTitle)
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 4,
                                    style: .continuous
                                )
                                .fill()
                            )
                    } else {
                        Text(buttonTitle)
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 4,
                                    style: .continuous
                                )
                                .stroke(style: .init(lineWidth: 1))
                            )
                    }
                })
            })
        }
    }
}

#Preview {
    MultiSelectButton(buttonTitles: ["0","1","2","3","4"],
                      initialSelections: [0, 2]) { _ in
        
    }
}
