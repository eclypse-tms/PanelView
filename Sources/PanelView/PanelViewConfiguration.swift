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
    
    /// adjusts the positioning of the empty state view vertically. acceptable
    /// values are from -1 to +1.
    ///
    /// * +1 puts the empty view all the way to the top of the screen
    /// * 0 places the empty view at the center. the default value.
    /// * -1 puts the empty view all the way to the bottom of the screen
    public var emptyViewVerticalAdjustment: CGFloat
        
    /// the color to highlight panel dividers when a pointer hovers over them.
    ///
    /// only applicable to macCatalyst. It has no effect when running in iOS
    /// devices.
    public var panelDividerHoverColor: UIColor?
    
    /// the this color is only visible in between the panels - when there are
    /// multiple panels open.
    public var panelDividerColor: UIColor
    
    /// The space in the between the panels.
    public var interPanelSpacing: CGFloat
    
    /// Controls the number of panels on each side of the central panel that are created and added to the view hiearchy.
    ///
    /// The default value is 3. This means that there are 3 panels on the left and 3 panels
    /// on the right of the central panel for a total of 7 panels in the view hierarchy.
    /// Creating panels beforehand helps with the animations and the transitions.
    public var numberOfPanelsOnEachSide: Int
    
    /// the animation duration when inserting and removing panels from the view
    public var panelTransitionDuration: Double
    
    /// determines whether the panels heights or widths can be changed in the UI
    public var allowsUIPanelSizeAdjustment: Bool
    
    /// controls whether to automatically release the ViewController/SwiftUI View when a panel is hidden
    ///
    /// This property is by default false. This means that ViewController/SwiftUI View will be kept in memory
    /// when its associated panel is hidden from view. This allows you to re-use the View
    /// when the panel is shown again without having to worry about preserving its state.
    /// On the other hand if you are not planning on re-using the same View when the panels are
    /// hidden, set this property to true to automatically reclaim the memory.
    ///
    /// - Note: This value is ignored when running in SwiftUI views
    public var autoReleaseViews: Bool
    
    /// Determines whether to run PanelView in single or multi panel mode.
    /// When in single panel mode, any panel that you show will take up the entire available screen and
    /// other panels - if they are visible, will be hidden.
    ///
    /// This mode may be useful when running the PanelView in compact screen sizes.
    public var panelMode: PanelMode
    
    /// When this value is set to true, all navigation bars are hidden right away.
    ///
    /// If you want to display a Navigation Bar for a panel, you can do so by accessing the
    /// PanelView.viewControllers property.
    public var hideAllNavigationBars: Bool
}

public extension PanelViewConfiguration {
    init() {
        self.orientation = .horizontal
        self.emptyStateView = nil
        self.panelDividerColor = UIColor.opaqueSeparator
        self.numberOfPanelsOnEachSide = 3
        self.panelTransitionDuration = 0.333333
        self.allowsUIPanelSizeAdjustment = true
        self.interPanelSpacing = 1.0
        self.panelDividerHoverColor = nil
        self.autoReleaseViews = false
        self.panelMode = .multi
        self.emptyViewVerticalAdjustment = 0
        self.hideAllNavigationBars = false
    }
}
