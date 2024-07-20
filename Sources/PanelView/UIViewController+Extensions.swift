//
//  UIViewController+Extensions.swift
//  
//
//  Created by eclypse on 7/12/24.
//

import UIKit

extension UIViewController {
    /*
    /// replaces this child view controller with the one that is currently displayed
    /// while pinning the child's view to the parent's bounds
    func swap(childViewController: UIViewController, within thisView: UIView) {
        
        let alreadyAddedChildVC = children.first(where: { $0 == childViewController })
        
        if alreadyAddedChildVC == nil {
            //this child view controller is not one of the children controllers
            //it can be added
            
            //first remove all existing child controllers
            children.forEach { eachChildViewController in
                remove(childViewController: eachChildViewController)
            }
        
            guard childViewController.parent == nil else {
                //if the child already has a parent, it won't add anything
                return
            }
            
            addChild(childViewController)
            view.addSubview(childViewController.view)
            
            childViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                thisView.leadingAnchor.constraint(equalTo: childViewController.view.leadingAnchor),
                thisView.trailingAnchor.constraint(equalTo: childViewController.view.trailingAnchor),
                thisView.topAnchor.constraint(equalTo: childViewController.view.topAnchor),
                thisView.bottomAnchor.constraint(equalTo: childViewController.view.bottomAnchor)])
            
            childViewController.didMove(toParent: self)
        }
    }
    
    //----------------------------------------------//
    /// new swap view controller functionality as obtained from stackoverflow
    func swapAndAnimate(newChildViewController: UIViewController, parentViewController: UIViewController, within thisView: UIView?) {
        let existingChildVC = parentViewController.children.first
        
        if parentViewController.children.first(where: { $0 == newChildViewController }) == nil {
            //this child view controller is not one of the children controllers
            //it can be added to the parent
            
            if newChildViewController.parent == nil {
                //only process this request, if the child view controller has no parent
                
                // associate the child with the parent
                parentViewController.addChild(newChildViewController)
                
                //determine which view to add it to
                let viewToAddChildViewControllerTo: UIView = thisView ?? parentViewController.view
                
                //add child's view as a subview
                viewToAddChildViewControllerTo.addSubview(newChildViewController.view)
                
                //enable constraints
                newChildViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    viewToAddChildViewControllerTo.leadingAnchor.constraint(equalTo: newChildViewController.view.leadingAnchor),
                    viewToAddChildViewControllerTo.trailingAnchor.constraint(equalTo: newChildViewController.view.trailingAnchor),
                    viewToAddChildViewControllerTo.topAnchor.constraint(equalTo: newChildViewController.view.topAnchor),
                    viewToAddChildViewControllerTo.bottomAnchor.constraint(equalTo: newChildViewController.view.bottomAnchor)])
                
                newChildViewController.view.alpha = 0
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                    newChildViewController.view.alpha = 1
                    existingChildVC?.view.alpha = 0
                }) { (finished) in
                    newChildViewController.didMove(toParent: parentViewController)
                                        
                    //you cannot remove if the childviewcontroller does not have a parent if
                    existingChildVC?.willMove(toParent: nil)
                    existingChildVC?.view.removeFromSuperview()
                    existingChildVC?.removeFromParent()
                }
            } else {
                //new child view controller is already associated with a parent - nothing to do
            }
        } else {
            //new child view controller is already one of the children view controller - nothing to do
        }
    }

    private func addSubview(subView:UIView, toView parentView: UIView) {
        parentView.layoutIfNeeded()
        parentView.addSubview(subView)
        
        subView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        subView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive  = true
    }
    //----------------------------------------------//
    
    /// adds a child view controller and makes it the only child by removing all other children that may have been added before
    @objc
    func addChildAndRemoveOthers(childViewController: UIViewController) {
        children.forEach { eachChildViewController in
            remove(childViewController: eachChildViewController)
        }
        addFullScreen(childViewController: childViewController)
    }
    
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
    */
    
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
