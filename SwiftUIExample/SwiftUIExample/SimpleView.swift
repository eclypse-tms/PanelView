//
//  SimpleView.swift
//  SwiftUIExample
//
//  Created by Nessa Kucuk, Turker on 8/24/24.
//

import SwiftUI
import PanelView

struct SimpleView: View {
    
    let panelId: String
    let selectedBackgroundColor: Color?
    
    init(panelId: String, backgroundColor: Color? = nil) {
        self.panelId = panelId
        self.selectedBackgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(maxWidth: .greatestFiniteMagnitude, 
                       maxHeight: .greatestFiniteMagnitude)
            
            VStack(spacing: 4) {
                Text("Panel")
                    .font(.title)
                Text(panelId)
                    .font(.title2)
            }
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .stroke(style: .init(lineWidth: 1))
                .frame(width: 90, height: 90)
            )
            
            Spacer()
                .frame(maxWidth: .greatestFiniteMagnitude,
                       maxHeight: .greatestFiniteMagnitude)
        }
        .background(selectedBackgroundColor)
    }
}

#Preview {
    SimpleView(panelId: "-3",
               backgroundColor: .yellow)
    .ignoresSafeArea()
}
