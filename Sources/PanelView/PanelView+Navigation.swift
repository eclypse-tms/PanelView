//
//  PanelView+Navigation.swift
//
//
//  Created by eclypse on 7/22/24.
//

import UIKit

public extension PanelView {
    /// pushes a view controller on the panel's navigation stack
    func push(viewController: UIViewController, on panel: PanelIndex = .center) {
        if let navController = viewControllers[panel] {
            navController.pushViewController(viewController, animated: true)
        }
    }
    
    /// pops the top view controller on the specified panel
    func popViewController(on panel: PanelIndex = .center) {
        if let navController = viewControllers[panel] {
            navController.popViewController(animated: true)
        }
    }
    
    /// replaces the top view controller with another view controller
    func replaceTopViewController(with this: UIViewController, animated: Bool, on panel: PanelIndex = .center) {
        if let navController = viewControllers[panel] {
            var newStack = Array(navController.viewControllers.dropLast(1))
            newStack.append(this)
            navController.setViewControllers(newStack, animated: animated)
        }
    }
    
    /// pops the stack on the specified panel to the provided UIViewController type
    @discardableResult
    func popToViewController<T>(usingType viewControllerType: T.Type, animated: Bool, on panel: PanelIndex = .center) -> [UIViewController]? {
        if let navController = viewControllers[panel] {
            
            let candidateVC = navController.viewControllers.first(where: { eachVCInStack in
                let typeOfThisViewController = type(of: eachVCInStack)
                return viewControllerType == typeOfThisViewController
            })
            
            if let validVC = candidateVC {
                return navController.popToViewController(validVC, animated: animated)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
