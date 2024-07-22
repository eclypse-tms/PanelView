//
//  PanelViewDisplayManager.swift
//
//
//  Created by eclypse on 7/16/24.
//

import UIKit

public extension PanelView {
    /// If the panel is already associated with a view controller, this action redisplays it.
    /// - Parameters:
    ///   - panel: the name of the panel to show.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(panel: Panel, animated: Bool, completion: (() -> Void)? = nil) {
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
            }, completion: { _ in
                completion?()
            })
        } else {
            animatableBlock()
            completion?()
        }
    }
    
    
    /// Displays a view controller at the specified index. If there was another view controller already associated
    /// with that panel, this action replaces the existing view controller.
    /// - Parameters:
    ///   - viewController: a view controller to show.
    ///   - index: negative indices appear on the left side of the screen. positive indices appear on the right side.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(viewController: UIViewController, at index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        let onTheFlyIndex = Panel(index: index)
        show(viewController: viewController, for: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    /// Displays a view controller for the named panel. If there was another view controller already associated
    /// with that panel, this action replaces the existing view controller.
    /// - Parameters:
    ///   - viewController: a view controller to show.
    ///   - panel: the name of the panel to show this view controller.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(viewController: UIViewController, for panel: Panel, animated: Bool = true, completion: (() -> Void)? = nil) {
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
            
            show(panel: panel, animated: animated, completion: completion)
        } else {
            pendingViewControllers[panel] = viewController
            completion?()
        }
    }
    
    /// Displays a navigation stack for the named panel. If there was another view controller already associated
    /// with that panel, this action replaces the existing view controller.
    /// - Parameters:
    ///   - navigationStack: view controllers of a navigation stack.
    ///   - panel: the name of the panel to show this navigation stack.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(navigationStack: [UIViewController], for panel: Panel, animated: Bool = true, completion: (() -> Void)? = nil) {
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
            
            show(panel: panel, animated: animated, completion: completion)
        } else {
            let navController = UINavigationController()
            navController.setViewControllers(navigationStack, animated: false)
            pendingViewControllers[panel] = navController
            completion?()
        }
    }
    
    func topViewController(for panel: Panel) -> UIViewController? {
        return viewControllers[panel]?.topViewController
    }
    
    
    var visiblePanels: [Panel] {
        let sortedVisiblePanels = panelMappings.compactMap { (eachPanelIndex, eachPanel) -> Panel? in
            if isVisible(panel: eachPanelIndex) {
                return eachPanelIndex
            } else {
                return nil
            }
        }.sorted()
        return sortedVisiblePanels
    }
    
    /// check whether
    func isVisible(panel: Panel) -> Bool {
        if let discoveredPanel = panelMappings[panel] {
            return !discoveredPanel.isHidden
        } else {
            return false
        }
    }
    
    /// checks whether the provided viewController is currently being presented in one of the panels
    func presents(viewController: UIViewController) -> Panel? {
        var vcPresentedIn: Panel?
        for (eachPanel, eachNavController) in viewControllers {
            if eachNavController.viewControllers.contains(viewController) {
                vcPresentedIn = eachPanel
                break
            }
        }
        return vcPresentedIn
    }
    
    private func hideEmptyView() {
        if let validEmptyStateView = emptyView {
            self.view.sendSubviewToBack(validEmptyStateView)
            validEmptyStateView.isHidden = true
        }
        self.view.backgroundColor = configuration.panelDividerColor
    }
    
    private func calculateAppropriateIndex(for panel: Panel) -> Int {
        let sortedPanels: [Panel] = panelMappings.map { $0.key }.sorted()
        if sortedPanels.isEmpty {
            // since there are no panels, the subview index is zero
            return 0
        }
        
        var nextIndex: Int?
        for (subviewIndex, eachPanelIndex) in sortedPanels.enumerated() {
            if eachPanelIndex.index == panel.index {
                nextIndex = subviewIndex
            }
        }
        
        if let discoveredIndex = nextIndex {
            return discoveredIndex
        } else {
            // this panel must be the last panel
            return sortedPanels.endIndex
        }
    }
}