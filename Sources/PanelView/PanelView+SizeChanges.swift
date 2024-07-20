//
//  PanelView.swift
//  
//
//  Created by eclypse on 7/17/24.
//

import UIKit

/// enumerates the possible screen size changes that may happen to due to
/// device trait changes such as orientation or app window resizing
public struct ScreenSizeChanges: OptionSet, Hashable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// screen changed to regular size horizontally
    public static let horizontalSizeChangedFromCompactToRegular = ScreenSizeChanges(rawValue: 1 << 0)
    
    /// screen changed to compact size horizontally
    public static let horizontalSizeChangedFromRegularToCompact = ScreenSizeChanges(rawValue: 1 << 1)
    
    /// screen changed to regular size vertically
    public static let verticalSizeChangedFromCompactToRegular = ScreenSizeChanges(rawValue: 1 << 2)
    
    /// screen changed to compact size vertically
    public static let verticalSizeChangedFromRegularToCompact = ScreenSizeChanges(rawValue: 1 << 3)
    
    /// indicates that panel view became compact size either in horizontal or vertical direction
    public static let anyDimensionChangedToCompact: ScreenSizeChanges = [.horizontalSizeChangedFromRegularToCompact, .verticalSizeChangedFromRegularToCompact]
    
    /// indicates that panel view became regular size either in horizontal or vertical direction
    public static let anyDimensionChangedToRegular: ScreenSizeChanges = [.horizontalSizeChangedFromCompactToRegular, .verticalSizeChangedFromCompactToRegular]
}

public extension PanelView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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
        }
    }
    
    /// takes the content from all the visible panels and puts them in the center panel in a navigation hiearachy.
    ///
    /// panels with the lower index are placed at the bottom of the stack while the panel with the highest index
    /// becomes the visible view controller in the navigation stack.
    func combineAll() {
        let sortedVisiblePanels = panelMappings.compactMap { (eachPanelIndex, eachPanel) -> Panel? in
            if isVisible(panel: eachPanelIndex) {
                return eachPanelIndex
            } else {
                return nil
            }
        }.sorted()
        
        var newNavigationStack = [UIViewController]()
        for eachVisiblePanel in sortedVisiblePanels {
            if let navControllerManagedViewControllers = viewControllers[eachVisiblePanel]?.viewControllers {
                newNavigationStack.append(contentsOf: navControllerManagedViewControllers)
            }
        }
        
        reset()
        show(navigationStack: newNavigationStack, for: .center, animated: false)
    }
}
