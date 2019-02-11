//
//  HowToPlayViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit

class HowToPlayViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    var player: Player?
    var qrCodeImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: 1300)
        
        do {
            player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            
            qrCodeImage = ProfileViewController.generateQRCode(from: player?.address ?? "no address")
            
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    @IBAction func addBalanceBtnTapped(_ sender: Any) {
        do {
            let vc = try instantiateViewController(identifier: "addBalanceViewControllerID", storyboardName: "Profile") as? AddBalanceViewController
            vc?.qrImage = qrCodeImage
            vc?.player = player
            
            present(vc!, animated: true, completion: nil)
        } catch {
            let alertView = monsterAlertView(title: "Ups", message: "Something happened")
            present(alertView, animated: false, completion: nil)
        }
    }
}
