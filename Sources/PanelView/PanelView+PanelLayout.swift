//
//  PanelView+PanelLayout.swift
//
//
//  Created by eclypse on 7/21/24.
//

import UIKit

extension PanelView {
    private var defaultPanelMinWidth: CGFloat {
        320
    }
    
    private var defaultPanelMaxWidth: CGFloat {
        768
    }
    
    /// layout dimension attribute that is used to size the panels widthwise or heightwise
    private var layoutAttribute: NSLayoutConstraint.Attribute {
        if configuration.orientation == .horizontal {
            return .width
        } else {
            return .height
        }
    }
    
    /// layout dimension attribute that is used to size the panels widthwise or heightwise
    private var layoutAttributeIdentifier: String {
        if configuration.orientation == .horizontal {
            return "width"
        } else {
            return "height"
        }
    }
    
    func layoutIfNeeded() {
        mainStackView.layoutIfNeeded()
    }
    
    @discardableResult
    func getPanel(for indexedPanel: PanelIndex) -> UIView {
        return panelMappings[indexedPanel]!
        /*
        let aNewPanel = UIView()
        aNewPanel.translatesAutoresizingMaskIntoConstraints = false
        aNewPanel.tag = indexedPanel.index
        aNewPanel.isHidden = true
        panelMappings[indexedPanel] = aNewPanel
        mainStackView.addArrangedSubview(aNewPanel)
        
        if indexedPanel.index != 0 {
            
            if isSinglePanelMode {
                // when running in single panel mode
                // we do not need to apply any constraints to any
                // panel because there is only one panel and it takes
                // up the entirity of the screen
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
        */
    }
    
    func applyMinWidthConstraint(for aNewPanel: UIView, using indexedPanel: PanelIndex) {
        let effectiveMinWidthConstantForPanel: CGFloat
        if let existingMinWidthConstraint = panelMinWidthMappings[indexedPanel] {
            effectiveMinWidthConstantForPanel = existingMinWidthConstraint.constant
            
            // if there is already an existing constraint deactivate it
            if existingMinWidthConstraint.isActive {
                existingMinWidthConstraint.isActive = false
            }
            
        } else if let pendingMinWidthConstraint = pendingMinimumWidth[indexedPanel] {
            effectiveMinWidthConstantForPanel = pendingMinWidthConstraint
        } else {
            print("PanelView - we couldn't find minimum width constraint for panel: \(indexedPanel.index). applying default values.")
            effectiveMinWidthConstantForPanel = defaultPanelMinWidth
        }
        
        let minWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                    attribute: layoutAttribute,
                                                    relatedBy: .greaterThanOrEqual,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: effectiveMinWidthConstantForPanel)
        
