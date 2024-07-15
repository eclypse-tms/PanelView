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
// public typealias PanelViewIndex = Int

open class PanelViewIndex: Hashable, Comparable {
    let tag: String
    let index: Int
    
    public init(index: Int, tag: String = "") {
        self.tag = tag
        self.index = index
    }
    
    public static func == (lhs: PanelViewIndex, rhs: PanelViewIndex) -> Bool {
        return lhs.index == rhs.index
    }
    
    public static func < (lhs: PanelViewIndex, rhs: PanelViewIndex) -> Bool {
        return lhs.index < rhs.index
    }
    
    open func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    public static var navigationPanel: PanelViewIndex {
        return PanelViewIndex(index: -2, tag: "navigation")
    }
    
    public static var navigationDetailPanel: PanelViewIndex {
        return PanelViewIndex(index: -1, tag: "navigationDetail")
    }
    
    public static var centerPanel: PanelViewIndex {
        return PanelViewIndex(index: 0, tag: "mainScreen")
    }
    
    public static var inspectorPanel: PanelViewIndex {
        return PanelViewIndex(index: 1, tag: "inspector")
    }
    
    public static var inspectorDetailPanel: PanelViewIndex {
        return PanelViewIndex(index: 2, tag: "inspectorDetail")
    }
}

open class Turker: PanelViewIndex {
    public static var hola: PanelViewIndex {
        return PanelViewIndex(index: 2, tag: "hola")
    }
}
