//
//  MacPanGestureRecognizer.swift
//
//
//  Created by eclypse on 7/12/24.
//

import UIKit

class MacPanGestureRecognizer: UIPanGestureRecognizer {
    var orientation: PanelOrientation = .horizontal
    
    private var initialTouchLocation: CGPoint?
    private let minOffset: CGFloat = 1

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        #if targetEnvironment(macCatalyst)
        self.initialTouchLocation = touches.first?.location(in: self.view)
        #endif
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        #if targetEnvironment(macCatalyst)
        if self.state == .possible {
            let touchPoint: CGFloat
            let initialTouchPoint: CGFloat
            switch orientation {
            case .vertical:
                touchPoint = touches.first?.location(in: self.view).y ?? 0
                initialTouchPoint = self.initialTouchLocation?.y ?? 0
            case .horizontal:
                touchPoint = touches.first?.location(in: self.view).x ?? 0
                initialTouchPoint = self.initialTouchLocation?.x ?? 0
            }
            
            let movedSufficiently =  abs (touchPoint - initialTouchPoint) >= self.minOffset
            if movedSufficiently {
                self.state = .changed
            }
        }
        #endif
    }
}
