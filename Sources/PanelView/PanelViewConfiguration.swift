//
//  PanelViewConfiguration.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit

public struct PanelViewConfiguration {
    /// runs the PanelView in horizontal or vertical mode.
    ///
    /// Once the orientation is determined, it cannot be changed later on.
    public var orientation: PanelOrientation
    
    /// the view to display when there are no panels visible.
    public var emptyStateView: UIView?
        
    /// when this value is not nil, the view resizers will be highlighted when
    /// a pointer hovers over them. when this value is nil, no highlighting will
    /// occur.
    ///
    /// only applicable to macCatalyst
    public var viewResizerHoverColor: UIColor?
    
    /// Number of panels on each side that are created and added to the view hiearchy.
    /// The default value is 4. This means 4 panels on each side of the main panel
    /// for a total of 9 panels are added to the view hierarchy. Priming panels
    /// before hand helps with animations and transitions to work correctly. If you know
    /// that you will need more than 9 panels adjust this number accordingly otherwise
    /// leave it as-is.
    public var numberOfPanelsToPrime: Int
    
    /// the animation duration when inserting and removing panels from the view
    public var panelTransitionDuration: Double
    
    /// determines whether the panels heights or widths can be changed in the UI
    public var allowsUIPanelSizeAdjustment: Bool
}

public extension PanelViewConfiguration {
    init() {
        self.orientation = .horizontal
        self.emptyStateView = nil
        self.viewResizerHoverColor = nil
        self.numberOfPanelsToPrime = 4
        self.panelTransitionDuration = 0.333333
        self.allowsUIPanelSizeAdjustment = true
    }
}
