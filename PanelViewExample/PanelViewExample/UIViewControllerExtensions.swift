//
//  UIViewControllerExtensions.swift
//  PanelViewExample
//
//  Created by eclypse on 7/26/24.
//

import UIKit

extension UIViewController {
    func showOneActionAlert(title: String?, message: String?, positiveButtonTitle: String? = nil, positiveAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: (positiveButtonTitle ?? "OK"), style: .default, handler: positiveAction))
        self.present(alert, animated: true, completion: nil)
    }
}
