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
    ///   - index: negative indices appear on the left side of the screen. positive indices appear on the right side.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        let onTheFlyIndex = PanelIndex(index: index)
        show(panel: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    /// If the panel is already associated with a view controller, this action redisplays it.
    /// - Parameters:
    ///   - panel: the name of the panel to show.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(panel: PanelIndex, animated: Bool = true, completion: (() -> Void)? = nil) {
        var tempEqualWidthsConstraint: NSLayoutConstraint?
        var panelToHide: UIView?
        
        func preAnimationBlock(panelToShow: UIView) {
            if isSinglePanelMode {
                expandStackView(panelIndexToBeShown: panel)
                if let currentlyVisiblePanelAndItsIndex = currentlyVisiblePanelAndItsIndex {
                    
                    let currentlyVisiblePanelIndex = currentlyVisiblePanelAndItsIndex.0
                    let currentlyVisiblePanel = currentlyVisiblePanelAndItsIndex.1
                    panelToHide = currentlyVisiblePanel
                    
                    tempEqualWidthsConstraint = currentlyVisiblePanel.widthAnchor.constraint(equalTo: panelToShow.widthAnchor)
                    tempEqualWidthsConstraint?.identifier = "panel: \(panel.index) width = panel :\(currentlyVisiblePanelIndex.index) width"
                    tempEqualWidthsConstraint?.isActive = true
                }
                panelToShow.isHidden = false
            } else {
                // no need to do anything when in multi-panel mode
            }
        }
        
        func animatableBlock(panelToShow: UIView) {
            if isSinglePanelMode {
                slideStackView()
                
            } else {
                // we are running in multi-panel mode,
                // all we have to do is to show the panel
                panelToShow.layer.removeAllAnimations()
                panelToShow.isHidden = false
            }
        }
        
        func postAnimationBlock(panelToShow: UIView) {
            if isSinglePanelMode {
                // when running in single panel mode,
                // all dividers are ignored - so we don't have to re-establish the divider constraints
                
                tempEqualWidthsConstraint?.isActive = false
                panelToHide?.isHidden = true
                restoreStackViewBackToItsOriginalSize()
            } else {
                // no need to do anything when in multi-panel mode
            }
        }
        
        let aPanelToShow = panelMappings[panel] ?? createPanel(for: panel)
        
        // in order for animations to run correctly for the stackview, we need to first remove the panel
        // from the superview and then re-insert it at the correct index
        aPanelToShow.removeFromSuperview()
        let subViewIndex = calculateAppropriateIndex(for: panel)
        mainStackView.insertArrangedSubview(aPanelToShow, at: subViewIndex)
        
        
        // reattach its accompanying view divider if necessary
        if panel.index != 0, configuration.allowsUIPanelSizeAdjustment, !isSinglePanelMode {
            createPanelDivider(for: panel)
        }
        
        preAnimationBlock(panelToShow: aPanelToShow)
        
        self.view.layoutIfNeeded()
        
        if isSinglePanelMode {
            // in single panel mode, all panels are animatable
            if animated {
                
                let animations = UIViewPropertyAnimator(duration: configuration.panelTransitionDuration, curve: .easeInOut, animations: {
                    animatableBlock(panelToShow: aPanelToShow)
                    self.view.layoutIfNeeded()
                })
                animations.addCompletion({ _ in
                    postAnimationBlock(panelToShow: aPanelToShow)
                    completion?()
                })
                animations.startAnimation()
                 
                /*
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    animatableBlock(panelToShow: aPanelToShow)
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    postAnimationBlock(panelToShow: aPanelToShow)
                    completion?()
                })
                 */
            } else {
                self.view.layoutIfNeeded()
                animatableBlock(panelToShow: aPanelToShow)
                postAnimationBlock(panelToShow: aPanelToShow)
                self.view.layoutIfNeeded()
                completion?()
            }
        } else {
            // in multi panel mode, only non-zero panels can be animated
            if panel.index == 0 {
                animatableBlock(panelToShow: aPanelToShow)
                postAnimationBlock(panelToShow: aPanelToShow)
                completion?()
            } else {
                if animated {
                    let animations = UIViewPropertyAnimator(duration: configuration.panelTransitionDuration, curve: .easeInOut, animations: {
                        animatableBlock(panelToShow: aPanelToShow)
                    })
                    animations.addCompletion({ _ in
                        postAnimationBlock(panelToShow: aPanelToShow)
                        completion?()
                    })
                    animations.startAnimation()
                } else {
                    animatableBlock(panelToShow: aPanelToShow)
                    postAnimationBlock(panelToShow: aPanelToShow)
                    completion?()
                }
            }
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
        let onTheFlyIndex = PanelIndex(index: index)
        show(viewController: viewController, for: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    /// Displays a view controller for the named panel. If there was another view controller already associated
    /// with that panel, this action replaces the existing view controller.
    /// - Parameters:
    ///   - viewController: a view controller to show.
    ///   - panel: the name of the panel to show this view controller.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(viewController: UIViewController, for panel: PanelIndex, animated: Bool = true, completion: (() -> Void)? = nil) {
        if isAttachedToWindow {
            if let previousVC = viewControllers[panel] {
                previousVC.removeSelfFromParent()
                viewControllers.removeValue(forKey: panel)
            }
            
            // since there is at least one panel that will be visible
            // we should hide the empty view stack
            hideEmptyState()
            
            show(panel: panel, animated: animated, completion: completion)
            
            if let alreadyEmbeddedInNavController = viewController as? UINavigationController {
                add(childNavController: alreadyEmbeddedInNavController, on: panel)
            } else {
                let navController = UINavigationController(rootViewController: viewController)
                add(childNavController: navController, on: panel)
            }
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
    func show(navigationStack: [UIViewController], for panel: PanelIndex, animated: Bool = true, completion: (() -> Void)? = nil) {
        if isAttachedToWindow {
            if let previousVC = viewControllers[panel] {
                previousVC.removeSelfFromParent()
                viewControllers.removeValue(forKey: panel)
            }
            
            // since there is at least one panel that is will be visible
            // we should hide the empty view stack
            hideEmptyState()
           
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
    
    func topViewController(for panel: PanelIndex) -> UIViewController? {
        return viewControllers[panel]?.topViewController
    }
    
    /// returns a list of all visible panels sorted in ascending order by each panel's index
    var visiblePanels: [PanelIndex] {
        let sortedVisiblePanels = panelMappings.compactMap { (eachPanelIndex, eachPanel) -> PanelIndex? in
            if isVisible(panel: eachPanelIndex) {
                return eachPanelIndex
            } else {
                return nil
            }
        }.sorted()
        return sortedVisiblePanels
    }
    
    /// check whether
    func isVisible(panel: PanelIndex) -> Bool {
        if let discoveredPanel = panelMappings[panel] {
            return !discoveredPanel.isHidden
        } else {
            return false
        }
    }
    
    /// returns the panel index of the provided viewController if it is in the view hierarchy
    func index(of viewController: UIViewController) -> PanelIndex? {
        var vcPresentedIn: PanelIndex?
        for (eachPanel, eachNavController) in viewControllers {
            if eachNavController.viewControllers.contains(viewController) {
                vcPresentedIn = eachPanel
                break
            }
        }
        return vcPresentedIn
    }
    
    /// this function is only valid if the current mode is single panel
    /// when called when the current mode is not single, then it returns nil
    var currentlyVisiblePanelIndex: PanelIndex? {
        currentlyVisiblePanelAndItsIndex?.0
    }
    
    /// this function is only valid if the current mode is single panel
    /// when called when the current mode is not single, then it returns nil
    var currentlyVisiblePanel: UIView? {
        currentlyVisiblePanelAndItsIndex?.1
    }
    
    /// this function is only valid if the current mode is single panel
    /// when called when the current mode is not single, then it returns nil
    var currentlyVisiblePanelAndItsIndex: (PanelIndex, UIView)? {
        if isSinglePanelMode {
            let possibleVisiblePanel = panelMappings.first(where: { isVisible(panel: $0.key) })
            return possibleVisiblePanel
        } else {
            return nil
        }
    }
    
    private func calculateAppropriateIndex(for panel: PanelIndex) -> Int {
        let sortedPanels: [PanelIndex] = panelMappings.map { $0.key }.sorted()
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
