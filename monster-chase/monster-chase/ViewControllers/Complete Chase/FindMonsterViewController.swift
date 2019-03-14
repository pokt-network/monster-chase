//
//  FindMonsterViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/7/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import MapKit
import BigInt
import Pocket
import HDAugmentedReality

class FindMonsterViewController: ARViewController, ARDataSource, AnnotationViewDelegate {
    @IBOutlet weak var claimButton: UIButton!
    @IBOutlet weak var permissionsView: UIView!
    
    fileprivate var arViewController: ARViewController!
    var chaseLocation: CLLocation?
    var currentUserLocation: CLLocation?
    var currentChase: Chase?
    var currentPlayer: Player?
    var chaseProof: ChaseProofSubmission?
    
    // Activity Indicator
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var grayView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Current Player
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            self.present(self.monsterAlertView(title: "Error", message: "An error ocurred retrieving your account information, please try again"), animated: true)
            return
        }
        
        // AR Setup
        self.dataSource = self
        self.presenter.maxVisibleAnnotations = 1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gray view setup
//        grayView = UIView.init(frame: view.frame)
//        grayView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.75)
//        view.addSubview(grayView!)
        
        // Activity indicator setup
        indicator.center = view.center
        
        view.addSubview(indicator)
        indicator.startAnimating()
        
        self.view.isUserInteractionEnabled = false
        
        // Refresh player info
        refreshPlayerInfo()
        
    }
    
    override func refreshView() throws {
        // Check for camera permission
        checkCameraAccess()
    }
    
    func setupMonsterAR() {
        // Monster Location is generated based in the user location after is confirmed the user is withing the chase completion range.
        let coordinates = getMonsterLocation()
        chaseLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        let monsterLocation = CLLocation(latitude: chaseLocation?.coordinate.latitude ?? 0.0, longitude: chaseLocation?.coordinate.longitude ?? 0.0)
        let monsterLocationC = CLLocation(coordinate: monsterLocation.coordinate, altitude: CLLocationDistance.init(currentUserLocation?.altitude ?? 0), horizontalAccuracy: CLLocationAccuracy.init(0), verticalAccuracy: CLLocationAccuracy.init(0), timestamp: Date.init())
        
        let distance = monsterLocationC.distance(from: currentUserLocation!)
        
        if distance <= 50000 {
            let annotation = ARAnnotation.init(identifier: "monster", title: currentChase?.name ?? "NONE", location: monsterLocationC)
            
            // AR options
            // Max distance between the player and the Banano
            self.presenter.maxDistance = 50
            
            // We add the annotations that for Banano quest is 1 at a time
            self.setAnnotations([annotation!])
        }else {
            let alertController = monsterAlertView(title: "Not in range", message: "\(currentChase?.name ?? "") monster is not within 50 meters of your current location")
            present(alertController, animated: false, completion: nil)
        }
    }
    
    func checkCameraAccess() {
        let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if cameraIsAvailable {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .authorized:
                permissionsView.isHidden = true
                setupMonsterAR()
            case .denied:
                permissionsView.isHidden = false
                
                let alertView = UIAlertController(title: "Camera Access", message: "Monster Chase is requesting camera access, will you like to enable access to the camera?", preferredStyle: .alert)
                
                alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                    self.openAppSettings()
                }))
                
                alertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                present(alertView, animated: false, completion: nil)
                
            case .notDetermined:
                requestCameraAccess()
            default:
                requestCameraAccess()
            }
        } else {
            let alertView = monsterAlertView(title: "Error", message: "Device has not cameras available")
            
            present(alertView, animated: false, completion: nil)
        }
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
        
    }
    
    func requestCameraAccess() {
        let alertView = UIAlertController( title: "Camera Access", message: "Monster Chase would like to access your Camera to continue.", preferredStyle: .alert )
        
        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
            if let _ = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                    DispatchQueue.main.async {
                        self.checkCameraAccess()
                    }
                }
            }else{
                let noCameraAlertView = self.monsterAlertView(title: "Failed", message: "Back Camera not available, please try again later.")
                self.present(noCameraAlertView, animated: false, completion: nil)
                print("Back Camera not available")
            }
        })
        
        alertView.addAction(allowAction)
        let declineAction = UIAlertAction(title: "Not Now", style: .cancel) { (alert) in
            print("Permission denied")
        }
        alertView.addAction(declineAction)
        present(alertView, animated: true, completion: nil)
    }
    
    func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        
        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    
    func getMonsterLocation() -> CLLocationCoordinate2D {
        if currentUserLocation == nil {
            return CLLocationCoordinate2D.init()
        }
        return locationWithBearing(bearing: 0.0, distanceMeters: 30, origin: (currentUserLocation?.coordinate)!)
    }
    
    func didTouch(annotationView: AnnotationView) {
        print("Touched the monster")
    }
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        // View for the annotation setup
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        
        return annotationView
    }
    // MARK: Tools
    func refreshPlayerInfo() {
        var godfatherAddress: String? = nil
        if let godfatherWallet = currentPlayer?.getGodfatherWallet() {
            godfatherAddress = godfatherWallet.address
        }
        let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: currentPlayer?.address ?? "0", monsterTokenAddress: AppConfiguration.monsterTokenAddress, godfatherAddress: godfatherAddress)
        appInitQueueDispatcher.initDispatchSequence {
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.indicator.stopAnimating()
                self.grayView?.isHidden = true
                
                do {
                    try self.refreshView()
                } catch let error as NSError {
                    print("Failed to refresh view with error: \(error)")
                }
            }
            
            print("Player information updated")
        }
    }
    
    func claimFailedAlertView() {
        let alertView = monsterAlertView(title: "Error", message: "Something happened while submitting your information, please try again later.")
        
        present(alertView, animated: false, completion: nil)
    }
    
    func claimMonster(wallet: Wallet, nrg: BigInt) {
        
        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            
            guard let chaseIndex = BigInt.init(currentChase?.index ?? "0") else {
                claimFailedAlertView()
                return
            }
            
            guard let proof = chaseProof?.proof else {
                claimFailedAlertView()
                return
            }
            
            guard let answer = chaseProof?.answer else {
                claimFailedAlertView()
                return
            }
            guard let playerAddress = player.address else {
                claimFailedAlertView()
                return
            }
            
            guard let monsterName = currentChase?.name else {
                claimFailedAlertView()
                return
            }
            guard let leftOrRight = chaseProof?.order else {
                claimFailedAlertView()
                return
            }
            
            let operationQueue = OperationQueue()
            let nonceOperation = DownloadTransactionCountOperation.init(address: wallet.address)
            nonceOperation.completionBlock = {
                if let transactionCount = nonceOperation.transactionCount {
                    let claimOperation = UploadChaseProofOperation.init(wallet: wallet, transactionCount: transactionCount, playerAddress: playerAddress, chaseIndex: chaseIndex, proof: proof, answer: answer, leftOrRight: leftOrRight, nrg: nrg)
                    
                    claimOperation.completionBlock = {
                        if let txHash = claimOperation.txHash {
                            let transaction = Transaction.init(txHash: txHash, type: TransactionType.claim, context: CoreDataUtils.backgroundPersistentContext)
                            do {
                                try transaction.save()
                            } catch {
                                print("\(error)")
                            }
                        } else {
                            PushNotificationUtils.sendNotification(title: "Monster Claim", body: "An error occurred claiming your Monster: \(monsterName), please try again.", identifier: "MonsterClaimError")
                        }
                    }
                    
                    operationQueue.addOperations([claimOperation], waitUntilFinished: false)
                } else {
                    self.showNotificationOverlayWith(text: "There was an error claiming your MONSTER: \(monsterName)")
                }
            }
            
            // Operation Queue
            operationQueue.addOperations([nonceOperation], waitUntilFinished: false)
            let alertView = self.monsterAlertView(title: "Submitted", message: "Proof submitted, your request is being processed in the background") { (UIAlertAction) in
                
                self.backButtonPressed(self)
            }
            
            self.present(alertView, animated: false, completion: nil)
            
        } catch let error as NSError {
            print("Failed with error: \(error)")
        }
    }
    @IBAction func grantCameraAccess(_ sender: Any) {
        requestCameraAccess()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func claimButtonPressed(_ sender: Any) {
        self.retrieveGasEstimate { (gasEstimateWei) in
            if let gasEstimate = gasEstimateWei {
                let message = "Are you sure you want to claim this Monster?"
                let txDetailsAlertView = self.monsterAlertView(title: "Confirmation", message: message) { (uiAlertAction) in
                    guard let player = self.currentPlayer else {
                        self.present(self.monsterAlertView(title: "Error", message: "Player account not found, please try again."), animated: true, completion: nil)
                        return
                    }
                    
                    self.resolvePlayerWalletAuth(player: player, successHandler: { (wallet) in
                        var currentWallet: Wallet?
                        guard let playerAddress = player.address else {
                            self.noBalanceHandler(message: "An error has ocurred, please try again")
                            return
                        }
                        
                        PlayerBalanceQueueDispatcher.init(playerAddress: playerAddress, godfatherAddress: player.godfatherAddress, completionHandler: { (playerBalance, godfatherBalance) in
                            if godfatherBalance > gasEstimate {
                                currentWallet = player.getGodfatherWallet()
                            } else if playerBalance > gasEstimate && currentWallet == nil {
                                currentWallet = wallet
                            } else {
                                self.noBalanceHandler(message: "An error has ocurred, please try again later")
                                return
                            }
                            
                            guard let currentWallet = currentWallet else {
                                self.noBalanceHandler(message: "An error has ocurred, please try again later")
                                return
                            }
                            
                            self.claimMonster(wallet: currentWallet, nrg: gasEstimate)
                        })
                    }, errorHandler: { (error) in
                        self.present(self.monsterAlertView(title: "Error", message: "An error ocurred accessing your account, please try again"), animated: true, completion: nil)
                    })
                }
                txDetailsAlertView.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(txDetailsAlertView, animated: false, completion: nil)
            } else {
                let alertController = self.monsterAlertView(title: "Error", message: "An error has ocurred, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
        }
    }
    
    func noBalanceHandler(message: String) {
        let alertView = monsterAlertView(title: "Failed", message: message)
        present(alertView, animated: false, completion: nil)
    }
    
    func retrieveGasEstimate(handler: @escaping (BigInt?) -> Void) {
        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            guard let questIndexStr = currentChase?.index else {
                let alertController = self.monsterAlertView(title: "Error", message: "Failed to retrieve your account data, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
            guard let proof = chaseProof?.proof else {
                let alertController = self.monsterAlertView(title: "Error", message: "Failed to proof your location, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
            guard let answer = chaseProof?.answer else {
                let alertController = self.monsterAlertView(title: "Error", message: "Failed to proof your location, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
            
            guard let leftOrRight = chaseProof?.order else {
                let alertController = self.monsterAlertView(title: "Error", message: "Failed to proof your location, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
            let operationQueue = OperationQueue.init()
            let gasEstimateOperation = UploadChaseProofEstimateOperation.init(playerAddress: player.address!, tokenAddress: AppConfiguration.monsterTokenAddress, chaseIndex: BigInt.init(questIndexStr)!, proof: proof, answer: answer, leftOrRight: leftOrRight)
            gasEstimateOperation.completionBlock = {
                handler(gasEstimateOperation.estimatedGas)
            }
            operationQueue.addOperations([gasEstimateOperation], waitUntilFinished: false)
        } catch {
            let alertController = self.monsterAlertView(title: "Error", message: "Failed to retrieve your account data, please try again")
            self.present(alertController, animated: false, completion: nil)
            return
        }
    }
}
