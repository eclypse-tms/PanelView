//
//  PanelViewConstraints.swift
//  
//
//  Created by eclypse on 7/16/24.
//

import Foundation

public protocol PanelViewConstraints {
    // MARK: Heights
    /// sets the minimum height for the given index at the corresponding panel
    func minimumHeight(_ height: CGFloat, at index: Int)
    
    /// sets the minimum height for the given panel
    func minimumHeight(_ height: CGFloat, for panel: Panel)
    
    /// sets the maximum height for the given index at the corresponding panel
    func maximumHeight(_ height: CGFloat, at index: Int)
    
    /// sets the maximum height for the given panel
    func maximumHeight(_ height: CGFloat, for panel: Panel)
    
    // MARK: Widths
    /// sets the minimum width for the given index at the corresponding panel
    func minimumWidth(_ width: CGFloat, at index: Int)
    
    /// sets the minimum width for the given panel
    func minimumWidth(_ width: CGFloat, for panel: Panel)
    
    /// sets the maximum width for the given index at the corresponding panel
    func maximumWidth(_ width: CGFloat, at index: Int)
    
    /// sets the maximum width for the given panel
    func maximumWidth(_ width: CGFloat, for panel: Panel)
    
    // MARK: Preferences
    /// preferred width of the panel in terms of screen size
    func preferredWidthFraction(_ fraction: CGFloat, at index: Int)
    
    /// preferred width of the panel in terms of screen size
    func preferredWidthFraction(_ fraction: CGFloat, for panel: Panel)
    
    /// preferred height of the panel in terms of screen size
    func preferredHeightFraction(_ fraction: CGFloat, at index: Int)
    
    /// preferred height of the panel in terms of screen size
    func preferredHeightFraction(_ fraction: CGFloat, for panel: Panel)
}

extension PanelView: PanelViewConstraints {
    // MARK: Minimums
    public func minimumHeight(_ height: CGFloat, at index: Int) {
        minimumWidth(height, at: index)
    }
    
    public func minimumWidth(_ width: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = Panel(index: index)
        minimumWidth(width, for: onTheFlyPanelIndex)
    }
    
    public func minimumHeight(_ height: CGFloat, for panel: Panel) {
        minimumWidth(height, for: panel)
    }
    
    public func minimumWidth(_ width: CGFloat, for panel: Panel) {
        if isAttachedToWindow, let constraintForPanel = panelMinWidthMappings[panel] {
            constraintForPanel.constant = width
        } else {
            pendingMinimumWidth[panel] = width
        }
    }
    
    // MARK: Maximums
    public func maximumHeight(_ height: CGFloat, at index: Int) {
        maximumWidth(height, at: index)
    }
    
    public func maximumWidth(_ width: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = Panel(index: index)
        maximumWidth(width, for: onTheFlyPanelIndex)
    }
    
    public func maximumHeight(_ height: CGFloat, for panel: Panel) {
        maximumWidth(height, for: panel)
    }
    
    public func maximumWidth(_ width: CGFloat, for panel: Panel) {
        if isAttachedToWindow, let constraintForPanel = panelMaxWidthMappings[panel] {
            constraintForPanel.constant = width
        } else {
            pendingMaximumWidth[panel] = width
        }
    }
    
    // MARK: Preferred Width Fractions
    public func preferredHeightFraction(_ fraction: CGFloat, at index: Int) {
        preferredWidthFraction(fraction, at: index)
    }
    
    public func preferredHeightFraction(_ fraction: CGFloat, for panel: Panel) {
        preferredWidthFraction(fraction, for: panel)
    }
    
    public func preferredWidthFraction(_ fraction: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = Panel(index: index)
        preferredWidthFraction(fraction, for: onTheFlyPanelIndex)
    }
    
    public func preferredWidthFraction(_ fraction: CGFloat, for panel: Panel) {
        let sanitizedFraction: CGFloat
        if fraction > 1 {
            sanitizedFraction = 1
        } else if fraction < 0 {
            sanitizedFraction = 0
        } else {
            sanitizedFraction = fraction
        }
        
        if isAttachedToWindow, let constraintForPanel = panelWidthMappings[panel] {
            if configuration.orientation == .horizontal {
                constraintForPanel.constant = view.frame.width * sanitizedFraction
            } else {
                constraintForPanel.constant = view.frame.height * sanitizedFraction
            }
        } else {
            pendingWidthFraction[panel] = sanitizedFraction
        }
    }
}
