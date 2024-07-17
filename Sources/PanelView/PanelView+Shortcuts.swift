//
//  PanelView+Shortcuts.swift
//  
//
//  Created by Nessa Kucuk, Turker on 7/16/24.
//

import UIKit

public extension PanelView {
    /// navigation controller that manages the view stack on the center view
    var centralPanelNavController: UINavigationController? {
        return viewControllers[.center]
    }
    
    /// navigation controller that manages the view stack on the side view (left hand side) of the panel view
    var sideMenuController: UINavigationController? {
        return viewControllers[.navigation]
    }
    
    func topViewController(for panel: PanelIndex) -> UIViewController? {
        return viewControllers[panel]?.topViewController
    }
    
    func isVisible(panel: PanelIndex) -> Bool {
        if let discoveredPanel = panelMappings[panel] {
            return !discoveredPanel.isHidden
        } else {
            return false
        }
    }
    
    var centerNavigationController: UINavigationController? {
        return viewControllers[.center]
    }
    
    func replaceTopViewController(with this: UIViewController, animated: Bool) {
        if let navController = viewControllers[.center] {
            navController.replaceTopViewController(with: this, animated: animated)
        }
    }
    
    @discardableResult
    func popToViewController<T>(usingType viewControllerType: T.Type, animated: Bool) -> [UIViewController]? {
        if let navController = viewControllers[.center] {
            return navController.popToViewController(usingType: viewControllerType, animated: animated)
        }
        return nil
    }
}