        minWidthConstraint.isActive = true
        minWidthConstraint.identifier = "min \(layoutAttributeIdentifier): panel: \(indexedPanel.index)"
        panelMinWidthMappings[indexedPanel] = minWidthConstraint
        
    }
    
    func applyMaxWidthConstraint(for aNewPanel: UIView, using indexedPanel: PanelIndex) {
        
        let effectiveMaxWidthConstantForPanel: CGFloat
        if let existingMaxWidthConstraint = panelMaxWidthMappings[indexedPanel] {
            effectiveMaxWidthConstantForPanel = existingMaxWidthConstraint.constant
            
            // if there is already an existing constraint deactivate it
            if existingMaxWidthConstraint.isActive {
                existingMaxWidthConstraint.isActive = false
            }
            
        } else if let pendingMaxWidthConstraint = pendingMaximumWidth[indexedPanel] {
            effectiveMaxWidthConstantForPanel = pendingMaxWidthConstraint
        } else {
            print("PanelView - we couldn't find maximum width constraint for panel: \(indexedPanel.index). applying default values.")
            effectiveMaxWidthConstantForPanel = defaultPanelMaxWidth
        }
        
        let maxWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                    attribute: layoutAttribute,
                                                    relatedBy: .lessThanOrEqual,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: effectiveMaxWidthConstantForPanel)
        maxWidthConstraint.priority = UILayoutPriority(750)
        maxWidthConstraint.isActive = true
        maxWidthConstraint.identifier = "max \(layoutAttributeIdentifier): panel: \(indexedPanel.index)"
        panelMaxWidthMappings[indexedPanel] = maxWidthConstraint
        
    }
    
    func applyPreferredWidthConstraint(for aNewPanel: UIView, using indexedPanel: PanelIndex) {
        
        let effectiveWidthConstantForPanel: CGFloat
    
        if let existingWidthConstraint = panelWidthMappings[indexedPanel] {
            effectiveWidthConstantForPanel = existingWidthConstraint.constant
            
            // if there is already an existing constraint deactivate it
            if existingWidthConstraint.isActive {
                existingWidthConstraint.isActive = false
            }
            
        } else if let savedWidthFraction = pendingWidthFraction[indexedPanel] {
            if configuration.orientation == .horizontal {
                effectiveWidthConstantForPanel = view.frame.width * savedWidthFraction
            } else {
                effectiveWidthConstantForPanel = view.frame.height * savedWidthFraction
            }
        } else {
            print("PanelView - we couldn't find width constraint for panel: \(indexedPanel.index). applying default values.")
            effectiveWidthConstantForPanel = 450
        }
        
        let widthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                    attribute: layoutAttribute,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: effectiveWidthConstantForPanel)
        
        widthConstraint.priority = UILayoutPriority(999)
        widthConstraint.isActive = true
        widthConstraint.identifier = "\(layoutAttributeIdentifier): panel: \(indexedPanel.index)"
        panelWidthMappings[indexedPanel] = widthConstraint
        
    }
    
    func activatePanelLayoutConstraintsIfNecessary(for indexedPanel: PanelIndex) {
        if let aConstraint = panelMaxWidthMappings[indexedPanel] {
            if aConstraint.isActive {
                // nothing to do - max constraint is already active
            } else {
                if let correspondingView = panelMappings[indexedPanel] {
                    applyMaxWidthConstraint(for: correspondingView, using: indexedPanel)
                } else {
                    print("PanelView - there is no corresponding panel view for the index: \(indexedPanel.index)")
                }
            }
        } else {
            if let correspondingView = panelMappings[indexedPanel] {
                applyMaxWidthConstraint(for: correspondingView, using: indexedPanel)
            } else {
                print("PanelView - there is no corresponding panel view for the index: \(indexedPanel.index)")
            }
        }
        
        if let aConstraint = panelMinWidthMappings[indexedPanel] {
            if aConstraint.isActive {
                // nothing to do - min constraint is already active
            } else {
                if let correspondingView = panelMappings[indexedPanel] {
                    applyMinWidthConstraint(for: correspondingView, using: indexedPanel)
                } else {
                    print("PanelView - there is no corresponding panel view for the index: \(indexedPanel.index)")
                }
            }
        }
        
        if let aConstraint = panelWidthMappings[indexedPanel] {
            if aConstraint.isActive {
                // nothing to do - width constraint is already active
            } else {
                if let correspondingView = panelMappings[indexedPanel] {
                    applyPreferredWidthConstraint(for: correspondingView, using: indexedPanel)
                } else {
                    print("PanelView - there is no corresponding panel view for the index: \(indexedPanel.index)")
                }
            }
        }
        
        /*
        if doWeNeedToRecreatePanel {
            createPanel(for: indexedPanel)
        }
        */
    }
    
    func deactivatePanelLayoutConstraints(for indexedPanel: PanelIndex) {
        if let aConstraint = panelMaxWidthMappings[indexedPanel] {
            aConstraint.isActive = false
        }
        
        
        if let aConstraint = panelMinWidthMappings[indexedPanel] {
            // aConstraint.isActive = false
        }
        
        
        if let aConstraint = panelWidthMappings[indexedPanel] {
            aConstraint.isActive = false
        }
    }
}
