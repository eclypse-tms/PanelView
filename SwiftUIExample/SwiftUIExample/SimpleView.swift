//
//  SimpleView.swift
//  SwiftUIExample
//
//  Created by Nessa Kucuk, Turker on 8/24/24.
//

import SwiftUI
import PanelView

struct SimpleView: View {
    
    let panel: Panel
    
    init(index: Int) {
        let onTheFlyPanel = Panel(index: index)
        self.panel = onTheFlyPanel
    }
    
    init(panel: Panel) {
        self.panel = panel
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: .init(lineWidth: 1))
                .frame(width: 90, height: 90)
            
            VStack(spacing: 4) {
                Text("Panel")
                    .font(.title)
                Text("\(panel.index)")
                    .font(.title2)
            }
        }
    }
}

#Preview {
    SimpleView(index: -3)
}
