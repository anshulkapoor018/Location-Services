//
//  ViewUtils.swift
//  Location Services
//
//  Created by Anshul Kapoor on 18/03/20.
//  Copyright © 2020 Anshul Kapoor. All rights reserved.
//

import Foundation
import UIKit

class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.gray
    @IBInspectable var shadowOpacity: Float = 0.8
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

class disableUITextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == "paste:" {
            return false
        }
        if action == "copy:" {
            return false
        }
        if action == "delete:" {
            return false
        }
        if action == "cut:" {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
