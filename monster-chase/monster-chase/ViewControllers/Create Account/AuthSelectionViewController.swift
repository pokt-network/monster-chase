//
//  AuthSelectionViewController.swift
//  monster-chase
//
//  Created by Luis De Leon on 4/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import PocketAion
import CoreData

class AuthSelectionViewController: UIViewController {
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var currentPlayer: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: - Actions
    @IBAction func goToImport(_ sender: Any) {
        do {
            let vc = try self.instantiateViewController(identifier: "importWalletID", storyboardName: "CreateAccount") as? ImportWalletViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        } catch {
            self.show(self.monsterAlertView(title: "Error", message: "An error has ocurred, please try again"), sender: self)
        }
    }
    
    @IBAction func goToCreate(_ sender: Any) {
        do {
            let vc = try self.instantiateViewController(identifier: "newWalletID", storyboardName: "CreateAccount") as? NewWalletViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        } catch {
            self.show(self.monsterAlertView(title: "Error", message: "An error has ocurred, please try again"), sender: self)
        }
    }
}

