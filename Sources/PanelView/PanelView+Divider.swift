//
//  PanelView+Divider.swift
//  
//
//  Created by eclypse on 7/21/24.
//

import UIKit

extension PanelView {
    func createPanelDivider(for indexedPanel: Panel) {
        // we cannot create a panel divider for central panel
        guard indexedPanel.index != 0 else { return }
        
        // panel dividers are not usable in single-panel mode because
        // panel dividers are used to resize each panel
        guard !isSinglePanelMode else { return }
        
        if let existingPanelDivider = dividerMappings[indexedPanel] {
            existingPanelDivider.removeFromSuperview()
            dividerMappings.removeValue(forKey: indexedPanel)
            
            dividerToPanelMappings.removeValue(forKey: existingPanelDivider)    
        }
        
        let associatedPanel: UIView
        if let matchingPanel = panelMappings[indexedPanel] {
            associatedPanel = matchingPanel
        } else {
            associatedPanel = createPanel(for: indexedPanel)
        }
        
        
        let viewDivider = UIView()
        viewDivider.tag = indexedPanel.index
        // viewDivider.backgroundColor = .green
        viewDivider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(viewDivider)
        
        if configuration.orientation == .horizontal {
            // the panels are laid out side by side
            var layoutConstraints = [NSLayoutConstraint]()
            layoutConstraints.append(viewDivider.topAnchor.constraint(equalTo: self.view.topAnchor))
            layoutConstraints.append(viewDivider.bottomAnchor.constraint(equalTo: self.view.bottomAnchor))
            layoutConstraints.append(viewDivider.widthAnchor.constraint(equalToConstant: panelDividerWidth))
            
            if indexedPanel.index < 0 {
                // this is a leading side panel, we need to place the divider view on the trailing edge of the panel
                let tempConstraint = viewDivider.trailingAnchor.constraint(equalTo: associatedPanel.trailingAnchor, constant: (panelDividerWidth-1))
                tempConstraint.identifier = "\(_dividerConstraintIdentifier)\(indexedPanel.index)"
                layoutConstraints.append(tempConstraint)
            } else {
                // this is a trailing side panel, we need to place the divider on the leading edge of the panel
                let tempConstraint = viewDivider.leadingAnchor.constraint(equalTo: associatedPanel.leadingAnchor, constant: -(panelDividerWidth-1))
                tempConstraint.identifier = "\(_dividerConstraintIdentifier)\(indexedPanel.index)"
                layoutConstraints.append(tempConstraint)
            }
            
            NSLayoutConstraint.activate(layoutConstraints)
            
        } else {
            // the panels are laid out top to bottom
            var layoutConstraints = [NSLayoutConstraint]()
            layoutConstraints.append(viewDivider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
            layoutConstraints.append(viewDivider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
            layoutConstraints.append(viewDivider.heightAnchor.constraint(equalToConstant: panelDividerWidth))
            
            if indexedPanel.index < 0 {
                // this is a top panel that appears above the central panel. we need to place the divider view on the
                // bottom edge of the panel
                let tempConstraint = viewDivider.bottomAnchor.constraint(equalTo: associatedPanel.bottomAnchor, constant: (panelDividerWidth-1))
                tempConstraint.identifier = "\(_dividerConstraintIdentifier)\(indexedPanel.index)"
                layoutConstraints.append(tempConstraint)
            } else {
                // this is a bottom panel that appears below the central panel. we need to place the divider view
                // on the top edge of the panel
                let tempConstraint = viewDivider.topAnchor.constraint(equalTo: associatedPanel.topAnchor, constant: -(panelDividerWidth-1))
                tempConstraint.identifier = "\(_dividerConstraintIdentifier)\(indexedPanel.index)"
                layoutConstraints.append(tempConstraint)
            }
            
            NSLayoutConstraint.activate(layoutConstraints)
        }
        
        dividerMappings[indexedPanel] = viewDivider
        
        dividerToPanelMappings[viewDivider] = indexedPanel
        
        if configuration.allowsUIPanelSizeAdjustment {
            enableResizing(for: indexedPanel)
        }
    }
    
    func removePanelDivider(for indexedPanel: Panel) {
        if let viewDivider = dividerMappings[indexedPanel] {
            viewDivider.removeFromSuperview()
            dividerToPanelMappings.removeValue(forKey: viewDivider)
            dividerMappings.removeValue(forKey: indexedPanel)
        }
    }
}
