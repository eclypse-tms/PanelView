//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by Nessa Kucuk, Turker on 8/22/24.
//

import SwiftUI
import PanelView

struct ContentView: View {
    @State private var singlePanelMode = false
    @State private var showCenterPanel = false
    @State private var showEmptyView = false
    @State private var useComplexViews = false
    @Environment(\.colorScheme) private var dayOrNightMode
    private let panelView: SwiftPanel
    
    
    init() {
        panelView = SwiftPanel(configuration: .init())
    }
    
    var body: some View {
        let panelBackground = dayOrNightMode == .light ? Color.white : Color.black
        

        ZStack {
            panelView
                .show(centralPanel: SimpleView(panelId: "center", backgroundColor: .blue))
            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 8) {
                    VStack(spacing: 4, content: {
                        Text("Left Panels")
                        MultiSelectButton(buttonTitles: ["-5", "-4", "-3", "-2", "-1"], actions: { buttonInfo in
                            let panelIndex = Int(buttonInfo.title)!
                            
                            if buttonInfo.state == .selected {
                                self.panelView.show(SimpleView(panelId: buttonInfo.title), at: panelIndex)
                            } else {
                                self.panelView.hide(index: panelIndex)
                            }
                        })
                    })
                    .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    .background(panelBackground)
                    .clipShape(.rect(cornerRadius: 8))
                    
                    Spacer()
                        .frame(minWidth: 20)
                    
                    VStack(spacing: 12, content: {
                        Toggle(isOn: $singlePanelMode, label: {
                            Text("Single panel mode")
                        })
                        Toggle(isOn: $showEmptyView, label: {
                            Text("Show empty view")
                        })
                        Toggle(isOn: $useComplexViews, label: {
                            Text("Use complex views")
                        })
                        HStack(spacing: 20, content: {
                            Text("Center panel")
                            MultiSelectButton(buttonTitles: ["0"], initialSelections: [0], actions: { buttonInfo in
                                if buttonInfo.state == .selected {
                                    panelView.show(SimpleView(panelId: "center"), at: 0)
                                } else {
                                    panelView.hide(index: 0)
                                }
                            })
                        })
                    })
                    .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    .background(panelBackground)
                    .clipShape(.rect(cornerRadius: 8))
                    .frame(minWidth: 240)
                    
                    Spacer()
                        .frame(minWidth: 20)
                    
                    VStack(spacing: 4, content: {
                        Text("Right Panels")
                        MultiSelectButton(buttonTitles: ["1", "2", "3", "4", "5"], actions: { buttonInfo in
                            let panelIndex = Int(buttonInfo.title)!
                            
                            if buttonInfo.state == .selected {
                                self.panelView.show(SimpleView(panelId: buttonInfo.title), at: panelIndex)
                            } else {
                                self.panelView.hide(index: panelIndex)
                            }
                        })
                        
                    })
                    .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    .background(panelBackground)
                    .clipShape(.rect(cornerRadius: 8))
                    
                }
            }
            .padding(20)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea()
}
