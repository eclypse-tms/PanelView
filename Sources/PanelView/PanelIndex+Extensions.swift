//
//  PanelIndex+Extensions.swift
//  
//
//  Created by eclypse on 7/16/24.
//

import Foundation

public extension Panel {
    /// an example panel that appears to the left of the center panel
    /// in horizontal mode.
    static var navigation: Panel {
        return Panel(index: -2, tag: "navigation")
    }
    
    /// an example panel that appears to the left of the center panel
    /// in horizontal mode.
    static var navigationDetail: Panel {
        return Panel(index: -1, tag: "navigationDetail")
    }
    
    /// an example panel that appears to the right of the center panel
    /// in horizontal mode.
    static var inspector: Panel {
        return Panel(index: 1, tag: "inspector")
    }
    
    /// an example panel that appears to the right of the center panel
    /// in horizontal mode.
    static var inspectorDetail: Panel {
        return Panel(index: 2, tag: "inspectorDetail")
    }
}
