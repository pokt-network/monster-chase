//
//  ImportWalletViewController.swift
//  monster-chase
//
//  Created by Luis De Leon on 4/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import PocketSwift
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
        
        do {
            let wallet = try PocketAion.shared?.importWallet(privateKey: privateKey, netID: AppConfiguration.netID)
            let vc = try self.instantiateViewController(identifier: "newWalletID", storyboardName: "CreateAccount") as? NewWalletViewController
            vc?.walletPrivateKey = wallet?.privateKey
            self.navigationController?.pushViewController(vc!, animated: false)
        } catch {
            showInvalidPrivateKeyError()
            return
        }
        
    }
}

