//
//  Bundle.swift
//  
//
//  Created by eclypse on 8/15/24.
//

import Foundation

public extension PanelView {
    static var assetBundle: Bundle {
        get {
            #if SWIFT_PACKAGE
            return Bundle.module
            #else
            return Bundle(for: PanelView.self)
            #endif
        }
    }
}
