//
//  PanelOrientation.swift
//
//
//  Created by eclypse on 7/12/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Determines how the panels should be laid out.
public enum PanelOrientation: Int {
    
    /// lays the panels in a vertical fashion
    case vertical
    
    /// lays the panels in a horizontal fashion
    case horizontal
    
    var axis: NSLayoutConstraint.Axis {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
}
