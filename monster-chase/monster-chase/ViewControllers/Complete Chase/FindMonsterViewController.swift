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

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentAccentColor: UIColor {
        return UIColor(red: 14/255, green: 169/255, blue: 168/255, alpha: 0.0)
    }
}

class FindMonsterViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var claimButton: UIButton!
    @IBOutlet weak var permissionsView: UIView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    //fileprivate var arViewController: ARViewController!
    var chaseLocation: CLLocation?
    var currentUserLocation: CLLocation?
    var currentChase: Chase?
    var currentPlayer: Player?
    var chaseProof: ChaseProofSubmission?
    var completeVC: CompleteChaseViewController?
    
    // Activity Indicator
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var grayView: UIView?
    
    var monsterRendered: Bool = false
    var monsterNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLighting()
        // Current Player
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            self.present(self.monsterAlertView(title: "Error", message: "An error ocurred retrieving your account information, please try again"), animated: true)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
        
        // Activity indicator setup
        indicator.center = view.center
        
        view.addSubview(indicator)
        indicator.startAnimating()
        
        self.view.isUserInteractionEnabled = false
        
        // Refresh player info
        refreshPlayerInfo()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func refreshView() throws {
        // Check for camera permission
        checkCameraAccess()
    }
    
    // MARK: AR
    func renderTextureWithColor(topImage: UIImage, hex: String) -> UIImage {
        let bottomImage = UIImage.drawImage(ofSize: topImage.size, path: UIBezierPath.init(rect: CGRect.init(x: 0.0, y: 0.0, width: topImage.size.height, height: topImage.size.width)), fillColor: UIColor.init(hexString: hex) ?? UIColor.black)!
        
        let newSize = CGSize.init(width: topImage.size.width, height: topImage.size.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        bottomImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize), blendMode: CGBlendMode.normal, alpha: 1.0)
        topImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize), blendMode: CGBlendMode.normal, alpha: 1.0)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.transparentAccentColor
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
        if let currentMonsterNode = self.createMonsterNode(x: planeAnchor.center.x, y: planeAnchor.center.y, z: planeAnchor.center.z) {
            self.monsterNode = currentMonsterNode
            node.addChildNode(self.monsterNode!)
            self.monsterRendered = true
            DispatchQueue.main.async {
                self.claimButton.isHidden = false
            }
        }
    }
    
    func createMonsterNode(x: Float, y: Float, z: Float) -> SCNNode? {
        if monsterRendered == true {
            return nil
        }
        
        guard let monsterScene = SCNScene(named: "monster.scn"),
            let monsterNode = monsterScene.rootNode.childNode(withName: "Monster_body", recursively: false)
            else { return nil }
        
        let material = SCNMaterial()
        let materialImage = self.renderTextureWithColor(topImage: UIImage.init(named: "monster-texture.png")!, hex: self.currentChase?.hexColor ?? "#4D4B9F")
        material.diffuse.contents = materialImage
        
        monsterNode.scale = SCNVector3(0.01, 0.01, 0.01)
        monsterNode.position = SCNVector3(x,y,z)
        if let currentFrame = sceneView.session.currentFrame {
            monsterNode.eulerAngles.y = currentFrame.camera.eulerAngles.y
        } else {
            monsterNode.eulerAngles.y = -.pi / 3
        }
        monsterNode.geometry?.materials = [material]
        return monsterNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    func checkCameraAccess() {
        let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if cameraIsAvailable {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .authorized:
                permissionsView.isHidden = true
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
                if let completeViewController = self.completeVC {
                    completeViewController.dismissViewController = true
                }
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
