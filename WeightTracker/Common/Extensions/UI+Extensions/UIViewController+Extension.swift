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
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
}
