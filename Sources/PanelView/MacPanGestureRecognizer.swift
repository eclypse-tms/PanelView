//
//  MacPanGestureRecognizer.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit

class MacPanGestureRecognizer: UIPanGestureRecognizer {
    private var initialTouchLocation: CGPoint?
    private let minHorizontalOffset: CGFloat = 1

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        #if targetEnvironment(macCatalyst)
        self.initialTouchLocation = touches.first?.location(in: self.view)
        #endif
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        #if targetEnvironment(macCatalyst)
        if self.state == .possible,
           abs((touches.first?.location(in: self.view).x ?? 0) - (self.initialTouchLocation?.x ?? 0)) >= self.minHorizontalOffset {
            self.state = .changed
        }
        #endif
    }
}
