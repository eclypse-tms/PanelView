//
//  UIViewController+Extensions.swift
//  
//
//  Created by eclypse on 7/12/24.
//

import UIKit

public extension UIViewController {
    /// adds a child view controller and makes it full screen
    func addFullScreen(childViewController child: UIViewController) {
        guard child.parent == nil else {
            //if the child already has a parent, it won't add anything
            return
        }
        
        addChild(child)
        view.addSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: child.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
        ])
        
        child.didMove(toParent: self)
    }
    
    /// removes an existing child view controller
    func remove(childViewController child: UIViewController?) {
        guard let validChild = child else {
            return
        }
        
        guard validChild.parent != nil else {
            //you cannot remove something that doesn't have a parent
            return
        }
        
        validChild.willMove(toParent: nil)
        validChild.view.removeFromSuperview()
        validChild.removeFromParent()
    }
    
    /// removes a child view controller from its parent
    func removeSelfFromParent() {
        guard self.parent != nil else {
            //you cannot remove something that doesn't have a parent
            return
        }
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
