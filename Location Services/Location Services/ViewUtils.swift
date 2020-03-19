//
//  ViewUtils.swift
//  Location Services
//
//  Created by Anshul Kapoor on 18/03/20.
//  Copyright © 2020 Anshul Kapoor. All rights reserved.
//

import Foundation
import UIKit
/*
 Custom UITEXTFIELD to disable copy, paste, delete and cut
 */

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
