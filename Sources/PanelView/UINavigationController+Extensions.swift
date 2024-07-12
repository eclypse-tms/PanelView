//
//  UINavigationController+Extensions.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import Foundation

import UIKit

extension UINavigationController {
    func replaceTopViewController(with this: UIViewController, animated: Bool) {
        var newStack = Array(viewControllers.dropLast(1))
        newStack.append(this)
        setViewControllers(newStack, animated: animated)
    }
    
    @discardableResult
    func popToViewController<T>(usingType viewControllerType: T.Type, animated: Bool) -> [UIViewController]? {
        let candidateVC = viewControllers.first(where: { eachVCInStack in
            let typeOfThisViewController = type(of: eachVCInStack)
            return viewControllerType == typeOfThisViewController
        })
        
        if let validVC = candidateVC {
            return popToViewController(validVC, animated: animated)
        } else {
            return nil
        }
    }
}
