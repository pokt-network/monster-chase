//
//  LeaderboardViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit
import BigInt

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var qrCodeBackgroundImage: UIImageView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    // Monster and position labels
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var positionValueLabel: UILabel!
    @IBOutlet weak var positionCircle: UIImageView!
    @IBOutlet weak var monsterCountLabel: UILabel!
    @IBOutlet weak var monsterCountValueLabel: UILabel!
    @IBOutlet weak var monsterCircle: UIImageView!
    
    var ownersRecords = [LeaderboardRecord]()
    var currentPlayer: Player?
    
    // Activity Indicator
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var grayView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the current player
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
        
        // Load the data
        loadAndSetLeaderboardData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Indicator
        // Gray view setup
        grayView = UIView.init(frame: view.frame)
        grayView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.75)
        grayView?.isHidden = true
        view.addSubview(grayView!)
        
        // Activity indicator setup
        indicator.center = view.center
        
        view.addSubview(indicator)
        toggleIndicator()
        
        // Styling
        // QR Code
        qrCodeBackgroundImage.layer.cornerRadius = qrCodeBackgroundImage.frame.height / 2
        qrCodeBackgroundImage.layer.borderWidth = 4
        qrCodeBackgroundImage.layer.borderColor = AppColors.base.cgColor()
        
        qrCodeImage.image = ProfileViewController.generateQRCode(from: currentPlayer?.address ?? "")
        
        self.tableView.separatorStyle = .none
        
        refreshTableView()
    }
    
    // MARK: UI
    func toggleIndicator() {
        if self.indicator.isAnimating {
            self.indicator.stopAnimating()
            self.grayView?.isHidden = true
        } else {
            self.indicator.startAnimating()
            self.grayView?.isHidden = false
        }
    }
    
    func refreshTableView() {
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate
    // MARK: Data
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
        //activityIndicator.startAnimating()
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
                self.refreshTableView()
                let ownerPosition = self.calculateOwnerPosition()
                guard let playerOwnerRecord = self.playerOwnerRecord() else {
                    self.placeholderLabel.isHidden = false
                    self.toggleIndicator()
                    return
                }
                if (playerOwnerRecord.tokenTotal == BigInt.init(0)) {
                    self.placeholderLabel.isHidden = false
                } else {
                    self.placeholderLabel.isHidden = true
                    self.setPositionAndMonsterCount(position: ownerPosition, monsterCount: playerOwnerRecord.tokenTotal)
                }
                self.toggleIndicator()
            }
        })
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
    
    func setPositionAndMonsterCount(position: Int64, monsterCount: BigInt) {
        self.toggleCountLabels()
        self.monsterCountValueLabel.text = String.init(monsterCount)
        self.positionValueLabel.text = String.init(position)
    }
    
    func toggleCountLabels() {
        [self.monsterCircle, self.monsterCountLabel, self.monsterCountValueLabel, self.positionLabel, self.positionCircle, self.positionValueLabel].forEach { (view) in
            guard let view = view else {
                return
            }
            
            view.isHidden = !view.isHidden
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
    
    //MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ownersRecords.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell") as! LeaderBoardTableViewCell
        let score = ownersRecords[indexPath.row]
        cell.record = score
        cell.index = indexPath.row
        cell.configureCell(viewController: self)
        return cell;
    }
    
    // MARK: - IBActions
    @IBAction func menuButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
}
