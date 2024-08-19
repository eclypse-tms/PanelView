//
//  PanelView+VisibilityTest.swift
//
//
//  Created by Nessa Kucuk, Turker on 8/19/24.
//

import UIKit

public extension PanelView {
    /// returns the visible view controller on that panel
    func topViewController(for panel: Panel) -> UIViewController? {
        return viewControllers[panel]?.topViewController
    }
    
    /// returns the visible view controller on that panel
    func topViewController(index: Int) -> UIViewController? {
        let onTheFlyPanelIndex = Panel(index: index)
        return viewControllers[onTheFlyPanelIndex]?.topViewController
    }
    
    /// returns a list of all visible panels sorted in ascending order by each panel's index
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
    
    /// returns the panel index of the provided viewController if it is in the view hierarchy
    func index(of viewController: UIViewController) -> Panel? {
        var vcPresentedIn: Panel?
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
    var currentlyVisiblePanel: Panel? {
        currentlyVisiblePanelAndItsView?.0
    }
    
    /// this function is only valid if the current mode is single panel
    /// when called when the current mode is not single, then it returns nil
    var currentlyVisiblePanelView: UIView? {
        currentlyVisiblePanelAndItsView?.1
    }
    
    /// this function is only valid if the current mode is single panel
    /// when called when the current mode is not single, then it returns nil
    var currentlyVisiblePanelAndItsView: (Panel, UIView)? {
        if isSinglePanelMode {
            let possibleVisiblePanel = panelMappings.first(where: { isVisible(panel: $0.key) })
            return possibleVisiblePanel
        } else {
            return nil
        }
    }
}
