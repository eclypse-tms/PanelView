//
//  ScreenSizeChanges.swift
//
//
//  Created by eclypse on 7/19/24.
//

import Foundation

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
