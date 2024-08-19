//
//  PanelView+PanelCreation.swift
//
//
//  Created by eclypse on 8/19/24.
//

import UIKit

extension PanelView {
    @discardableResult
    func createPanel(for indexedPanel: Panel) -> UIView {
        let aNewPanel = UIView()
        aNewPanel.translatesAutoresizingMaskIntoConstraints = false
        aNewPanel.tag = indexedPanel.index
        aNewPanel.layer.zPosition = CGFloat(100 + indexedPanel.index)
        aNewPanel.isHidden = true
        panelMappings[indexedPanel] = aNewPanel
        mainStackView.addArrangedSubview(aNewPanel)
        
        if indexedPanel.index != 0 {
            
            if isSinglePanelMode {
                // when running in single panel mode
                // we only need to apply the min-width constraint to prevent navigation bar
                // layout constraints complaints
                applyMinWidthConstraint(for: aNewPanel, using: indexedPanel)
            } else {
                // Configure min width
                applyMinWidthConstraint(for: aNewPanel, using: indexedPanel)
                
                // configure max width
                applyMaxWidthConstraint(for: aNewPanel, using: indexedPanel)
                
                // configure width
                applyPreferredWidthConstraint(for: aNewPanel, using: indexedPanel)
            }
        }
        return aNewPanel
    }
}
