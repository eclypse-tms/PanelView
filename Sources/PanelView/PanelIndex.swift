//
//  PanelIndex.swift
//
//
//  Created by eclypse on 7/12/24.
//

import Foundation

/// Allows the consumers of this library to refer to panels with names
/// instead of a plain indices.
///
/// All panels have an index. Index determines where the panel is laid out
/// relative to the center panel which always occupies 0 index. This means
/// that panels with negative index are laid out to the left of the center
/// panel in horizontal mode. Conversely, the panels with negative index
/// are laid out above the center in vertical mode.
///
/// If the panels that you are working with are stable, you should consider
/// creating your own panels so that you can show or hide panels with names
/// instead of indices.
///
/// In order to provide your own names for panels, you extend PanelIndex
/// as in this example:
///     
///     public static var secondary: PanelIndex {
///       return PanelIndex(index: -2, tag: "secondary")
///     }
///
/// Then you refer to the panels in your code as below:
///
///     panelView.show(viewController: myVC, for: .secondary)
///     ...
///     panelView.hide(panel: .secondary)
///
open class PanelIndex: Hashable, Comparable, CustomDebugStringConvertible {
    /// the tag is used to identify this panel. The tag is optional and
    /// only used for debugging purposes.
    ///
    /// The value of tag member is not used to test for equality.
    public let tag: String
    
    /// The primary value that separates one panel from another is its index value.
    public let index: Int
    
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
    
    public var debugDescription: String {
        if tag.isEmpty {
            return "panel index: \(index)"
        } else {
            return "tag: \(tag), panel index: \(index)"
        }
    }
    
    public static var center: PanelIndex {
        return PanelIndex(index: 0, tag: "center")
    }
}
