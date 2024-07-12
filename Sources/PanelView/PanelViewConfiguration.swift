//
//  PanelViewConfiguration.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit

public struct PanelViewConfiguration {
    public var orientation: PanelOrientation
    
    public var emptyViewImage: UIImage?
    
    public var emptyViewImageDimensions: CGSize?
    
    public var emptyViewLabel: UILabel?
}

public extension PanelViewConfiguration {
    init() {
        self.orientation = .horizontal
        self.emptyViewImage = nil
        self.emptyViewImageDimensions = nil
        self.emptyViewLabel = nil
    }
}
