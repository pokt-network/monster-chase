//
//  CreateChaseViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit
import FlexColorPicker
import Pocket
import MapKit
import BigInt

class CreateChaseViewController: UIViewController, ColorPickerDelegate, UITextViewDelegate {
    // UI Elements
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var monsterImageBackground: UIImageView!
    @IBOutlet weak var addColorButton: UIButton!
    @IBOutlet weak var monsterNameTextField: UITextField!
    @IBOutlet weak var monsterColorImage: UIImageView!
    @IBOutlet weak var howManyMonstersTextField: UITextField!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var infiniteMonstersSwitch: UISwitch!
    @IBOutlet weak var hintTextCountLabel: UILabel!
    @IBOutlet weak var balanceValueLabel: UILabel!

    
    // Variables
    var newChase: Chase?
    var currentPlayer: Player?
    var currentWallet: Wallet?
    var selectedLocation = [AnyHashable: Any]()
    var selectedColorHex: String?
    
    // Constants
    let maxHintSize = 140
    let maxNameSize = 40
    
    // Notifications
    static let notificationName = Notification.Name("getLocation")
    
    // Activity Indicator
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var grayView: UIView?
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            newChase = try Chase.init(obj: [:], context: CoreDataUtils.createBackgroundPersistentContext())
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            print("\(error)")
        }
        
        // Notification Center
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CreateChaseViewController.notificationName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Gray view setup
        grayView = UIView.init(frame: view.frame)
        grayView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.75)
        view.addSubview(grayView!)
        
        // Activity indicator setup
        indicator.center = view.center
        
        view.addSubview(indicator)
        indicator.startAnimating()
        
        self.view.isUserInteractionEnabled = false
        
        // Monster name Text field
        monsterNameTextField.borderStyle = .roundedRect
        monsterNameTextField.layer.borderColor = UIColor.init(hex: 0x4D4B9F, alpha: 1.0)?.cgColor
        monsterNameTextField.layer.cornerRadius = 10
        monsterNameTextField.layer.borderWidth = 1.0
        
        //
        hintTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 12)
        // Refresh player info
        refreshPlayerInfo()
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.newChase = nil
        super.viewWillDisappear(animated)
    }
    
    override func refreshView() throws {
        // UI Settings
        defaultUIElementsStyle()
        
        // Set current player balance
        //refreshPlayerBalance()
        
        // Initialize unloaded chase if necessary
        if self.newChase == nil {
            do {
                newChase = try Chase.init(obj: [:], context: CoreDataUtils.mainPersistentContext)
            } catch {
                print("\(error)")
            }
        }
    }
    
    // MARK: - Tools
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
            }
            
            print("Player information updated")
        }
    }
    
    func retrieveGasEstimate(handler: @escaping (BigInt?) -> Void) {
        let operationQueue = OperationQueue.init()
        let gasEstimateOperation = UploadChaseEstimateOperation.init(playerAddress: (currentPlayer?.address)!, chaseName: (newChase?.name)!, hint: (newChase?.hint)!, maxWinners: BigInt.init((newChase?.maxWinners)!)!, merkleRoot: (newChase?.merkleRoot)!, merkleBody: (newChase?.merkleBody)!, metadata: setupMetadata()!)
        
        gasEstimateOperation.completionBlock = {
            handler(gasEstimateOperation.estimatedGas)
        }
        operationQueue.addOperations([gasEstimateOperation], waitUntilFinished: false)
    }
    
    @objc func onNotification(notification:Notification)
    {
        if notification.userInfo != nil {
            selectedLocation = notification.userInfo!
            
        }
    }
    
    func defaultUIElementsStyle() {
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutside)
        
        monsterImageBackground.layer.cornerRadius = monsterImageBackground.frame.size.width / 2
        
        infiniteMonstersSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        monsterColorImage.layer.cornerRadius = monsterColorImage.frame.width / 2
        
        addColorButton.layer.cornerRadius = addColorButton.frame.size.width / 2
        addColorButton.layer.borderWidth = 1
        addColorButton.layer.borderColor = UIColor.clear.cgColor
        addColorButton.clipsToBounds = true
        
        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = UIColor.clear.cgColor
        
        monsterNameTextField.layer.borderWidth = 1
        monsterNameTextField.layer.borderColor = UIColor.init(hex: 0x4D4B9F, alpha: 1.0)?.cgColor
        
        howManyMonstersTextField.layer.borderWidth = 1
        howManyMonstersTextField.layer.borderColor = UIColor.clear.cgColor
        
        hintTextView.delegate = self
        if (hintTextView.text.isEmpty) {
            hintTextView.text = "Insert a clue about where the MONSTER will be hidden"
            hintTextView.textColor = UIColor.lightGray
            hintTextView.selectedTextRange = hintTextView.textRange(from: hintTextView.beginningOfDocument, to: hintTextView.beginningOfDocument)
        }
        
        hintTextView.layer.borderWidth = 2.0
        hintTextView.layer.cornerRadius = 20
        hintTextView.layer.borderColor = AppColors.accent.cgColor()
        
        if selectedColorHex != nil {
            monsterColorImage.backgroundColor = UIColor(hexString: selectedColorHex!)
            
            if newChase != nil {
                newChase?.hexColor = selectedColorHex!
            } else {
                // If newQuest is nil, create a new one and assign the new hexColor
                do {
                    newChase = try Chase.init(obj: [:], context: CoreDataUtils.mainPersistentContext)
                    newChase?.hexColor = selectedColorHex!
                } catch let error as NSError {
                    print("Failed to create chase with error: \(error)")
                }
            }
            self.monsterImageBackground.backgroundColor = UIColor(hexString: selectedColorHex!)
        }
    }
    
    func enableElements(bool: Bool) {
        addLocationButton.isEnabled = bool
        addColorButton.isEnabled = bool
        monsterNameTextField.isEnabled = bool
        infiniteMonstersSwitch.isEnabled = bool
        hintTextView.isEditable = bool
    }
    
    func isNewChaseValid() -> Bool {
        var isValid = [Bool]()
        
        // Validate quest name
        if (monsterNameTextField.text ?? "").isEmpty || ((monsterNameTextField.text ?? "").count > self.maxNameSize) {
            monsterNameTextField.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        } else {
            monsterNameTextField.layer.borderColor = UIColor.init(hex: 0x4D4B9F, alpha: 1.0)?.cgColor
            newChase?.name = monsterNameTextField.text ?? ""
        }
        
        // Validate banano amount
        if infiniteMonstersSwitch.isOn {
            newChase?.maxWinners = String.init(BigInt.init(0))
        } else {
            if (howManyMonstersTextField.text ?? "0.0").isEmpty {
                howManyMonstersTextField.layer.borderColor = UIColor.red.cgColor
                isValid.append(false)
            }else {
                howManyMonstersTextField.layer.borderColor = UIColor.clear.cgColor
                newChase?.maxWinners = String.init(BigInt.init(howManyMonstersTextField.text ?? "0") ?? BigInt.init(0))
            }
        }
        
        // Validate quest hint
        if (hintTextView.text ?? "").isEmpty || hintTextView.text.count > maxHintSize || hintTextView.textColor == UIColor.lightGray {
            hintTextView.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        } else {
            hintTextView.layer.borderColor = UIColor(red: (253/255), green: (204/255), blue: (48/255), alpha: 1.0).cgColor
            newChase?.hint = hintTextView.text
        }
        
        // Validate hex color
        if newChase?.hexColor == nil {
            addColorButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            addColorButton.layer.borderColor = UIColor.clear.cgColor
        }
        
        // Setup merkleTree
        setupMerkleTree()
        
        // Validate merkle tree
        if newChase?.merkleRoot?.isEmpty ?? false || newChase?.merkleRoot == nil {
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else{
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }
        if newChase?.merkleBody?.isEmpty ?? false || newChase?.merkleBody == nil{
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        } else {
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }
        
        // Validate quest metadata
        if setupMetadata() == nil {
            isValid.append(false)
        }
        
        // Return valid response
        return !isValid.contains(false)
    }
    
    func presentQuestListView() {
        do {
            let vc = try self.instantiateViewController(identifier: "chasingViewControllerID", storyboardName: "Chasing") as! ChasingViewController
            self.so_containerViewController?.topViewController = vc
        }catch {
            let failedAlertView = self.monsterAlertView(title: "Error:", message: "Oops something didn't happen, please try again")
            self.present(failedAlertView, animated: false, completion: nil)
        }
    }
    
    func createNewChase(gasEstimateWei: BigInt) {
        // New Quest submission
        // Pepare fields
        guard let maxWinners = BigInt.init(newChase?.maxWinners ?? "0") else {
            return
        }
        guard let wallet = currentWallet else {
            return
        }
        guard let chaseName = newChase?.name else {
            return
        }
        guard let chaseHint = newChase?.hint else {
            return
        }
        guard let merkleRoot = newChase?.merkleRoot else {
            return
        }
        guard let merkleBody = newChase?.merkleBody else {
            return
        }
        guard let metadata = setupMetadata() else {
            return
        }
        guard let playerAddress = currentPlayer?.address else {
            return
        }
        
        // Upload quest operation
        let operation = UploadChaseOperation.init(wallet: wallet, playerAddress: playerAddress, chaseName: chaseName, hint: chaseHint, maxWinners: maxWinners, merkleRoot: merkleRoot, merkleBody: merkleBody, metadata:  metadata, nrg: gasEstimateWei)
        operation.completionBlock = {
            AppDelegate.shared.refreshCurrentViewController()
            if let txHash = operation.txHash {
                let transaction = Transaction.init(txHash: txHash, type: TransactionType.creation, context: CoreDataUtils.backgroundPersistentContext)
                
                self.refreshPlayerInfo()
                do {
                    try transaction.save()
                } catch {
                    print("\(error)")
                }
            } else {
                PushNotificationUtils.sendNotification(title: "Chase Creation", body: "An error occurred creating your Chase: \(chaseName), please try again.", identifier: "ChaseCreationError")
            }
        }
        // Operation Queue
        let operationQueue = OperationQueue.init()
        operationQueue.addOperations([operation], waitUntilFinished: false)
        
        DispatchQueue.main.async {
            // UI Elements disabled
            self.enableElements(bool: false)
        }
        
        // Let the user knows and present Quest list
        let alertView = UIAlertController(title: "Success", message: "Chase creation submitted successfully, we will let you know when it's done", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            self.presentQuestListView()
        }))
        
        present(alertView, animated: false, completion: nil)
    }
    
    func setupMetadata() -> String? {
        let hexColorStr: String?
        let hintQuadrant: [CLLocation]?
        var metadataStr: String?
        
        if newChase?.hexColor == nil {
            // Generate random hexColor
            newChase?.hexColor = UIColor.random().hexValue()
        }
        hexColorStr = newChase?.hexColor
        
        if selectedLocation.count < 2 {
            return nil
        }
        
        if !(selectedLocation["lat"] as! String).isEmpty && !(selectedLocation["lon"] as! String).isEmpty {
            let selectedLocation = CLLocation.init(latitude: Double(self.selectedLocation["lat"] as! String) ?? 0.0, longitude: Double(self.selectedLocation["lon"] as! String) ?? 0.0)
            let randomQuadrantCenter = LocationUtils.generateRandomCoordinates(currentLoc: selectedLocation, min: 21, max: 179)
            hintQuadrant = LocationUtils.generateHintQuadrant(center: randomQuadrantCenter, sideDistance: 0.2)
        }else {
            let alertView = monsterAlertView(title: "Error", message: "Failed to process the selected location, please try again later")
            self.present(alertView, animated: false, completion: nil)
            return nil
        }
        
        // Create metadata string
        if let hexColorStr = hexColorStr, let hintQuadrant = hintQuadrant {
            var metadataArr = [Any]()
            metadataArr.append(hexColorStr)
            metadataArr.append(contentsOf: hintQuadrant)
            
            metadataStr = metadataArr.reduce(into: String.init(""), { (result, currValue) in
                if let strValue = currValue as? String {
                    result.append(contentsOf: strValue + ",")
                } else if let locValue = currValue as? CLLocation {
                    let currLatStr = String.init(locValue.coordinate.latitude)
                    let currLonStr = String.init(locValue.coordinate.longitude)
                    result.append(contentsOf: currLatStr + ",")
                    result.append(contentsOf: currLonStr + ",")
                }
            })
            // Remove trailing comma
            metadataStr?.removeLast()
        }
        
        return metadataStr
    }
    
    func setupMerkleTree() {
        if selectedLocation.count < 2 {
            return
        }
        
        if !(selectedLocation["lat"] as! String).isEmpty && !(selectedLocation["lon"] as! String).isEmpty {
            let latitude = CLLocationDegrees.init(Double(selectedLocation["lat"] as! String) ?? 0.0)
            let longitude = CLLocationDegrees.init(Double(selectedLocation["lon"] as! String) ?? 0.0)
            
            let location = CLLocation.init(latitude: latitude, longitude: longitude)
            let chaseMerkleTree = ChaseMerkleTree.init(chaseCenter: location )
            
            // Assign properties
            newChase?.merkleBody = chaseMerkleTree.getMerkleBody()
            newChase?.merkleRoot = chaseMerkleTree.getRootHex()
        }else {
            let alertView = monsterAlertView(title: "Error", message: "Failed to process the selected location, please try again later")
            self.present(alertView, animated: false, completion: nil)
        }
    }
    
    func toggleMonsterAmountTextField() {
        howManyMonstersTextField.isEnabled = !howManyMonstersTextField.isEnabled
    }
    
    // MARK: - Selectors
    
    @objc func switchChanged(switchButton: UISwitch) {
        // Checks if the button is On or Off to disable/enable banano amount textField
        toggleMonsterAmountTextField()
        if switchButton.isOn {
            self.howManyMonstersTextField.text = ""
        } else {
            self.howManyMonstersTextField.text = ""
        }
    }
    
    // MARK: - colorPicker
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        monsterColorImage.backgroundColor = selectedColor
        
        if newChase != nil {
            newChase?.hexColor = selectedColor.hexValue()
            selectedColorHex = selectedColor.hexValue()
        } else {
            // If newQuest is nil, create a new one and assign the new hexColor
            do {
                newChase = try Chase.init(obj: [:], context: CoreDataUtils.mainPersistentContext)
                newChase?.hexColor = selectedColor.hexValue()
            } catch let error as NSError {
                print("Failed to create chase with error: \(error)")
            }
        }
        self.monsterImageBackground.backgroundColor = selectedColor
        
    }
    
    func colorPicker(_ colorPicker: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
        print("Confirmed a color")
    }
    
    func noBalanceHandler(message: String) {
        let alertView = monsterAlertView(title: "Failed", message: message)
        present(alertView, animated: false, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func addColorPressed(_ sender: Any) {
        do {
            let colorPickerController = try self.instantiateViewController(identifier: "colorPickerViewControllerID", storyboardName: "CreateChase") as! ColorPickerViewController
            
            colorPickerController.delegate = self
            present(colorPickerController, animated: true, completion: nil)
            
        } catch let error as NSError {
            print("failed: \(error)")
        }
        
    }
    
    @IBAction func addLocationPressed(_ sender: Any) {
        do {
            let mapVC = try instantiateViewController(identifier: "createChaseMapViewControllerID", storyboardName: "CreateChase")
            
            present(mapVC, animated: false, completion: nil)
        } catch let error as NSError {
            print("Failed to instantiate CreateChaseMapViewController with error: \(error)")
        }
        
    }
    
    @IBAction func createChaseButtonPressed(_ sender: Any) {
        // Check if the quest inputs are correct.
        if isNewChaseValid(){
            self.retrieveGasEstimate { (gasEstimateWei) in
                if let gasEstimate = gasEstimateWei {
                    let message = "Are you sure you want to hide this Monster?"
                    let txDetailsAlertView = self.monsterAlertView(title: "Confirmation", message: message) { (uiAlertAction) in
                        guard let player = self.currentPlayer else {
                            self.present(self.monsterAlertView(title: "Error", message: "Player account not found, please try again"), animated: true, completion: nil)
                            return
                        }
                        
                        guard let gasEstimateWei = gasEstimateWei else {
                            self.present(self.monsterAlertView(title: "Error", message: "Invalid nrg estimate"), animated: true, completion: nil)
                            return
                        }
                        
                        self.resolvePlayerWalletAuth(player: player, successHandler: { (wallet) in
                            self.currentWallet = nil
                            guard let playerAddress = player.address else {
                                self.noBalanceHandler(message: "An error has ocurred, please try again")
                                return
                            }
                            
                            PlayerBalanceQueueDispatcher.init(playerAddress: playerAddress, godfatherAddress: player.godfatherAddress, completionHandler: { (playerBalance, godfatherBalance) in
                                if godfatherBalance > gasEstimate {
                                    self.currentWallet = player.getGodfatherWallet()
                                } else if playerBalance > gasEstimate && self.currentWallet == nil {
                                    self.currentWallet = wallet
                                } else {
                                    self.noBalanceHandler(message: "An error has ocurred, please try again later")
                                    return
                                }
                                self.createNewChase(gasEstimateWei: gasEstimateWei)
                            })
                        }, errorHandler: { (error) in
                            self.present(self.monsterAlertView(title: "Error", message: "An error ocurred accessing your account, please try again"), animated: true, completion: nil)
                        })
                    }
                    txDetailsAlertView.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(txDetailsAlertView, animated: false, completion: nil)
                } else {
                    let alertView = self.monsterAlertView(title: "Error", message: "Error retrieving the transaction costs, please try again.")
                    self.present(alertView, animated: false, completion: nil)
                }
            }
        } else {
            let alertView = self.monsterAlertView(title: "Invalid", message: "Invalid quest, please complete the fields properly.")
            self.present(alertView, animated: false, completion: nil)
        }
    }
    
    // MARK: - TextViewDelegate
    // Credit: https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            textView.text = "Insert a clue about where the MONSTER will be hidden"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                updateHintCount(textView: textView)
            }
        }
    }
    
    func updateHintCount(textView: UITextView) {
        DispatchQueue.main.async {
            // Update text length indicator
            var textLength = textView.text.count
            guard let textColor = textView.textColor else {
                return
            }
            
            if textColor == UIColor.lightGray {
                textLength = 0
            }
            self.hintTextCountLabel.text = String.init(format: "%i/%i", textLength, self.maxHintSize)
            if textLength > self.maxHintSize {
                self.hintTextCountLabel.textColor = UIColor.red
            } else {
                self.hintTextCountLabel.textColor = AppColors.base.uiColor()
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateHintCount(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateHintCount(textView: textView)
    }
}

