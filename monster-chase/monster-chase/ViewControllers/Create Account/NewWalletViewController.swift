//
//  NewWalletViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import PocketSwift
import CoreData
import PocketSwift

class NewWalletViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    public var walletPrivateKey: String?
    var createdPlayer: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    func startDataDownload(player: Player) {
        var godfatherAddress: String? = nil
        guard let playerAddress = player.address else {
            return
        }
        if let godfatherWallet = player.getGodfatherWallet() {
            godfatherAddress = godfatherWallet.address
        }
        let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: playerAddress, monsterTokenAddress: AppConfiguration.monsterTokenAddress, godfatherAddress: godfatherAddress)
        appInitQueueDispatcher.initDispatchSequence {
            let chaseListQueueDispatcher = AllChasesQueueDispatcher.init(monsterTokenAddress: AppConfiguration.monsterTokenAddress, playerAddress: playerAddress)
            chaseListQueueDispatcher.initDispatchSequence(completionHandler: {
                
                UIApplication.getPresentedViewController(handler: { (topVC) in
                    if topVC == nil {
                        print("Failed to get current view controller")
                    }else {
                        do {
                            try topVC!.refreshView()
                        }catch let error as NSError {
                            print("Failed to refresh current view controller with error: \(error)")
                        }
                    }
                })
            })
        }
    }
    
    func biometricsSetupSuccessHandler() {
        let alertView = self.monsterAlertView(title: "Success", message: "You have succesfully setup FaceID/TouchID for your account.") { (alertAction) in
            self.navigateToChasing()
        }
        self.present(alertView, animated: true, completion: nil)
    }

    func biometricsSetupErrorHandler(error: Error) {
        let alertView = self.monsterAlertView(title: "Alert", message: "You can setup FaceID/TouchID later from your profile.") { (alertAction) in
            self.navigateToChasing()
        }
        self.present(alertView, animated: true, completion: nil)
    }
    
    func navigateToChasing() {
        do {
            let vc = try self.instantiateViewController(identifier: "containerViewControllerID", storyboardName: "Chasing") as? ContainerViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        } catch {
            self.present(self.monsterAlertView(title: "Error", message: "An error ocurred, please try again later."), animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    @IBAction func dismissViewController(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createPlayer(_ sender: Any) {
        if let _ = self.createdPlayer {
            navigateToChasing()
            return
        }
        
        guard let password = passwordTextField.text else {
            let alertView = monsterAlertView(title: "Error", message: "Failed to get password, please try again later")
            present(alertView, animated: false, completion: nil)
            return
        }
        
        if password.isEmpty {
            let alertView = monsterAlertView(title: "Invalid", message: "Password shouldn't be empty")
            present(alertView, animated: false, completion: nil)
            return
        }
        
        // Create the player
        do {
            let currentPlayer: Player?
            
            // Create or import the player
            if let importedPrivateKey = self.walletPrivateKey {
                currentPlayer = try Player.createPlayer(walletPassphrase: password, privateKey: importedPrivateKey)
            } else {
                currentPlayer = try Player.createPlayer(walletPassphrase: password)
            }
            
            guard let player = currentPlayer else {
                self.present(self.monsterAlertView(title: "Error", message: "Error creating your account, please try again"), animated: true, completion: nil)
                return
            }
            
            self.createdPlayer = player
            startDataDownload(player: player)
            BiometricsUtils.setupPlayerBiometricRecord(passphrase: password, successHandler: biometricsSetupSuccessHandler, errorHandler: biometricsSetupErrorHandler)
        } catch {
            print("Failed to create wallet with error: \(error)")
            self.present(self.monsterAlertView(title: "Error", message: "Error creating your account, please try again"), animated: true, completion: nil)
        }
    }
}
