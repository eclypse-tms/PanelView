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
    
    /// when this value is not nil, the view resizers will be highlighted when
    /// a pointer hovers over them. when this value is nil, no highlighting will
    /// occur.
    ///
    /// only applicable to macCatalyst
    public var viewResizerHighlightColorOnHover: UIColor?
}

public extension PanelViewConfiguration {
    init() {
        self.orientation = .horizontal
        self.emptyStateView = nil
        self.preferredEmptyStateViewSize = nil
        self.viewResizerHighlightColorOnHover = nil
    }
}
