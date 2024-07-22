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
    ///   - releaseViewController: whether to release the view controller upon hiding. when not specified uses the value in PanelViewConfiguration.
    ///   - completion: notifies the called that hiding is complete.
    func hidePanel(containing viewController: UIViewController, animated: Bool = true, releaseViewController: Trilean = .default, completion: (() -> Void)? = nil) {
        let panelToHide: Panel? = presents(viewController: viewController)
        
        if let discoveredPanelToHide = panelToHide {
            hide(panel: discoveredPanelToHide, animated: animated, completion: completion)
        }
    }
    
    /// Hides the panel at the given index.
    /// - Parameters:
    ///   - index: the index of the panel to hide.
    ///   - animated: whether to animate the hiding transition. default value is true.
    ///   - releaseViewController: whether to release the view controller upon hiding. when not specified uses the value in PanelViewConfiguration.
    ///   - completion: notifies the called that hiding is complete.
    func hide(index: Int, animated: Bool = true, releaseViewController: Trilean = .default, completion: (() -> Void)? = nil) {
        let onTheFlyIndex = Panel(index: index)
        hide(panel: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    /// Hides the panel by its name.
    /// - Parameters:
    ///   - panel: the panel that contains the given view controller
    ///   - animated: whether to animate the hiding transition. default value is true.
    ///   - releaseViewController: whether to release the view controller upon hiding. when not specified uses the value in PanelViewConfiguration.
    ///   - completion: notifies the called that hiding is complete.
    func hide(panel: Panel, animated: Bool = true, releaseViewController: Trilean = .default, completion: (() -> Void)? = nil) {
        func hideAppropriatePanel() {
            panelMappings[panel]?.isHidden = true
            
            hideViewResizer(associatedPanel: panel)
            
            showEmptyStateIfNecessary()
        }
        
        func _performPanelHiding(panel: Panel, animated: Bool, hidingCompleted: (() -> Void)?) {
            if panel.index != 0, animated {
                // we shouldn't animate hiding of the main panel
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hideAppropriatePanel()
                }, completion: { _ in
                    hidingCompleted?()
                })
            } else {
                hideAppropriatePanel()
                hidingCompleted?()
            }
        }
        
        _performPanelHiding(panel: panel, animated: animated, hidingCompleted: { [weak self] in
            guard let strongSelf = self else { return }
            let shouldViewControllerBeReleasedFromMemory: Bool
            switch releaseViewController {
            case .default:
                shouldViewControllerBeReleasedFromMemory = strongSelf.configuration.autoReleaseViewControllers
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
            panel.isHidden = true
            hideViewResizer(associatedPanel: eachPanelIndex)
        }
        
        showEmptyStateIfNecessary()
    }
    
    /// when there are no visible panels, we show the empty view
    private func showEmptyStateIfNecessary() {
        if let validEmptyStateView = emptyView {
            var atLeastOnePanelVisible = false
            for eachPanel in mainStackView.subviews {
                if !eachPanel.isHidden {
                    // at least one panel is visible
                    atLeastOnePanelVisible = true
                    break
                }
            }
            
            if !atLeastOnePanelVisible {
                // all panels are hidden, show the empty view
                self.view.bringSubviewToFront(validEmptyStateView)
                validEmptyStateView.isHidden = false
                
            }
        }
        self.view.backgroundColor = .systemBackground
    }
    
    private func hideViewResizer(associatedPanel: Panel) {
        if let associatedResizer = dividerMappings[associatedPanel] {
            let uniqueConstraintIdentifier = "\(_dividerConstraintIdentifier)\(associatedResizer.tag)"
            if let constraintThatNeedToAltered = self.view.constraints.first(where: { $0.identifier == uniqueConstraintIdentifier }) {
                constraintThatNeedToAltered.constant = 0
            }
        }
    }
}
