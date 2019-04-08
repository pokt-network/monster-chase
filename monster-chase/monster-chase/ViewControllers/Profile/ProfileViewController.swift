//
//  ProfileViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit
import BigInt

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var qrCodeCircle: UIView!
    @IBOutlet weak var walletAddressTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var monstersCountLabel: UILabel!
    @IBOutlet weak var leaderboardPositionLabel: UILabel!
    
    
    var currentPlayer: Player?
    var monsters: [Monster] = [Monster]()
    var ownersRecords = [LeaderboardRecord]()
    
    // Activity Indicator
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var grayView: UIView?
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
        
        // Gray view setup
        grayView = UIView.init(frame: view.frame)
        grayView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.75)
        grayView?.isHidden = true
        view.addSubview(grayView!)
        
        // Activity indicator setup
        indicator.center = view.center
        view.addSubview(indicator)
        
        loadPlayerMonsters()
        loadAndSetLeaderboardData()
    }
    
    func playerOwnerRecord() -> LeaderboardRecord? {
        var playerRecord: LeaderboardRecord?
        if self.ownersRecords.isEmpty {
            return nil
        }
        
        guard let playerAddress = self.currentPlayer?.address else {
            return nil
        }
        
        for ownerRecord in self.ownersRecords {
            if ownerRecord.address.caseInsensitiveCompare(playerAddress) == .orderedSame {
                playerRecord = ownerRecord
                break
            }
        }
        return playerRecord
    }
    
    func toggleIndicator() {
        if self.indicator.isAnimating {
            self.indicator.stopAnimating()
            self.grayView?.isHidden = true
        } else {
            self.indicator.startAnimating()
            self.grayView?.isHidden = false
        }
    }
    
    func fetchOwnerCount(completionBlock:@escaping (BigInt?) -> Void) {
        let downloadOwnersCountOperation = DownloadOwnersCountOperation.init(monsterTokenAddress: AppConfiguration.monsterTokenAddress)
        downloadOwnersCountOperation.completionBlock = {
            guard let ownerTotal = downloadOwnersCountOperation.total else {
                print("Error fetching OwnersCount in Leaderboard")
                completionBlock(nil)
                return
            }
            completionBlock(ownerTotal)
            print("Total owners in leadeboard:\(ownerTotal)")
        }
        downloadOwnersCountOperation.start()
    }
    
    func fetchOwnerLeaderboardRecordCount(index: BigInt,completionBlock:@escaping (BigInt, LeaderboardRecord?) -> Void) {
        let downloadOwnerTokenOperation = DownloadOwnersTokenCountOperation(monsterTokenAddress: AppConfiguration.monsterTokenAddress, ownerIndex: BigInt.init(index))
        downloadOwnerTokenOperation.completionBlock = {
            guard let score = downloadOwnerTokenOperation.leaderboardRecord else {
                completionBlock(index,nil)
                return
            }
            completionBlock(index,score)
        }
        downloadOwnerTokenOperation.start()
    }
    
    func calculateOwnerPosition() -> Int64 {
        var result: Int64 = 0
        
        guard let playerAddress = currentPlayer?.address else {
            return result
        }
        
        for i in 0..<self.ownersRecords.count {
            let record = self.ownersRecords[i]
            if record.address.caseInsensitiveCompare(playerAddress) == .orderedSame {
                result = Int64.init(i) + 1
                break
            }
        }
        
        return result
    }
    
    func loadAndSetLeaderboardData() {
        toggleIndicator()
        fetchOwnerCount(completionBlock: { count in
            guard let count = count else {
                self.toggleIndicator()
                let errorAlert = self.monsterAlertView(title: "Error", message: "Error fetching Leaderboard records")
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            self.ownersRecords = [LeaderboardRecord]()
            let dispatchGroup = DispatchGroup()
            for i in BigInt.init(0)..<BigInt.init(count){
                dispatchGroup.enter()
                self.fetchOwnerLeaderboardRecordCount(index: i, completionBlock: { (index, leaderboardRecord) in
                    if leaderboardRecord != nil {
                        self.ownersRecords.append(leaderboardRecord!)
                    }
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue:.main) {
                self.ownersRecords.sort(by: { (l1, l2) -> Bool in
                    return l1.tokenTotal > l2.tokenTotal
                })
                //self.refreshTableView()
                let ownerPosition = self.calculateOwnerPosition()
                guard let playerOwnerRecord = self.playerOwnerRecord() else {
                    self.toggleIndicator()
                    return
                }
                if (playerOwnerRecord.tokenTotal != BigInt.init(0)) {
                    self.setPositionAndMonsterCount(position: ownerPosition, monsterCount: playerOwnerRecord.tokenTotal)
                }
                self.toggleIndicator()
            }
        })
    }
    
    func setPositionAndMonsterCount(position: Int64, monsterCount: BigInt) {
        self.monstersCountLabel.text = String.init(monsterCount)
        self.leaderboardPositionLabel.text = String.init(position)
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
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - IBActions
    @IBAction func biometricSetupButtonPressed(_ sender: Any) {
        guard let player = currentPlayer else {
            let alertView = self.monsterAlertView(title: "Error", message: "Could not retrieve your account.")
            self.present(alertView, animated: false, completion: nil)
            return
        }
        
        guard let playerAddress = player.address else {
            let alertView = self.monsterAlertView(title: "Error", message: "Could not retrieve your account.")
            self.present(alertView, animated: false, completion: nil)
            return
        }
        
        if BiometricsUtils.biometricRecordExists(playerAddress: playerAddress) {
            let alertView = self.monsterAlertView(title: "Error", message: "You've already setup FaceID/TouchID.")
            self.present(alertView, animated: false, completion: nil)
            return
        }
        
        let requestAlertView = self.requestPassphraseAlertView { (password, error) in
            if let _ = error {
                let alertView = self.monsterAlertView(title: "Error", message: "Could not retrieve your account, please try again.")
                self.present(alertView, animated: false, completion: nil)
                return
            }
            
            guard let password = password else {
                let alertView = self.monsterAlertView(title: "Error", message: "Could not retrieve your account, please try again.")
                self.present(alertView, animated: false, completion: nil)
                return
            }
            
            BiometricsUtils.setupPlayerBiometricRecord(passphrase: password, successHandler: {
                let alertView = self.monsterAlertView(title: "Success", message: "FaceID/TouchID successfully setup.")
                self.present(alertView, animated: false, completion: nil)
            }, errorHandler: { (error) in
                let alertView = self.monsterAlertView(title: "Error", message: "An error ocurred, please try again later.")
                self.present(alertView, animated: false, completion: nil)
            })
        }
        self.present(requestAlertView, animated: true, completion: nil)
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
            let alertView = monsterAlertView(title: "Success:", message: "Your address has been copied to the clipboard.")
            UIPasteboard.general.string = walletAddressTextField.text
            present(alertView, animated: false, completion: nil)
        }
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        // Resolve wallet auth
        guard let player = currentPlayer else {
            self.present(self.monsterAlertView(title: "Error", message: "Error retrieving your account details, please try again"), animated: true)
            return
        }
        
        self.resolvePlayerWalletAuth(player: player, successHandler: { (wallet) in
            let privateKey = wallet.privateKey
            
            let alertView = self.monsterAlertView(title: "Warning", message: "Your private key has been copied to the clipboard, do not share it with anyone! When you press OK you will be logged out.", handler: { (UIAlertAction) in
                UIPasteboard.general.string = privateKey
                do {
                    let _ = try Player.wipePlayerData(context: CoreDataUtils.mainPersistentContext, player: player, wallet: wallet)
                } catch {
                    print("\(error)")
                }
                do {
                    let vc = try self.instantiateViewController(identifier: "authSelectionID", storyboardName: "CreateAccount") as? AuthSelectionViewController
                    self.navigationController?.pushViewController(vc!, animated: false)
                } catch let error as NSError {
                    print("Failed to instantiate AuthSelectionViewController with error: \(error)")
                }
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
        return CGSize(width: collectionView.bounds.width/3.0, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.monsters.count == 0 {
            return 1
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
    
    func loadPlayerMonsters() {
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
