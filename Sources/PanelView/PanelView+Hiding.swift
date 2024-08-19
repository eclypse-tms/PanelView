//
//  PanelViewHidingManager.swift
//
//
//  Created by eclypse on 7/16/24.
//

import UIKit

public extension PanelView {
    /// Hides the specified panel associated with the provided view controller.
    /// - Parameters:
    ///   - viewController: the panel that contains the given view controller
    ///   - animated: whether to animate the hiding transition. default value is true.
    ///   - releaseView: whether to release the view controller upon hiding. when not specified uses the value in PanelViewConfiguration.
    ///   - completion: notifies the called that hiding is complete.
    func hide(containing viewController: UIViewController, animated: Bool = true, releaseView: Trilean = .default, completion: (() -> Void)? = nil) {
        let panelToHide: Panel? = index(of: viewController)
        
        if let discoveredPanelToHide = panelToHide {
            hide(panel: discoveredPanelToHide, animated: animated, completion: completion)
        }
    }
    
    /// Hides the panel at the given index.
    /// - Parameters:
    ///   - index: the index of the panel to hide.
    ///   - animated: whether to animate the hiding transition. default value is true.
    ///   - releaseView: whether to release the view controller upon hiding. when not specified uses the value in PanelViewConfiguration.
    ///   - completion: notifies the called that hiding is complete.
    func hide(index: Int, animated: Bool = true, releaseView: Trilean = .default, completion: (() -> Void)? = nil) {
        let onTheFlyIndex = Panel(index: index)
        hide(panel: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    /// Hides the panel by its name.
    /// - Parameters:
    ///   - panel: the panel that contains the given view controller
    ///   - animated: whether to animate the hiding transition. default value is true.
    ///   - releaseView: whether to release the view controller upon hiding. when not specified uses the value in PanelViewConfiguration.
    ///   - completion: notifies the called that hiding is complete.
    func hide(panel: Panel, animated: Bool = true, releaseView: Trilean = .default, completion: (() -> Void)? = nil) {
        func hideAppropriatePanel() {
            if let panelToHide = panelMappings[panel] {
                if !panelToHide.isHidden {
                    panelToHide.layer.removeAllAnimations()
                    panelToHide.isHidden = true
                }
            }
            
            hideViewDivider(associatedPanel: panel)
            
            displayEmptyStateIfNecessary()
        }
        
        func _performPanelHiding(panel: Panel, animated: Bool, hidingCompleted: (() -> Void)?) {
            if panel.index != 0, animated {
                // we shouldn't animate hiding of the main panel
                let animations = UIViewPropertyAnimator(duration: configuration.panelTransitionDuration, curve: .easeInOut, animations: {
                    hideAppropriatePanel()
                })
                animations.addCompletion({ _ in
                    self.mainStackView.layoutIfNeeded()
                    hidingCompleted?()
                })
                animations.startAnimation()
            } else {
                hideAppropriatePanel()
                self.mainStackView.layoutIfNeeded()
                hidingCompleted?()
            }
        }
        
        
        // if we decide to hide the central panel and there are other panels visible,
        // this creates a problem with the constraints as the central panel is the one
        // without constraints which allows it to take the remainder of the space. 
        // when this happens, we need to find the panel with the highest panel index
        // and disable the constraints on that panel
        //if panel.index == 0, visiblePanels.first(where: { $0.index != 0 }) != nil {
            
        //}
        
        _performPanelHiding(panel: panel, animated: animated, hidingCompleted: { [weak self] in
            guard let strongSelf = self else { return }
            let shouldViewControllerBeReleasedFromMemory: Bool
            switch releaseView {
            case .default:
                shouldViewControllerBeReleasedFromMemory = strongSelf.configuration.autoReleaseViews
            case .true:
                shouldViewControllerBeReleasedFromMemory = true
            case .false:
                shouldViewControllerBeReleasedFromMemory = false
            }
            
            if shouldViewControllerBeReleasedFromMemory {
                if let previousVC = strongSelf.viewControllers[panel] {
                    previousVC.removeSelfFromParent()
                    strongSelf.viewControllers.removeValue(forKey: panel)
                }
            }
            
            // now that the panel is hidden, remove it from the view
            strongSelf.removePanelDivider(for: panel)
            
            completion?()
        })
    }
    
    /// hides all the panels and removes all the view controllers and swiftUI views from the layout.
    /// you will have to re-add view controllers before you want to show another panel
    func reset() {
        // first remove any existing view controllers from the parent
        for (_, vc) in viewControllers {
            vc.removeSelfFromParent()
        }
        
        // remove all the view controllers from the mappings
        viewControllers.removeAll(keepingCapacity: true)
        swiftUIViewMappings.removeAllObjects()
        
        // hide everything
        panelMappings.forEach { (eachPanelIndex, panel) in
            if !panel.isHidden {
                panel.isHidden = true
            }
            hideViewDivider(associatedPanel: eachPanelIndex)
        }
        
        displayEmptyStateIfNecessary()
    }
    
    private func hideViewDivider(associatedPanel: Panel) {
        if let associatedResizer = dividerMappings[associatedPanel] {
            let uniqueConstraintIdentifier = "\(_dividerConstraintIdentifier)\(associatedResizer.tag)"
            if let constraintThatNeedToAltered = self.view.constraints.first(where: { $0.identifier == uniqueConstraintIdentifier }) {
                constraintThatNeedToAltered.constant = 0
            }
        }
    }
}
