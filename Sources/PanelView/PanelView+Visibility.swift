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
    func show(panel: PanelIndex, animated: Bool = true, 
              animationsWillBegin: (() -> Void)? = nil,
              completion: (() -> Void)? = nil) {
        func animatableBlock(accompanyingPanel: UIView) {
            if isSinglePanelMode {
                // when running in single panel mode,
                // all dividers are ignored - so we don't have to re-establish the divider constraints
                // all we have to do is to slide stack view to the opposing side
                slideStackView()
            } else {
                // we are running in multi-panel mode,
                // all we have to do is to show the panel
                accompanyingPanel.isHidden = false
            }
        }
        
        func preAnimationBlock(accompanyingPanel: UIView) {
            if isSinglePanelMode {
                // in single panel mode, we need to adjust the main stackview's constraints
                // before we show the additional panel
                // doing so prevents the constraint based layout problems
                
                self.expandStackView(panelToShow: panel)
                accompanyingPanel.isHidden = false
            } else {
                // nothing to do for post animation block in multi panel mode
            }
        }
        
        func postAnimationBlock(accompanyingPanel: UIView) {
            if isSinglePanelMode {
                // we hide all other visible panels
                visiblePanels.forEach { eachPanel in
                    if let eachPanel = panelMappings[eachPanel] {
                        if eachPanel == accompanyingPanel {
                            // we shouldn't be hiding the acompanying panel
                        } else {
                            eachPanel.isHidden = true
                        }
                    }
                }
                restoreStackViewBackToItsOriginalSize()
            } else {
                // nothing to do for post animation block in multi panel mode
            }
        }
        
        let aPanelToShow = panelMappings[panel] ?? getPanel(for: panel)
        
        // in order for animations to run correctly for the stackview, we need to first remove the panel
        // from the superview and re-insert it later on
        aPanelToShow.removeFromSuperview()
        let subViewIndex = calculateAppropriateIndex(for: panel)
        mainStackView.insertArrangedSubview(aPanelToShow, at: subViewIndex)
        
        // reattach its accompanying view divider if necessary
        if panel.index != 0, configuration.allowsUIPanelSizeAdjustment, !isSinglePanelMode {
            createPanelDivider(for: panel)
        }
        
        preAnimationBlock(accompanyingPanel: aPanelToShow)
        animationsWillBegin?()
        
        if animated {
            if isSinglePanelMode {
                // in single panel mode all panels are animatable
                // other panels can be animated
                UIView.animate(withDuration: 3.0, animations: { [weak self] in
                    // animatableBlock(accompanyingPanel: aPanelToShow)
                    
                    guard let strongSelf = self else { return }
                    if strongSelf.isSinglePanelMode {
                        // when running in single panel mode,
                        // all dividers are ignored - so we don't have to re-establish the divider constraints
                        // all we have to do is to slide stack view to the opposing side
                        strongSelf.slideStackView()
                    } else {
                        // we are running in multi-panel mode,
                        // all we have to do is to show the panel
                        aPanelToShow.isHidden = false
                    }
                    
                }, completion: { animationsCompleted in
                    print("animations completed: \(animationsCompleted)")
                    postAnimationBlock(accompanyingPanel: aPanelToShow)
                    //self.mainStackView.layoutIfNeeded()
                    completion?()
                })
            } else {
                // in multi panel mode, displaying the central panel is not animatable
                if panel.index == 0 {
                    // no animations
                    animatableBlock(accompanyingPanel: aPanelToShow)
                    //self.mainStackView.layoutIfNeeded()
                    postAnimationBlock(accompanyingPanel: aPanelToShow)
                    completion?()
                } else {
                    // other panels can be animated
                    UIView.animate(withDuration: 3.0, animations: { [weak self] in
                        // animatableBlock(accompanyingPanel: aPanelToShow)
                        
                        guard let strongSelf = self else { return }
                        if strongSelf.isSinglePanelMode {
                            // when running in single panel mode,
                            // all dividers are ignored - so we don't have to re-establish the divider constraints
                            // all we have to do is to slide stack view to the opposing side
                            strongSelf.slideStackView()
                        } else {
                            // we are running in multi-panel mode,
                            // all we have to do is to show the panel
                            aPanelToShow.isHidden = false
                        }
                        
                    }, completion: { animationsCompleted in
                        print("animations completed: \(animationsCompleted)")
                        postAnimationBlock(accompanyingPanel: aPanelToShow)
                        //self.mainStackView.layoutIfNeeded()
                        completion?()
                    })
                }
            }
        } else {
            // forced to no animations
            animatableBlock(accompanyingPanel: aPanelToShow)
            //self.mainStackView.layoutIfNeeded()
            postAnimationBlock(accompanyingPanel: aPanelToShow)
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
            
            if isSinglePanelMode {
                // in single panel mode, we need to show the panel first and then add the view controller
                // in the hierarchy
                show(panel: panel, animated: animated, completion: { [weak self] in
                    if let alreadyEmbeddedInNavController = viewController as? UINavigationController {
                        self?.add(childNavController: alreadyEmbeddedInNavController, on: panel)
                    } else {
                        let navController = UINavigationController(rootViewController: viewController)
                        self?.add(childNavController: navController, on: panel)
                    }
                    completion?()
                })
            } else {
                // in multi panel mode, we can add the view controller to the view hierarchy and show the
                // panel right away
                if let alreadyEmbeddedInNavController = viewController as? UINavigationController {
                    add(childNavController: alreadyEmbeddedInNavController, on: panel)
                } else {
                    let navController = UINavigationController(rootViewController: viewController)
                    add(childNavController: navController, on: panel)
                }
                
                show(panel: panel, animated: animated, completion: completion)
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
    
    /// check whether indicated panel is visible or not
    func isVisible(panel: PanelIndex) -> Bool {
        if let discoveredPanel = panelMappings[panel] {
            return !discoveredPanel.isHidden
        } else {
            return false
        }
    }
    
    /// this function is only valid if the current mode is single panel
    /// when called when the current mode is not single, then it returns nil
    var currentlyVisiblePanel: PanelIndex? {
        if isSinglePanelMode {
            let possibleVisiblePanel = panelMappings.first(where: { isVisible(panel: $0.key) })?.key
            return possibleVisiblePanel
        } else {
            return nil
        }
    }
    
    /// checks whether the provided viewController is currently being presented in one of the panels
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
