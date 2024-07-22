//
//  PanelViewConfiguration.swift
//
//
//  Created by eclypse on 7/12/24.
//

import UIKit

/// Constains settings for PanelView.
public struct PanelViewConfiguration {
    /// runs the PanelView in horizontal or vertical mode.
    ///
    /// Once the orientation is determined, it cannot be changed later on.
    public var orientation: PanelOrientation
    
    /// the view to display when there are no panels visible.
    public var emptyStateView: UIView?
        
    /// the color to highlight panel dividers when a pointer hovers over them.
    ///
    /// only applicable to macCatalyst. It has no effect when running in iOS
    /// devices.
    public var panelDividerHoverColor: UIColor?
    
    /// the this color is only visible in between the panels - when there are
    /// multiple panels open.
    public var panelSeparatorColor: UIColor
    
    /// The space in the between the panels.
    public var interPanelSpacing: CGFloat
    
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
    
    /// controls whether to automatically release the view controllers when a panel is hidden
    ///
    /// This property is by default false. This means that view controller will be kept in memory
    /// when its associated panel is hidden from view. This allows you to re-use the view controller
    /// when the panel is shown again without having to worry about preserving its state.
    /// On the other hand if you are not planning on re-using the same view controller when the panels are
    /// hidden, set this property to true to automatically reclaim the memory occupied by the view controller.
    public var autoReleaseViewControllers: Bool
}

public extension PanelViewConfiguration {
    init() {
        self.orientation = .horizontal
        self.emptyStateView = nil
        self.panelSeparatorColor = UIColor.opaqueSeparator
        self.numberOfPanelsToPrime = 4
        self.panelTransitionDuration = 0.333333
        self.allowsUIPanelSizeAdjustment = true
        self.interPanelSpacing = 1.0
        self.panelDividerHoverColor = nil
        self.autoReleaseViewControllers = false
    }
}
