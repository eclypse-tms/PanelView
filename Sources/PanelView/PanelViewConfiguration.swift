//
//  PanelViewConfiguration.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit

public struct PanelViewConfiguration {
    public var orientation: PanelOrientation
    
    public var emptyStateView: UIView?
    
    public var preferredEmptyStateViewSize: CGSize?
}

public extension PanelViewConfiguration {
    init() {
        self.orientation = .horizontal
        self.emptyStateView = nil
        self.preferredEmptyStateViewSize = nil
    }
}
