//
//  PanelViewIndex.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import Foundation

/// 0 means center panel. when the panels are split vertically,
/// negative values indicate those panels that are above the center panel. when
/// the panels are split horizontally, negative values indicate those panels
/// that are to the left of the center panel.

open class PanelIndex: Hashable, Comparable {
    /// Tag is used to identify or name this panel for the benefit of developers.
    /// The value of tag member is not used to test for equality.
    let tag: String
    
    /// The primary thing that separates one panel from another is its index value.
    let index: Int
    
    public init(index: Int, tag: String = "") {
        self.tag = tag
        self.index = index
    }
    
    
    public static func == (lhs: PanelIndex, rhs: PanelIndex) -> Bool {
        return lhs.index == rhs.index
    }
    
    public static func < (lhs: PanelIndex, rhs: PanelIndex) -> Bool {
        return lhs.index < rhs.index
    }
    
    open func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    public static var navigationPanel: PanelIndex {
        return PanelIndex(index: -2, tag: "navigation")
    }
    
    public static var navigationDetailPanel: PanelIndex {
        return PanelIndex(index: -1, tag: "navigationDetail")
    }
    
    public static var centerPanel: PanelIndex {
        return PanelIndex(index: 0, tag: "mainScreen")
    }
    
    public static var inspectorPanel: PanelIndex {
        return PanelIndex(index: 1, tag: "inspector")
    }
    
    public static var inspectorDetailPanel: PanelIndex {
        return PanelIndex(index: 2, tag: "inspectorDetail")
    }
}

open class Turker: PanelIndex {
    public static var hola: PanelIndex {
        return PanelIndex(index: 2, tag: "hola")
    }
}
