//
//  PanelMode.swift
//  
//
//  Created by eclypse on 7/29/24.
//

import Foundation

public enum PanelMode: Int {
    /// allows PanelView to display multiple panels side-by-side or top-to-bottom.
    /// the default option.
    case multi
    
    /// limits PanelView to show only one Panel at a time. When you show a panel
    /// in Single panel mode the existing panel is hidden.
    case single
    
}
