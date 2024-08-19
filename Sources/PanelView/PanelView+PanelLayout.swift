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
    var layoutAttributeIdentifier: String {
        if configuration.orientation == .horizontal {
            return "width"
        } else {
            return "height"
        }
    }
    
    func layoutIfNeeded() {
        mainStackView.layoutIfNeeded()
    }
    
    func applyMinWidthConstraint(for aNewPanel: UIView, using indexedPanel: Panel) {
        var effectiveMinWidthConstantForPanel: CGFloat = defaultPanelMinWidth
        if let existingMinWidthConstraint = panelMinWidthMappings[indexedPanel] {
            effectiveMinWidthConstantForPanel = existingMinWidthConstraint.constant
        } else if let pendingMinWidthConstraint = pendingMinimumWidth[indexedPanel] {
            effectiveMinWidthConstantForPanel = pendingMinWidthConstraint
        } else {
            print("PanelView - we couldn't find minimum width constraint for panel: \(indexedPanel.index). applying default values.")
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
    
    func applyMaxWidthConstraint(for aNewPanel: UIView, using indexedPanel: Panel) {
        var effectiveMaxWidthConstantForPanel: CGFloat = defaultPanelMaxWidth
        if let existingMaxWidthConstraint = panelMaxWidthMappings[indexedPanel] {
            effectiveMaxWidthConstantForPanel = existingMaxWidthConstraint.constant
        } else if let pendingMaxWidthConstraint = pendingMaximumWidth[indexedPanel] {
            effectiveMaxWidthConstantForPanel = pendingMaxWidthConstraint
        } else {
            print("PanelView - we couldn't find maximum width constraint for panel: \(indexedPanel.index). applying default values.")
        }
        
        let maxWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                    attribute: layoutAttribute,
                                                    relatedBy: .lessThanOrEqual,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: effectiveMaxWidthConstantForPanel)
        maxWidthConstraint.priority = UILayoutPriority(998.0)
        maxWidthConstraint.isActive = true
        maxWidthConstraint.identifier = "max \(layoutAttributeIdentifier): panel: \(indexedPanel.index)"
        panelMaxWidthMappings[indexedPanel] = maxWidthConstraint
    }
    
    func applyPreferredWidthConstraint(for aNewPanel: UIView, using indexedPanel: Panel) {
        var effectiveWidthConstantForPanel: CGFloat = 475
        
        if let existingWidthConstraint = panelWidthMappings[indexedPanel] {
            effectiveWidthConstantForPanel = existingWidthConstraint.constant
        } else if let savedWidthFraction = pendingWidthFraction[indexedPanel] {
            if configuration.orientation == .horizontal {
                effectiveWidthConstantForPanel = view.frame.width * savedWidthFraction
            } else {
                effectiveWidthConstantForPanel = view.frame.height * savedWidthFraction
            }
        } else {
            print("PanelView - we couldn't find width constraint for panel: \(indexedPanel.index). applying default values.")
        }
        
        let widthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                    attribute: layoutAttribute,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: effectiveWidthConstantForPanel)
        
        widthConstraint.priority = UILayoutPriority(999.0)
        widthConstraint.isActive = true
        widthConstraint.identifier = "\(layoutAttributeIdentifier): panel: \(indexedPanel.index)"
        panelWidthMappings[indexedPanel] = widthConstraint
    }
    
    func activatePanelLayoutConstraintsIfNecessary(for indexedPanel: Panel) {
        func applyMaxWidth() {
            if let correspondingView = panelMappings[indexedPanel] {
                applyMaxWidthConstraint(for: correspondingView, using: indexedPanel)
            } else {
                print("PanelView - there is no corresponding panel view for the index: \(indexedPanel.index)")
            }
        }
        
        func applyMinWidth() {
            if let correspondingView = panelMappings[indexedPanel] {
                applyMinWidthConstraint(for: correspondingView, using: indexedPanel)
            } else {
                print("PanelView - there is no corresponding panel view for the index: \(indexedPanel.index)")
            }
        }
        
        func applyPreferredWidth() {
            if let correspondingView = panelMappings[indexedPanel] {
                applyPreferredWidthConstraint(for: correspondingView, using: indexedPanel)
            } else {
                print("PanelView - there is no corresponding panel view for the index: \(indexedPanel.index)")
            }
        }
        
        if let aConstraint = panelMinWidthMappings[indexedPanel] {
            if aConstraint.isActive {
                if aConstraint.firstAttribute == .width && configuration.orientation == .vertical {
                    // this constraint is for the width but we are in the vertical mode
                    // we need to deactive this constraint and re-apply
                    aConstraint.isActive = false
                    applyMinWidth()
                } else if aConstraint.firstAttribute == .height && configuration.orientation == .horizontal {
                    // this constraint is for the height but we are in the horizontal mode
                    // we need to deactive this constraint and re-apply
                    aConstraint.isActive = false
                    applyMinWidth()
                } else {
                    // nothing to do - max constraint is already active
                }
            } else {
                applyMinWidth()
            }
        }
        
        if let aConstraint = panelMaxWidthMappings[indexedPanel] {
            if aConstraint.isActive {
                if aConstraint.firstAttribute == .width && configuration.orientation == .vertical {
                    // this constraint is for the width but we are in the vertical mode
                    // we need to deactive this constraint and re-apply
                    aConstraint.isActive = false
                    applyMaxWidth()
                } else if aConstraint.firstAttribute == .height && configuration.orientation == .horizontal {
                    // this constraint is for the height but we are in the horizontal mode
                    // we need to deactive this constraint and re-apply
                    aConstraint.isActive = false
                    applyMaxWidth()
                } else {
                    // nothing to do - max constraint is already active
                }
            } else {
                applyMaxWidth()
            }
        }
        
        
        if let aConstraint = panelWidthMappings[indexedPanel] {
            if aConstraint.isActive {
                if aConstraint.firstAttribute == .width && configuration.orientation == .vertical {
                    // this constraint is for the width but we are in the vertical mode
                    // we need to deactive this constraint and re-apply
                    aConstraint.isActive = false
                    applyPreferredWidth()
                } else if aConstraint.firstAttribute == .height && configuration.orientation == .horizontal {
                    // this constraint is for the height but we are in the horizontal mode
                    // we need to deactive this constraint and re-apply
                    aConstraint.isActive = false
                    applyPreferredWidth()
                } else {
                    // nothing to do - max constraint is already active
                }
            } else {
                applyPreferredWidth()
            }
        }
    }
    
    func deactivatePanelLayoutConstraints(for indexedPanel: Panel) {
        if let aConstraint = panelMaxWidthMappings[indexedPanel] {
            aConstraint.isActive = false
        }
        
        // deactivating minimum width constraint causes navigation bar 
        // layout errors in horizontal mode - we will keep the min widht constraint
        /*
        if let aConstraint = panelMinWidthMappings[indexedPanel] {
            pendingMinimumWidth[indexedPanel] = aConstraint.constant
            aConstraint.isActive = false
        }
        */
        
        if let aConstraint = panelWidthMappings[indexedPanel] {
            aConstraint.isActive = false
        }
    }
    
    /// when the PanelView switches from horizontal to vertical, the min width constraint
    /// gets re-created as a min-height constraint
    func deactivateMinWidthConstraintAndReapply(for indexedPanel: Panel) {
        if let aConstraint = panelMinWidthMappings[indexedPanel] {
            aConstraint.isActive = false
        }
        
        if let associatedPanel = panelMappings[indexedPanel] {
            applyMinWidthConstraint(for: associatedPanel, using: indexedPanel)
        }
    }
}
