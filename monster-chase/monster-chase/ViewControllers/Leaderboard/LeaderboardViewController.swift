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
import Pocket

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var qrCodeBackgroundImage: UIImageView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monsterCountLabel: UILabel!
    @IBOutlet weak var positionValueLabel: UILabel!
    
    var ownersRecords = [LeaderboardRecord]()
    var ownerPosition: Int?
    var currentPlayer: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // loadAndSetLeaderboardData()
        // TODO: ADD POSITION LABEL
//        positionLabel.text = ""
        
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
        
        // Test data
        let testData = LeaderboardRecord.init(wallet: currentPlayer?.address, tokenTotal: BigInt.init("1234", radix: 16))
        let testData2 = LeaderboardRecord.init(wallet: "0x0000000101010101010", tokenTotal: BigInt.init("12", radix: 16))
        
        self.ownersRecords.append(testData)
        self.ownersRecords.append(testData2)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Styling
        // QR Code
        qrCodeBackgroundImage.layer.cornerRadius = qrCodeBackgroundImage.frame.height / 2
        qrCodeBackgroundImage.layer.borderWidth = 4
        qrCodeBackgroundImage.layer.borderColor = AppColors.base.cgColor()
        
        qrCodeImage.image = ProfileViewController.generateQRCode(from: currentPlayer?.address ?? "")
        
        refreshTableView()
    }
    
    // MARK: UI
    func refreshTableView() {
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
    
    func setPositionLabelText() {
        if (ownerPosition == nil) {
            //positionLabel.text = "Collect monsters to get ranked!"
        } else {
            //positionLabel.text = "You are in position #\(ownerPosition!)!"
        }
    }
    
    // MARK: UITableViewDelegate
    // MARK: Data
    func calculateOwnerPosition() {
        for i in 0..<ownersRecords.count {
            let record = ownersRecords[i]
            let playerAddress = currentPlayer?.address
            if record.wallet == playerAddress {
                ownerPosition = i + 1
                break
            }
        }
    }
    
    func loadAndSetLeaderboardData() {
        //activityIndicator.startAnimating()
        fetchOwnerCount(completionBlock: { count in
            if count == nil {
                return
            }
            self.ownersRecords = [LeaderboardRecord]()
            let dispatchGroup = DispatchGroup()
            for i in 0..<Int(count!){
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
                    return l1.tokenTotal! > l2.tokenTotal!
                })
                self.refreshTableView()
                self.calculateOwnerPosition()
                self.setPositionLabelText()
                //self.activityIndicator.stopAnimating()
            }
        })
    }
    
    func fetchOwnerCount(completionBlock:@escaping (BigInt?) -> Void) {
        let downloadOwnersCountOperation = DownloadOwnersCountOperation.init(monsterTokenAddress: AppConfiguration.monsterTokenAddress)
        downloadOwnersCountOperation.completionBlock = {
            guard let ownerTotal = downloadOwnersCountOperation.total else {
                print("Error fetching OwnersCount in Leaderboard")
                completionBlock(nil)
                return
                ///TODO: dismiss??
            }
            completionBlock(ownerTotal)
            print("Total owners in leadeboard:\(ownerTotal)")
        }
        downloadOwnersCountOperation.start()
    }
    
    func fetchOwnerLeaderboardRecordCount(index:Int,completionBlock:@escaping (Int,LeaderboardRecord?) -> Void) {
        let downloadOwnerTokenOperation = DownloadOwnersTokenCountOperation(monsterTokenAddress: AppConfiguration.monsterTokenAddress, ownerIndex: index)
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
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell") as! LeaderBoardTableViewCell
        let score = ownersRecords[indexPath.row]
        
        cell.record = score
        cell.index = indexPath.row
        
        cell.configureCell()
        
        return cell;
    }
    
    // MARK: - IBActions
    @IBAction func menuButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
}
