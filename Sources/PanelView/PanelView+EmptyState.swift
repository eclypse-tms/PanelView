//
//  PanelView+EmptyState.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/24/24.
//

import Foundation

public extension PanelView {
    /// displays the empty state and hides all other visible panels.
    ///
    /// if there was no empty state view provided, this function does nothing
    func showEmptyState() {
        if let validEmptyStateView = _emptyStateBackgroundView {
            // show the empty view
            self.view.bringSubviewToFront(validEmptyStateView)
            validEmptyStateView.isHidden = false
            
            // we are showing the empty state view - switch the background back to the system color
            self.view.backgroundColor = .systemBackground
        }
    }
    
    /// hides the empty state from the view
    func hideEmptyState() {
        if let validEmptyStateView = _emptyStateBackgroundView {
            if let currentEmptyStateViewIndex = self.view.subviews.firstIndex(of: validEmptyStateView),
               currentEmptyStateViewIndex > 0 {
                self.view.sendSubviewToBack(validEmptyStateView)
                validEmptyStateView.isHidden = true
                self.view.backgroundColor = configuration.panelDividerColor
            }
        }
    }
}

extension PanelView {
    /// automatically called by the PanelView functions when there are no
    /// other visible panels
    func displayEmptyStateIfNecessary() {
        if let validEmptyStateView = _emptyStateBackgroundView {
            var atLeastOnePanelVisible = false
            for eachPanel in mainStackView.subviews {
                if !eachPanel.isHidden {
                    // at least one panel is visible
                    atLeastOnePanelVisible = true
                    break
                }
            }
            
            if atLeastOnePanelVisible {
                // since there is at least one panel visible
                // we make sure that background is panel divider color
                self.view.backgroundColor = configuration.panelDividerColor
            } else {
                // all panels are hidden, show the empty view
                self.view.bringSubviewToFront(validEmptyStateView)
                validEmptyStateView.isHidden = false
                
                // we are showing the empty view - switch the background back to the system color
                self.view.backgroundColor = .systemBackground
            }
        } else {
            // there is no empty view setup for this PanelView
            // the only thing to do is to ensure that background is panel divider color
            self.view.backgroundColor = .systemBackground
        }
    }
    
    
}
