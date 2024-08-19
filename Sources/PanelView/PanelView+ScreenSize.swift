//
//  PanelView.swift
//  
//
//  Created by eclypse on 7/17/24.
//

import UIKit

public protocol ScreenAdaptation {
    /// reports current horizontal screen size from UITraitCollection
    var horizontalScreenSize: UIUserInterfaceSizeClass { get }
    
    /// reports current vertical screen size from UITraitCollection
    var verticalScreenSize: UIUserInterfaceSizeClass { get }
    
    /// the panels that are currently being displayed in an ascending order.
    ///
    /// If you are using a single panel in an horizontally compact environment,
    /// you can use this information to see if panel view is presenting multiple or
    /// single panels.
    var visiblePanels: [Panel] { get }
    
    /// takes the content from all the visible panels and puts them in the center panel in a navigation hiearachy.
    ///
    /// panels with the lower index are placed at the bottom of the stack while the panel with the highest index
    /// becomes the visible view controller in the navigation stack.
    func combineAll()
}

extension PanelView: ScreenAdaptation {
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        var detectedChanges: ScreenSizeChanges = []
        if let validPreviousTraitCollection = previousTraitCollection {
            if traitCollection.horizontalSizeClass == .regular, validPreviousTraitCollection.horizontalSizeClass != .regular {
                // width is now wide mode but it used to be compact
                detectedChanges.insert(.horizontalSizeChangedFromCompactToRegular)
            } else if traitCollection.horizontalSizeClass != .regular, validPreviousTraitCollection.horizontalSizeClass == .regular {
                // width is now compact mode but it used to be wide
                detectedChanges.insert(.horizontalSizeChangedFromRegularToCompact)
            }
        
            if traitCollection.verticalSizeClass == .regular, validPreviousTraitCollection.verticalSizeClass != .regular {
                // height is now wide mode but it used to be compact
                detectedChanges.insert(.verticalSizeChangedFromCompactToRegular)
            } else if traitCollection.verticalSizeClass != .regular, validPreviousTraitCollection.verticalSizeClass == .regular {
                // height is now compact mode but it used to be wide
                detectedChanges.insert(.verticalSizeChangedFromRegularToCompact)
            }
        }
        
        if !detectedChanges.isEmpty {
            delegate?.didChangeSize(panelView: self, changes: detectedChanges)
            panelSizeChangedSubject.send(detectedChanges)
        }
    }
    
    public var verticalScreenSize: UIUserInterfaceSizeClass {
        if self.traitCollection.verticalSizeClass == .regular {
            return .regular
        } else {
            return .compact
        }
    }
    
    public var horizontalScreenSize: UIUserInterfaceSizeClass {
        if self.traitCollection.horizontalSizeClass == .regular {
            return .regular
        } else {
            return .compact
        }
    }
    
    public func combineAll() {
        var newNavigationStack = [UIViewController]()
        for eachVisiblePanel in visiblePanels {
            if let navControllerManagedViewControllers = viewControllers[eachVisiblePanel]?.viewControllers {
                newNavigationStack.append(contentsOf: navControllerManagedViewControllers)
            }
        }
        
        reset()
        show(navigationStack: newNavigationStack, for: .center, animated: false)
    }
}
