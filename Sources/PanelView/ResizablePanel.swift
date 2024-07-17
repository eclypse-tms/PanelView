//
//  ResizablePanel.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/16/24.
//

import UIKit

@objc
protocol ResizablePanel: NSObjectProtocol {
    func didHoverOnSeparator(_ recognizer: UIHoverGestureRecognizer)
    func didDragSeparator(_ gestureRecognizer: UIPanGestureRecognizer)
}
