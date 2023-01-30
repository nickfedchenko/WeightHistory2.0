//
//  UIView+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 30.01.2023.
//

import UIKit

extension UIView {
    
    func slideUpFromOutside(duration: TimeInterval = 0.25, frame: CGRect, viewHeight: CGFloat) {
        self.transform = CGAffineTransform(translationX: 0, y: frame.height)
        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: frame.height - viewHeight)
        }, completion: nil)
    }
    
    func slideOutToOutside(duration: TimeInterval = 0.25, frame: CGRect, viewHeight: CGFloat) {
        self.transform = CGAffineTransform(translationX: 0, y: frame.height - viewHeight)
        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: frame.height)
        }, completion: {_ in
            self.removeFromSuperview()
        })
    }
    
    func popIn(duration: TimeInterval = 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
                self.alpha = 1
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
        
    func popOut(duration: TimeInterval = 0.1, completion: @escaping (Bool) -> Void) {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }, completion: completion)
        }
}
