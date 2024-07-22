//
//  PanelViewHidingManager.swift
//
//
//  Created by eclypse on 7/16/24.
//

import UIKit

public protocol PanelViewHidingManager {
    /// hides the specified panel, optionally animating the transition and notifies the caller when the hiding is complete
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hide(panel: Panel, animated: Bool, completion: (() -> Void)?)
    
    /// hides the specified panel and optionally animating the transition
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hide(panel: Panel, animated: Bool)
    
    /// hides the specified panel while animating the transition
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hide(panel: Panel)
    
    /// hides the specified panel at the index, optionally animating the transition and notifies the caller when the hiding is complete
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hide(index: Int, animated: Bool, completion: (() -> Void)?)
    
    /// hides the specified panel at the index, optionally animating the transition
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hide(index: Int, animated: Bool)
    
    /// hides the specified panel at the index while animating the transition
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hide(index: Int)
    
    /// hides the panel that is associated with the provided view controller and
    /// optionally animates the transition and notifies the caller when the hiding is complete
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hidePanel(containing viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    
    /// hides the panel that is associated with the provided view controller and
    /// optionally animates the transition
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hidePanel(containing viewController: UIViewController, animated: Bool)
    
    /// hides the panel that is associated with the provided view controller while animating the transition
    ///
    /// the panel can be redisplayed by calling show(panel:animated:).
    func hidePanel(containing viewController: UIViewController)
    
    /// hides all the panels and removes all the view controllers and swiftUI views from the layout.
    /// you will have to re-add view controllers before you want to show another panel 
    func reset()
}

extension PanelView: PanelViewHidingManager {
    public func hidePanel(containing viewController: UIViewController) {
        hidePanel(containing: viewController, animated: true, completion: nil)
    }
    
    public func hidePanel(containing viewController: UIViewController, animated: Bool) {
        hidePanel(containing: viewController, animated: animated, completion: nil)
    }
    
    public func hidePanel(containing viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        let panelToHide: Panel? = presents(viewController: viewController)
        
        if let discoveredPanelToHide = panelToHide {
            hide(panel: discoveredPanelToHide, animated: animated, completion: completion)
        }
    }
    
    private func hideViewResizer(associatedPanel: Panel) {
        if let associatedResizer = dividerMappings[associatedPanel] {
            let uniqueConstraintIdentifier = "\(_dividerConstraintIdentifier)\(associatedResizer.tag)"
            if let constraintThatNeedToAltered = self.view.constraints.first(where: { $0.identifier == uniqueConstraintIdentifier }) {
                constraintThatNeedToAltered.constant = 0
            }
        }
    }
    
    public func hide(index: Int) {
        hide(index: index, animated: true, completion: nil)
    }
    
    public func hide(index: Int, animated: Bool) {
        hide(index: index, animated: animated, completion: nil)
    }
    
    /// hides the panel from the view and removes the view controller from the view hierarchy
    /// by its index. the view controller that was inside the panel may be released from memory.
    public func hide(index: Int, animated: Bool, completion: (() -> Void)?) {
        let onTheFlyIndex = Panel(index: index)
        hide(panel: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    public func hide(panel: Panel) {
        hide(panel: panel, animated: true, completion: nil)
    }
    
    public func hide(panel: Panel, animated: Bool) {
        hide(panel: panel, animated: animated, completion: nil)
    }
    
    /// hides the panel from the view and removes the view controller from the view hierarchy.
    /// the view controller that was inside the panel may be released from memory.
    public func hide(panel: Panel, animated: Bool, completion: (() -> Void)?) {
        _performPanelHiding(panel: panel, animated: animated, hidingCompleted: { [weak self] in
            guard let strongSelf = self else { return }
            if let previousVC = strongSelf.viewControllers[panel] {
                previousVC.removeSelfFromParent()
                strongSelf.viewControllers.removeValue(forKey: panel)
            }
            completion?()
        })
    }
    
    private func _performPanelHiding(panel: Panel, animated: Bool, hidingCompleted: (() -> Void)?) {
        func hideAppropriatePanel() {
            panelMappings[panel]?.isHidden = true
            
            hideViewResizer(associatedPanel: panel)
            
            showEmptyStateIfNecessary()
        }
        
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
    
    public func reset() {
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
}
