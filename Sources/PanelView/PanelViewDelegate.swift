//
//  PanelViewDelegate.swift
//  
//
//  Created by eclypse on 7/18/24.
//

import UIKit

public protocol PanelViewDelegate: AnyObject {
    /// called when the PanelView detects a horizontal or vertical size class change in (UIUserInterfaceSizeClass)
    ///
    /// It is possible for multiple screen size changes to occur at the same time. Consider the case
    /// when iPhone 15+'s orientation changes. After the orientation change, vertical size could be compact
    /// while at the same time horizontal size could be regular.
    func didChangeSize(panelView: PanelView, changes: ScreenSizeChanges)
}

public extension PanelViewDelegate {
    func didChangeSize(panelView: PanelView, changes: ScreenSizeChanges) {}
}
