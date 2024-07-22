//
//  PanelViewDisplayManager.swift
//
//
//  Created by eclypse on 7/16/24.
//

import UIKit

public protocol PanelViewDisplayManager {
    /// shows a previously hidden panel. If the panel does not have a childview controller
    /// associated with it already you will see an empty view.
    func show(panel: Panel, animated: Bool)
    
    /// shows a previously hidden panel. If the panel does not have a childview controller
    /// associated with it already you will see an empty view. animates the transition.
    func show(panel: Panel)
    
    /// shows a new view controller at the provided panel index. If the panel already contains
    /// another child view controller, it replaces that while animating the transition.
    ///
    /// You can use this function interchangeably with show(viewController:for:animated).
    func show(viewController: UIViewController, at index: Int)
    
    /// shows a new view controller at the provided panel index. If the panel already contains
    /// another child view controller, it replaces that while animating the transition.
    ///
    /// You can use this function interchangeably with show(viewController:for:animated).
    func show(viewController: UIViewController, at index: Int, animated: Bool)
    
    /// shows a new view controller for the provided named panel. If the panel already contains
    /// another child view controller, it replaces that. 
    ///
    /// You can use this function interchangeably with show(viewController:at:animated).
    func show(viewController: UIViewController, for panel: Panel, animated: Bool)
    
    /// shows a new view controller for the provided named panel. If the panel already contains
    /// another child view controller, it replaces that while animating the transition.
    ///
    /// You can use this function interchangeably with show(viewController:at:animated).
    func show(viewController: UIViewController, for panel: Panel)
    
    /// adds the provided navigation stack to the named panel. If the panel already contains
    /// another child view controller, it replaces that.
    func show(navigationStack: [UIViewController], for panel: Panel, animated: Bool)
}

extension PanelView: PanelViewDisplayManager {
    public func show(panel: Panel) {
        show(panel: panel, animated: true)
    }
    
    public func show(panel: Panel, animated: Bool) {
        func animatableBlock() {
            // in order for animations to run correctly, we need to first remove the panel
            // from the superview and re-insert it later on
            aPanelToShow.removeFromSuperview()
            let subViewIndex = calculateAppropriateIndex(for: panel)
            mainStackView.insertArrangedSubview(aPanelToShow, at: subViewIndex)
            aPanelToShow.isHidden = false
            
            // we need to re-establish the constraints for panel resizers
            // center panel does not have a resizer
            if panel.index != 0, let associatedResizer = dividerMappings[panel] {
                let reestablishedConstraint: NSLayoutConstraint
                if mainStackView.axis == .horizontal {
                    if panel.index < 0 {
                        // this is a horizonal layout and the panel is on the left hand side (leading side)
                        // resizer needs to be aligned to the trailing side of the panel
                        reestablishedConstraint = associatedResizer.trailingAnchor.constraint(equalTo: aPanelToShow.trailingAnchor, constant: panelDividerWidth/2.0)
                    } else {
                        // this is a horizonal layout and the panel is on the right hand side (trailing side)
                        // resizer needs to be aligned to the leading side of the panel
                        reestablishedConstraint = associatedResizer.leadingAnchor.constraint(equalTo: aPanelToShow.leadingAnchor, constant: -panelDividerWidth/2.0)
                    }
                } else {
                    if panel.index < 0 {
                        // this is a vertical layout and the panel is on the top side
                        // resizer needs to be aligned to the bottom side of the panel
                        reestablishedConstraint = associatedResizer.bottomAnchor.constraint(equalTo: aPanelToShow.bottomAnchor, constant: panelDividerWidth/2.0)
                    } else {
                        // this is a vertical layout and the panel is on the bottom
                        // resizer needs to be aligned to the top side of the panel
                        reestablishedConstraint = associatedResizer.topAnchor.constraint(equalTo: aPanelToShow.topAnchor, constant: panelDividerWidth/2.0)
                    }
                }
                reestablishedConstraint.identifier = "\(_dividerConstraintIdentifier)\(associatedResizer.tag)"
                reestablishedConstraint.isActive = true
                associatedResizer.isHidden = false
            }
        }
        
        let aPanelToShow = panelMappings[panel] ?? createPanel(for: panel)
        
        if panel.index != 0, animated {
            UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                animatableBlock()
            })
        } else {
            animatableBlock()
        }
    }
    
    public func show(viewController: UIViewController, at index: Int) {
        let onTheFlyIndex = Panel(index: index)
        show(viewController: viewController, for: onTheFlyIndex, animated: true)
    }
    
    public func show(viewController: UIViewController, at index: Int, animated: Bool) {
        let onTheFlyIndex = Panel(index: index)
        show(viewController: viewController, for: onTheFlyIndex, animated: animated)
    }
    
    public func show(viewController: UIViewController, for panel: Panel) {
        show(viewController: viewController, for: panel, animated: true)
    }
    
    public func show(viewController: UIViewController, for panel: Panel, animated: Bool) {
        if isAttachedToWindow {
            if let previousVC = viewControllers[panel] {
                previousVC.removeSelfFromParent()
                viewControllers.removeValue(forKey: panel)
            }
            
            // since there is at least one panel that is will be visible
            // we should hide the empty view stack
            hideEmptyView()
            
            if let alreadyEmbeddedInNavController = viewController as? UINavigationController {
                add(childNavController: alreadyEmbeddedInNavController, on: panel)
            } else {
                let navController = UINavigationController(rootViewController: viewController)
                add(childNavController: navController, on: panel)
            }
            
            show(panel: panel, animated: animated)
        } else {
            pendingViewControllers[panel] = viewController
        }
    }
    
    public func show(navigationStack: [UIViewController], for panel: Panel, animated: Bool) {
        if isAttachedToWindow {
            if let previousVC = viewControllers[panel] {
                previousVC.removeSelfFromParent()
                viewControllers.removeValue(forKey: panel)
            }
            
            // since there is at least one panel that is will be visible
            // we should hide the empty view stack
            hideEmptyView()
            
           
            let navController = UINavigationController()
            navController.setViewControllers(navigationStack, animated: false)
            add(childNavController: navController, on: panel)
            
            show(panel: panel, animated: animated)
        } else {
            let navController = UINavigationController()
            navController.setViewControllers(navigationStack, animated: false)
            pendingViewControllers[panel] = navController
        }
    }
    
    private func hideEmptyView() {
        if let validEmptyStateView = emptyView {
            self.view.sendSubviewToBack(validEmptyStateView)
            validEmptyStateView.isHidden = true
        }
        self.view.backgroundColor = configuration.panelSeparatorColor
    }
}
