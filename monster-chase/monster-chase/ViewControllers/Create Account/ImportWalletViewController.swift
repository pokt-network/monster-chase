//
//  ImportWalletViewController.swift
//  monster-chase
//
//  Created by Luis De Leon on 4/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import PocketAion
import CoreData

class ImportWalletViewController: UIViewController {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var privateKeyTextField: UITextField!
    
    var currentPlayer: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Styling
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    // MARK: - Tools
    override func refreshView() throws {
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutside)
    }
    
    func showInvalidPrivateKeyError() {
        self.present(self.monsterAlertView(title: "Error", message: "You need to input a valid private key"), animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction func dismissViewController(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func importWallet(_ sender: Any) {
        guard let privateKey = self.privateKeyTextField.text else {
            showInvalidPrivateKeyError()
            return
        }
        
        if privateKey.isEmpty {
            showInvalidPrivateKeyError()
            return
        }
        
        guard let parsedPrivateKey = HexStringUtil.removeLeadingZeroX(hex: privateKey) else {
            showInvalidPrivateKeyError()
            return
        }
        
        do {
            let _ = try PocketAion.importWallet(privateKey: parsedPrivateKey, subnetwork: AppConfiguration.subnetwork, address: "0xa05b88ac239f20ba0a4d2f0edac8c44293e9b36fa937fb55bf7a1cd61a60f036", data: nil)
            let vc = try self.instantiateViewController(identifier: "newWalletID", storyboardName: "CreateAccount") as? NewWalletViewController
            vc?.walletPrivateKey = parsedPrivateKey
            self.navigationController?.pushViewController(vc!, animated: false)
        } catch {
            showInvalidPrivateKeyError()
            return
        }
        
    }
}

