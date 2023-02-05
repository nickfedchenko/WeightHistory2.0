//
//  UIViewController+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

extension UIViewController {
        
    func showSimpleAlert(titleText: String) {
        let alert = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func showSimpleAlertWithCompletion(titleText: String, complition: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: complition))
        self.present(alert, animated: true)
    }
}
