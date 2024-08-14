//
//  Panel+Names.swift
//
//
//  Created by eclypse on 7/16/24.
//

import Foundation

public extension PanelIndex {
    /// main panel that appears in the center
    public static var center: PanelIndex {
        return PanelIndex(index: 0, tag: "center")
    }
    
    /// an example panel that appears to the left of the center panel
    /// in horizontal mode.
    static var navigation: PanelIndex {
        return PanelIndex(index: -2, tag: "navigation")
    }
    
    /// an example panel that appears to the left of the center panel
    /// in horizontal mode.
    static var navigationDetail: PanelIndex {
        return PanelIndex(index: -1, tag: "navigationDetail")
    }
    
    /// an example panel that appears to the right of the center panel
    /// in horizontal mode.
    static var inspector: PanelIndex {
        return PanelIndex(index: 1, tag: "inspector")
    }
    
    /// an example panel that appears to the right of the center panel
    /// in horizontal mode.
    static var inspectorDetail: PanelIndex {
        return PanelIndex(index: 2, tag: "inspectorDetail")
    }
}
