//
//  PanelView+PanelLayout.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/21/24.
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
        if mainStackView.axis == .horizontal {
            return .width
        } else {
            return .height
        }
    }
    
    /// layout dimension attribute that is used to size the panels widthwise or heightwise
    private var layoutAttributeIdentifier: String {
        if mainStackView.axis == .horizontal {
            return "width"
        } else {
            return "height"
        }
    }
    
    func createPanel(for indexedPanel: Panel) -> UIView {
        let aNewPanel = UIView()
        aNewPanel.tag = indexedPanel.index
        aNewPanel.isHidden = true
        panelMappings[indexedPanel] = aNewPanel
        mainStackView.addArrangedSubview(aNewPanel)
        
        if indexedPanel.index != 0 {
            // Configure min width
            applyMinWidthConstraint(for: aNewPanel, using: indexedPanel)
            
            // configure max width
            applyMaxWidthConstraint(for: aNewPanel, using: indexedPanel)
            
            // configure width
            applyPrefferredWidthConstraint(for: aNewPanel, using: indexedPanel)
            
            // attach its accompanying view divider
            if indexedPanel.index != 0, configuration.allowsUIPanelSizeAdjustment {
                createPanelDivider(associatedPanel: aNewPanel, for: indexedPanel)
            }
        }
        return aNewPanel
    }
    
    func applyMinWidthConstraint(for aNewPanel: UIView, using indexedPanel: Panel) {
        var effectiveMinWidthConstantForPanel: CGFloat = defaultPanelMinWidth
        if let existingMinWidthConstraint = panelMinWidthMappings[indexedPanel] {
            effectiveMinWidthConstantForPanel = existingMinWidthConstraint.constant
        } else if let pendingMinWidthConstraint = pendingMinimumWidth[indexedPanel] {
            effectiveMinWidthConstantForPanel = pendingMinWidthConstraint
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
        }
        
        let maxWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                    attribute: layoutAttribute,
                                                    relatedBy: .lessThanOrEqual,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: effectiveMaxWidthConstantForPanel)
        maxWidthConstraint.isActive = true
        maxWidthConstraint.identifier = "max \(layoutAttributeIdentifier): panel: \(indexedPanel.index)"
        panelMaxWidthMappings[indexedPanel] = maxWidthConstraint
    }
    
    func applyPrefferredWidthConstraint(for aNewPanel: UIView, using indexedPanel: Panel) {
        var effectiveWidthConstantForPanel: CGFloat = 475
        
        if let existingWidthConstraint = panelWidthMappings[indexedPanel] {
            effectiveWidthConstantForPanel = existingWidthConstraint.constant
        } else if let savedWidthFraction = pendingWidthFraction[indexedPanel] {
            if mainStackView.axis == .horizontal {
                effectiveWidthConstantForPanel = view.frame.width * savedWidthFraction
            } else {
                effectiveWidthConstantForPanel = view.frame.height * savedWidthFraction
            }
        }
        
        let widthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                    attribute: layoutAttribute,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1.0,
                                                    constant: effectiveWidthConstantForPanel)
        widthConstraint.priority = .defaultHigh
        widthConstraint.isActive = true
        widthConstraint.identifier = "\(layoutAttributeIdentifier): panel: \(indexedPanel.index)"
        panelWidthMappings[indexedPanel] = widthConstraint
    }
    
    func deactivatePanelLayoutConstraints(for indexedPanel: Panel) {
        if let aConstraint = panelMaxWidthMappings[indexedPanel] {
            aConstraint.isActive = false
            panelMaxWidthMappings.removeValue(forKey: indexedPanel)
        }
        
        if let aConstraint = panelMinWidthMappings[indexedPanel] {
            aConstraint.isActive = false
            panelMinWidthMappings.removeValue(forKey: indexedPanel)
        }
        
        if let aConstraint = panelWidthMappings[indexedPanel] {
            aConstraint.isActive = false
            panelWidthMappings.removeValue(forKey: indexedPanel)
        }
    }
}