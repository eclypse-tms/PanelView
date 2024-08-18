//
//  PanelView+SinglePanelMode.swift
//
//
//  Created by Nessa Kucuk, Turker on 8/17/24.
//

import Foundation

extension PanelView {
    func expandStackView(panelToShow: PanelIndex) {
        // we hide all other visible panels
        
        if self.isSinglePanelMode {
            if let visiblePanel = currentlyVisiblePanel {
                if panelToShow.index < visiblePanel.index {
                    // panel we are about to show is on the left hand side or the top side (depending on the orientation)
                    if configuration.orientation == .horizontal {
                        // the stack view needs to expand to the left hand side of the screen
                        mainStackViewLeadingConstraint.constant = -mainStackView.frame.width
                    } else {
                        // the stack view needs to expand to the top side of the screen
                        mainStackViewTopConstraint.constant = -mainStackView.frame.height
                    }
                } else {
                    // panel we are about to show is on the right hand side or the bottom side (depending on the orientation)
                    if configuration.orientation == .horizontal {
                        // the stack view needs to expand to the right hand side of the screen
                        mainStackViewTrailingConstraint.constant = -mainStackView.frame.width
                    } else {
                        // the stack view needs to expand to the top side of the screen
                        mainStackViewBottomConstraint.constant = -mainStackView.frame.height
                    }
                }
            } else {
                // there are no visible panels, no need to expand the stack view
            }
        } else {
            // there is no need to expand stack view in multi panel mode
        }
    }
    
    func slideStackView() {
        if mainStackViewLeadingConstraint.constant != 0 {
            let currentConstantValue = mainStackViewLeadingConstraint.constant
            mainStackViewTrailingConstraint.constant = currentConstantValue
            mainStackViewLeadingConstraint.constant = 0
        }
        
        if mainStackViewTrailingConstraint.constant != 0 {
            let currentConstantValue = mainStackViewTrailingConstraint.constant
            mainStackViewLeadingConstraint.constant = currentConstantValue
            mainStackViewTrailingConstraint.constant = 0
        }
        
        if mainStackViewTopConstraint.constant != 0 {
            let currentConstantValue = mainStackViewTopConstraint.constant
            mainStackViewBottomConstraint.constant = currentConstantValue
            mainStackViewTopConstraint.constant = 0
        }
        
        
        if mainStackViewBottomConstraint.constant != 0 {
            let currentConstantValue = mainStackViewBottomConstraint.constant
            mainStackViewTopConstraint.constant = currentConstantValue
            mainStackViewBottomConstraint.constant = 0
        }
    }
    
    func restoreStackViewBackToItsOriginalSize() {
        mainStackViewLeadingConstraint.constant = 0
        mainStackViewTopConstraint.constant = 0
        mainStackViewTrailingConstraint.constant = 0
        mainStackViewBottomConstraint.constant = 0
    }
}
