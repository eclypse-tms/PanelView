//
//  PanelViewSwiftUICoordinator.swift
//  
//
//  Created by Nessa Kucuk, Turker on 8/23/24.
//

import UIKit


public class PanelViewSwiftUICoordinator {
    /// associated panel view
    public weak var panelView: PanelView?
    
    @objc
    func didHoverOnSeparator(_ recognizer: UIHoverGestureRecognizer) {
        panelView?.didHoverOnSeparator(recognizer)
    }
}
