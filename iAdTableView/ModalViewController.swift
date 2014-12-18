//
//  ModalViewController.swift
//  iAdContainer
//
//  Created by Joseph Duffy on 17/12/2014.
//  Copyright (c) 2014 Yetii Ltd. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
