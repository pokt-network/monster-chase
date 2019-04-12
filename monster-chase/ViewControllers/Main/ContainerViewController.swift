//
//  ContainerViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import SidebarOverlay

class ContainerViewController: SOContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuSide = .left
        self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "chasingViewControllerID")
        self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "menuViewControllerID")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func refreshView() throws {
        
    }
    
}
