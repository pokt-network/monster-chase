//
//  AddBalanceViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/1/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AddBalanceViewController: UIViewController, WKUIDelegate {
    // Outlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var qrCodeBackgroundView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var faucetButton: UIButton!
    
    // Variables
    var player: Player?
    var qrImage: UIImage?
    let faucetURL = URL(string: "https://gitter.im/aionnetwork/mastery_faucet")
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        
        if player == nil {
            do {
                player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            } catch let error as NSError {
                print("Failed to retrieve current player with error: \(error)")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Styling
        qrCodeBackgroundView.layer.borderWidth = 2
        qrCodeBackgroundView.layer.borderColor = AppColors.base.cgColor()
        qrCodeBackgroundView.layer.cornerRadius = qrCodeBackgroundView.frame.height / 2
        
        faucetButton.layer.cornerRadius = faucetButton.frame.height / 2
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    override func refreshView() throws {
        faucetButton.layer.cornerRadius = 5
        
        addressTextField.text = player?.address ?? "0x0000000000000000"
        qrCodeImage.image = qrImage ?? #imageLiteral(resourceName: "CIRCLE STAMP x1")
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        if webView.isHidden {
            self.dismiss(animated: false, completion: nil)
        }else {
            webView.isHidden = true
            backButton.layer.borderWidth = 0
        }
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        // TODO: Create error system
        let showError = {
            let alertView = self.monsterAlertView(title: "Error:", message: "Address field is empty, please try again later")
            self.present(alertView, animated: false, completion: nil)
        }
        guard let isAddressEmpty = addressTextField.text?.isEmpty else {
            showError()
            return
        }
        if isAddressEmpty {
            showError()
            return
        } else {
            let alertView = monsterAlertView(title: "Success:", message: "Your Address has been copied to the clipboard.")
            present(alertView, animated: false, completion: nil)
            UIPasteboard.general.string = addressTextField.text
        }
    }
    
    func showWebFor(exchange: URL) {
        webView.isHidden = false
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.cgColor
        
        let request = URLRequest(url: exchange)
        webView.load(request)
    }
    
    @IBAction func faucetbyButtonPressed(_ sender: Any) {
        showWebFor(exchange: faucetURL!)
    }
    
}
