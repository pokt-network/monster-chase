//
//  ProfileViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit
import Pocket
import BigInt

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var qrCodeCircle: UIView!
    @IBOutlet weak var walletAddressTextField: UITextField!
    @IBOutlet weak var balanceValueLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var monstersCountLabel: UILabel!
    @IBOutlet weak var leaderboardPositionLabel: UILabel!
    
    var currentPlayer: Player?
    var monsters: [Monster] = [Monster]()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
        loadPlayerBananos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Styling
        qrCodeCircle.layer.cornerRadius = qrCodeCircle.frame.height / 2
        qrCodeCircle.layer.borderWidth = 4
        qrCodeCircle.layer.borderColor = AppColors.base.cgColor()
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func refreshView() throws {
        if currentPlayer == nil  {
            let alertView = monsterAlertView(title: "Error:", message: "Failed to retrieve current player, please try again later")
            present(alertView, animated: false, completion: nil)
            
            return
        }
        
        // Labels setup
        walletAddressTextField.text = currentPlayer?.address
        qrCodeImage.image = ProfileViewController.generateQRCode(from: currentPlayer?.address ?? "")
        if let weiBalanceStr = currentPlayer?.balanceWei {
            let weiBalance = BigInt.init(weiBalanceStr) ?? BigInt.init(0)
            let aion = String(format: "%.2f", arguments: [AionUtils.convertWeiToAion(wei: weiBalance)])
            let usd = String(format: "%.2f", arguments: [AionUtils.convertWeiToUSD(wei: weiBalance)])
            
            balanceValueLabel.text = "\(aion) AION - \(usd) USD"
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func addBalanceButtonPressed(_ sender: Any) {
        do {
            guard let vc = try instantiateViewController(identifier: "addBalanceViewControllerID", storyboardName: "Profile") as? AddBalanceViewController else {
                return
            }
            
            if currentPlayer != nil {
                vc.player = currentPlayer
            }
            if qrCodeImage.image != nil {
                vc.qrImage = qrCodeImage.image
            }
            
            self.present(vc, animated: false, completion: nil)
            
        } catch let error as NSError {
            print("Failed to instantiate Add Balance VC with error :\(error)")
        }
        
    }
    
    @IBAction func copyAddressButtonPressed(_ sender: Any) {
        let showError = {
            let alertView = self.monsterAlertView(title: "Error:", message: "Address field is empty, please try again later")
            self.present(alertView, animated: false, completion: nil)
        }
        guard let isAddressEmpty = walletAddressTextField.text?.isEmpty else {
            showError()
            return
        }
        if isAddressEmpty {
            showError()
            return
        } else {
            let alertView = monsterAlertView(title: "Success:", message: "Your Address has been copied to the clipboard.")
            UIPasteboard.general.string = walletAddressTextField.text
            present(alertView, animated: false, completion: nil)
        }
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func exportPressed(_ sender: Any) {
        // Resolve wallet auth
        guard let player = currentPlayer else {
            self.present(self.monsterAlertView(title: "Error", message: "Error retrieving your account details, please try again"), animated: true)
            return
        }
        
        self.resolvePlayerWalletAuth(player: player, successHandler: { (wallet) in
            let privateKey = wallet.privateKey
            
            let alertView = self.monsterAlertView(title: "WARNING", message: "Your private key has been copied to the clipboard, do not share it with anyone!: \(privateKey)", handler: { (UIAlertAction) in
                UIPasteboard.general.string = privateKey
            })
            
            self.present(alertView, animated: false, completion: nil)
        }) { (error) in
            print("\(error)")
            self.present(self.monsterAlertView(title: "Error", message: "Error retrieving your account details, please try again"), animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var yourWidth : CGFloat?
        var yourHeight : CGFloat?
        
        let device = UIDevice.modelName
        
        if device == "iPhone SE" || device == "Simulator iPhone SE" {
            yourWidth = collectionView.bounds.width/2.0
            yourHeight = yourWidth
        }else {
            yourWidth = collectionView.bounds.width/3.0
            yourHeight = yourWidth
        }
        return CGSize(width: yourWidth ?? 375, height: yourHeight ?? 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.monsters.count == 0 {
            return 3
        } else {
            return self.monsters.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if monsters.count != 0  && indexPath.item < monsters.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monsterCellIdentifier", for: indexPath) as! MonsterCollectionViewCell
            
            let monster = monsters[indexPath.item]
            cell.monster = monster
            cell.configureCellFor(index: indexPath.item, playerLocation: nil)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monsterCellIdentifier", for: indexPath) as! MonsterCollectionViewCell
            
            cell.configureEmptyCellFor(index: indexPath.item)
            
            return cell
        }
    }
    
    // MARK: Tools
    public static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func loadPlayerBananos() {
        // Initial load for the local monsters list
        do {
            self.monsters = try Monster.sortedMonstersByIndex(context: CoreDataUtils.mainPersistentContext)
            if self.monsters.count != 0 {
                try self.refreshView()
            }
        } catch {
            let alert = self.monsterAlertView(title: "Error", message: "Failed to retrieve current monsters with error:")
            self.present(alert, animated: false, completion: nil)
            print("Failed to retrieve monsters list with error: \(error)")
        }
    }
    
}
