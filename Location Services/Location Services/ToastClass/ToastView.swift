//
//  ToastView.swift
//  Location Services
//
//  Created by Anshul Kapoor on 20/03/20.
//  Copyright © 2020 Anshul Kapoor. All rights reserved.
//

import Foundation
import UIKit

class ToastView: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view: MyView!
    @IBOutlet weak var imageV:UIImageView!
    
    // used to move the view on the screen
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var left: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setAlpha(alpha: CGFloat) {
        DispatchQueue.main.async {
            if alpha <= 1.0 {
                self.view.alpha = alpha
            }
            else {
                self.view.alpha = 1.0
            }
        }
    }
    
}
