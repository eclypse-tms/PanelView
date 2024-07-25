//
//  File.swift
//  
//
//  Created by eclypse on 7/19/24.
//

import UIKit

public protocol PanelSizeControls {
    /// makes panel resizable within the previously provided min and max values.
    func enableResizing(for panel: PanelIndex)
    
    /// fixes panel's current size and stops users from being able to resize.
    func disableResizing(for panel: PanelIndex)
}

extension PanelView: PanelSizeControls {
    public func enableResizing(for panel: PanelIndex) {
        if let viewDivider = dividerMappings[panel] {
            // add hover gesture
            let viewResizerHoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(didHoverOnSeparator(_:)))
            viewResizerHoverGesture.name = "hover_on_divider"
            viewDivider.addGestureRecognizer(viewResizerHoverGesture)
            
            // add drag gesture
            let viewDividerDragGesture = MacPanGestureRecognizer(target: self, action: #selector(didDragSeparator(_:)))
            viewDividerDragGesture.name = "drag_divider"
            viewDividerDragGesture.orientation = configuration.orientation
            viewDivider.addGestureRecognizer(viewDividerDragGesture)
        }
    }
    
    public func disableResizing(for panel: PanelIndex) {
        if let associatedDivider = dividerMappings[panel] {
            var gesturesToRemove = [UIGestureRecognizer]()
            associatedDivider.gestureRecognizers?.forEach({ eachGesture in
                if eachGesture.name == "hover_on_divider" {
                    gesturesToRemove.append(eachGesture)
                } else if eachGesture.name == "drag_divider" {
                    gesturesToRemove.append(eachGesture)
                }
            })
            
            gesturesToRemove.forEach { eachGestureToRemove in
                associatedDivider.removeGestureRecognizer(eachGestureToRemove)
            }
        }
    }
}
