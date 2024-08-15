//
//  PanelView+ConfigurationChanges.swift
//  
//
//  Created by eclypse on 7/21/24.
//

import Foundation

extension PanelView {
    func processConfigurationChanges(oldConfig: PanelViewConfiguration, newConfig: PanelViewConfiguration) {
        if oldConfig.orientation != newConfig.orientation {
            //orientation changed
            // we need to expunge the existing panel constraints
            panelMappings.forEach { (indexedPanel, existingPanel) in
                if indexedPanel.index != 0 {
                    // center panel doesn't have any dividers or layout constraints
                    deactivatePanelLayoutConstraints(for: indexedPanel)
                    
                    removePanelDivider(for: indexedPanel)
                }
            }
                        
            mainStackView.layoutIfNeeded()
            
            panelMappings.forEach { (indexedPanel, existingPanel) in
                if indexedPanel.index != 0 {
                    // Configure min width
                    applyMinWidthConstraint(for: existingPanel, using: indexedPanel)
                    
                    // configure max width
                    applyMaxWidthConstraint(for: existingPanel, using: indexedPanel)
                    
                    // configure width
                    applyPreferredWidthConstraint(for: existingPanel, using: indexedPanel)
                }
            }
            
            mainStackView.layoutIfNeeded()
            
            // re-create panel dividers if in multi-panel mode
            if !isSinglePanelMode {
                visiblePanels.forEach { eachVisiblePanelIndex in
                    if let existingPanel = panelMappings[eachVisiblePanelIndex] {
                        if eachVisiblePanelIndex.index != 0, newConfig.allowsUIPanelSizeAdjustment {
                            createPanelDivider(for: eachVisiblePanelIndex)
                        }
                    }
                }
            }
        }
        
        if oldConfig.panelMode != newConfig.panelMode {
            if newConfig.panelMode == .single {
                // when running in single panel mode, we have to disable constraints
                // for all the panels as well as remove all panel dividers since
                // we are only showing one panel at a time
                panelMappings.forEach { (indexedPanel, _) in
                    deactivatePanelLayoutConstraints(for: indexedPanel)
                    removePanelDivider(for: indexedPanel)
                }
                
                // now that all panel constraints are removed, we need to hide all existing panels
                // except the one with the highest index
                if let panelWithTheHighestIndex = visiblePanels.last {
                    visiblePanels.forEach { eachPanelIndex in
                        // hide everything but the last indexed panel
                        if eachPanelIndex != panelWithTheHighestIndex {
                            // hide but do not release the view controller from the view
                            hide(panel: eachPanelIndex, animated: false, releaseViewController: .false)
                        }
                    }
                } else {
                    // there are no visible panels
                    // this may be because we are only showing the empty view
                }
            } else {
                // when switched to multi panel mode, we need to show the center panel
                show(index: 0, animated: false)
                panelMappings.forEach { (indexedPanel, _) in
                    if indexedPanel.index == 0 {
                        // there are no constraints or panel dividers for the center panel
                    } else {
                        activatePanelLayoutConstraintsIfNecessary(for: indexedPanel)
                    }
                }
                
                visiblePanels.forEach { eachPanel in
                    createPanelDivider(for: eachPanel)
                }
            }
            mainStackView.layoutIfNeeded()
        }
        
        if oldConfig.interPanelSpacing != newConfig.interPanelSpacing {
            // mainStackView.spacing = newConfig.interPanelSpacing
        }
        
        if oldConfig.allowsUIPanelSizeAdjustment != newConfig.allowsUIPanelSizeAdjustment {
            panelMappings.forEach { (indexedPanel, existingPanel) in
                if newConfig.allowsUIPanelSizeAdjustment {
                    createPanelDivider(for: indexedPanel)
                } else {
                    removePanelDivider(for: indexedPanel)
                }
            }
        }
        
        if oldConfig.emptyStateView != newConfig.emptyStateView {
            if let validNewEmptyState = newConfig.emptyStateView {
                self.configure(emptyStateView: validNewEmptyState)
            } else {
                self.removeEmptyStateView()
            }
        }
    }
}
