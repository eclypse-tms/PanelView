//
//  PanelView+CreatePanel.swift
//
//
//  Created by eclypse on 8/18/24.
//

import UIKit

extension PanelView {
    /// creates a new panel and adds it to the panel container
    /// only creates min, max and preferred width constraints
    @discardableResult
    func createPanel(for indexedPanel: PanelIndex) -> UIView {
        let aNewPanel = UIView()
        aNewPanel.translatesAutoresizingMaskIntoConstraints = false
        aNewPanel.tag = indexedPanel.index
        // aNewPanel.isHidden = true // no need to hide anything
        aNewPanel.layer.zPosition = CGFloat(100 + indexedPanel.index)
        panelMappings[indexedPanel] = aNewPanel
        mainStackView.addSubview(aNewPanel)
        
        if indexedPanel.index != 0 {
            
            if isSinglePanelMode {
                // when running in single panel mode, we need to create the panel outside of the viewport
                // then with animations we will bring the panel back into the viewport
                
                
            } else {
                // Configure min width
                applyMinWidthConstraint(for: aNewPanel, using: indexedPanel)
                
                // configure max width
                applyMaxWidthConstraint(for: aNewPanel, using: indexedPanel)
                
                // configure width
                applyPreferredWidthConstraint(for: aNewPanel, using: indexedPanel)
                
                // attach its accompanying view divider
                /*
                if indexedPanel.index != 0, configuration.allowsUIPanelSizeAdjustment {
                    createPanelDivider(associatedPanel: aNewPanel, for: indexedPanel)
                }
                */
            }
        }
        
        return aNewPanel
    }
}
