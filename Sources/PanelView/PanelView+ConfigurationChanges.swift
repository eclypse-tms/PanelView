//
//  PanelView+ConfigurationChanges.swift
//  
//
//  Created by Nessa Kucuk, Turker on 7/21/24.
//

import Foundation

extension PanelView {
    func processConfigurationChanges(oldConfig: PanelViewConfiguration, newConfig: PanelViewConfiguration) {
        if oldConfig.orientation != configuration.orientation {
            //orientation changed
            // we need to expunge the existing panel constraints
            panelMappings.forEach { (indexedPanel, existingPanel) in
                if indexedPanel.index != 0 {
                    // center panel doesn't have any dividers or layout constraints
                    deactivatePanelLayoutConstraints(for: indexedPanel)
                    
                    removePanelDivider(for: indexedPanel)
                }
            }
            
            mainStackView.axis = configuration.orientation.axis
            
            panelMappings.forEach { (indexedPanel, existingPanel) in
                if indexedPanel.index != 0 {
                    // Configure min width
                    applyMinWidthConstraint(for: existingPanel, using: indexedPanel)
                    
                    // configure max width
                    applyMaxWidthConstraint(for: existingPanel, using: indexedPanel)
                    
                    // configure width
                    applyPrefferredWidthConstraint(for: existingPanel, using: indexedPanel)
                    
                    // attach its accompanying view divider
                    if indexedPanel.index != 0, configuration.allowsUIPanelSizeAdjustment {
                        createPanelDivider(associatedPanel: existingPanel, for: indexedPanel)
                    }
                }
            }
        }
        
        if oldConfig.interPanelSpacing != configuration.interPanelSpacing {
            mainStackView.spacing = configuration.interPanelSpacing
        }
        
        if oldConfig.allowsUIPanelSizeAdjustment != configuration.allowsUIPanelSizeAdjustment {
            panelMappings.forEach { (indexedPanel, existingPanel) in
                if configuration.allowsUIPanelSizeAdjustment {
                    createPanelDivider(associatedPanel: existingPanel, for: indexedPanel)
                } else {
                    removePanelDivider(for: indexedPanel)
                }
            }
        }
    }
}
