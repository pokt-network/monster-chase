//
//  ChasingViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import BigInt

class ChasingViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    // IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nearestButton: UIButton!
    @IBOutlet weak var newestButton: UIButton!
    @IBOutlet weak var backgroundView: BackgroundView!
    @IBOutlet weak var topOrangeViewHeightConstraint: NSLayoutConstraint!
    
    // Variables
    var chases: [Chase] = [Chase]()
    var currentIndex = 0
    var locationManager = CLLocationManager()
    var currentPlayerLocation: CLLocation?
    
    // Activity Indicator
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var grayView: UIView?
    
    // Refresh Control
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ChasingViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.yellow
        refreshControl.transform = CGAffineTransform(scaleX: 1.75, y: 1.75)
        return refreshControl
    }()
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutside)
        
        // Location Manager
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gray view setup
        grayView = UIView.init(frame: view.frame)
        grayView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.75)
        grayView?.isHidden = true
        view.addSubview(grayView!)
        
        // Activity indicator setup
        indicator.center = view.center
        view.addSubview(indicator)
        self.collectionView.addSubview(refreshControl)
        
        do {
            self.loadQuestList()
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func refreshView() throws {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.indicator.stopAnimating()
            self.grayView?.isHidden = true
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.reloadData()
            if self.chases.count > 0 {
                let indexPath = IndexPath.init(item: 0, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
            }
            self.collectionView.collectionViewLayout.invalidateLayout()
            if UIDevice.modelName == "iPhone SE" || UIDevice.modelName == "Simulator iPhone SE" {
                self.topOrangeViewHeightConstraint.constant = 180
            }
        }
    }
    
    // MARK: Tools
    func toggleIndicator() {
        DispatchQueue.main.async {
            if self.indicator.isAnimating {
                self.indicator.stopAnimating()
                self.grayView?.isHidden = true
            } else {
                self.indicator.startAnimating()
                self.grayView?.isHidden = false
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.isUserInteractionEnabled = false
        
        // Launch Queue Dispatchers
        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            if let playerAddress = player.address {
                var godfatherAddress: String? = nil
                if let godfatherWallet = player.getGodfatherWallet() {
                    godfatherAddress = godfatherWallet.address
                }
                let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: playerAddress, monsterTokenAddress: AppConfiguration.monsterTokenAddress, godfatherAddress: godfatherAddress)
                appInitQueueDispatcher.initDispatchSequence {
                    let chaseListQueueDispatcher = AllChasesQueueDispatcher.init(monsterTokenAddress: AppConfiguration.monsterTokenAddress, playerAddress: playerAddress)
                    chaseListQueueDispatcher.initDispatchSequence(completionHandler: {
                        DispatchQueue.main.async {
                            do {
                                self.loadQuestList()
                                try self.refreshView()
                            } catch let error as NSError {
                                print("Failed to refreshView() with error: \(error)")
                            }
                        }
                    })
                }
            } else {
                refreshControl.endRefreshing()
                self.collectionView.isUserInteractionEnabled = true
            }
        } catch {
            refreshControl.endRefreshing()
            self.collectionView.isUserInteractionEnabled = true
        }
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            let alertView = self.monsterAlertView(title: "Error", message: "Location services are disabled, please enable for a better questing experience")
            self.present(alertView, animated: false, completion: nil)
        }
    }
    
    func loadQuestList() {
        // Initial load for the local quest list
        do {
            if let playerLocation = self.currentPlayerLocation {
                self.chases = try Chase.sortedChasesByNearest(context: CoreDataUtils.mainPersistentContext, userLocation: playerLocation)
            } else {
                self.chases = try Chase.sortedChasesByIndex(context: CoreDataUtils.mainPersistentContext)
            }
            if self.chases.count == 0 {
                DispatchQueue.main.async {
                    self.errorMessageLabel.text = "No Chases available, please try again later..."
                    self.showElements(bool: false)
                }
            } else {
                self.showElements(bool: true)
                do {
                    try self.refreshView()
                }catch let error as NSError {
                    print("Failed to refreshView with error: \(error)")
                }
            }
        } catch {
            self.chases = [Chase]()
            let alert = self.monsterAlertView(title: "Error", message: "Failed to retrieve chase list with error:")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve chase list with error: \(error)")
        }
    }
    
    func loadChaseListByNearest() {
        // Load chase list by nearest
        if currentPlayerLocation == nil {
            return
        }
        
        do {
            self.chases = try Chase.sortedChasesByNearest(context: CoreDataUtils.mainPersistentContext, userLocation: currentPlayerLocation!)
            
            if self.chases.count == 0 {
                DispatchQueue.main.async {
                    self.errorMessageLabel.text = "No Chases available, please try again later..."
                    self.showElements(bool: false)
                }
            } else {
                self.showElements(bool: true)
                do {
                    try self.refreshView()
                }catch let error as NSError {
                    print("Failed to refreshView with error: \(error)")
                }
            }
        } catch {
            let alert = self.monsterAlertView(title: "Error", message: "Failed to retrieve chase list with error:")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve chase list with error: \(error)")
        }
    }
    
    func showElements(bool: Bool) {
        DispatchQueue.main.async {
            self.errorMessageLabel.isHidden = bool
            self.collectionView.isHidden = !bool
            self.previousButton.isHidden = !bool
            self.nextButton.isHidden = !bool
            self.completeButton.isHidden = !bool
        }
    }
    
    func scrollToPositionedCell(positions: Int) {
        if let currentVisibleCell = self.collectionView.visibleCells.first {
            guard let cellIndexPath = self.collectionView.indexPath(for: currentVisibleCell) else {
                return
            }
            let currentChaseCount = self.chases.count
            let newIndex = cellIndexPath.item + positions
            
            if newIndex >= 0 && newIndex < currentChaseCount {
                let newIndexPath = IndexPath(item: newIndex, section: 0)
                collectionView.scrollToItem(at: newIndexPath, at: .right, animated: true)
            }
        }
    }
    
    // Is player the chase creator?
    func isChaseCreator(chase: Chase) -> Bool {
        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            let chaseCreator = chase.getCreatorHexAddress()
            
            if chaseCreator == player.address {
                return true
            }
            
        } catch let error as NSError {
            print("CompleteChaseViewController - isChaseCreator() - Failed to retrieve player information with error: \(error)")
        }
        return false
    }
    
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location update
        if locations.count > 0 {
            guard let location = locations.last else {
                return
            }
            let refreshQuestList = self.currentPlayerLocation == nil
            self.currentPlayerLocation = location
            
            if (refreshQuestList == true) {
                self.loadQuestList()
            }
        } else {
            let alertView = self.monsterAlertView(title: "Error", message: "Failed to get current location.")
            self.present(alertView, animated: false, completion: nil)
            
            print("Failed to get current location")
        }
    }
    
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        completeButtonPressed(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chases.count == 0 ? 1 : chases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = backgroundView.bounds.width
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chaseCollectionViewIdentifier", for: indexPath) as! ChaseCollectionViewCell
        
        currentIndex = indexPath.item
        
        if chases.isEmpty || currentIndex >= chases.count {
            cell.configureEmptyCellFor(index: indexPath.item)
            return cell
        }
        
        let chase = chases[currentIndex]
        cell.chase = chase
        cell.configureCellFor(index: indexPath.item, playerLocation: self.currentPlayerLocation)
        
        return cell
    }
    
    // MARK: IBActions
    @IBAction func nearestButtonTapped(_ sender: Any) {
        grayView?.isHidden = false
        indicator.startAnimating()
        
        nearestButton.isHidden = true
        newestButton.isHidden = false
        
        loadChaseListByNearest()
    }
    @IBAction func newestButtonTapped(_ sender: Any) {
        grayView?.isHidden = false
        indicator.startAnimating()
        
        nearestButton.isHidden = false
        newestButton.isHidden = true
        
        loadQuestList()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        scrollToPositionedCell(positions: 1)
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        scrollToPositionedCell(positions: -1)
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        guard let currentCell = collectionView.visibleCells.last as? ChaseCollectionViewCell else {
            let alert = self.monsterAlertView(title: "Error", message: "Failed to retrieve current chase, please try again later.")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve current chase, returning")
            return
        }
        
        if let chase = currentCell.chase {
            if chase.winner == true {
                let alert = self.monsterAlertView(title: "Monster Alert!", message: "You already claimed this Monster!")
                self.present(alert, animated: false, completion: nil)
                return
            } else {
                if let chaseIndexStr = chase.index {
                    if let chaseIndexBigInt = BigInt.init(chaseIndexStr) {
                        do {
                            guard let playerAddress = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext).address else {
                                return
                            }
                            let isWinnerOperation = DownloadAndUpdateChaseIsWinnerOperation.init(chaseIndex: chaseIndexBigInt, alledgedWinner: playerAddress)
                            isWinnerOperation.completionBlock = {
                                guard let isWinner = isWinnerOperation.isWinner else {
                                    return
                                }
                                
                                if isWinner == false {
                                    DispatchQueue.main.async {
                                        do {
                                            let vc = try self.instantiateViewController(identifier: "completeChaseViewControllerID", storyboardName: "CompleteChase") as? CompleteChaseViewController
                                            vc?.chase = chase
                                            vc?.currentUserLocation = self.currentPlayerLocation
                                            self.present(vc!, animated: false, completion: nil)
                                        }catch let error as NSError {
                                            let alert = self.monsterAlertView(title: "Error", message: "Ups, something happened, please try again later.")
                                            self.present(alert, animated: false, completion: nil)
                                            
                                            print("Failed to instantiate CompleteChaseViewController with error: \(error)")
                                        }
                                    }
                                } else {
                                    let alert = self.monsterAlertView(title: "Monster Alert!", message: "You already claimed this Monster!")
                                    self.present(alert, animated: false, completion: nil)
                                }
                                self.toggleIndicator()
                            }
                            let operationQueue = OperationQueue.init()
                            
                            // Toggle animation
                            self.toggleIndicator()
                            
                            operationQueue.addOperations([isWinnerOperation], waitUntilFinished: false)
                        } catch {
                            print("An error happened")
                        }
                    } else {
                        print("Error parsing big int")
                    }
                } else {
                    print("Chase without index")
                }
                
            }
        } else {
            let alert = self.monsterAlertView(title: "Error", message: "Failed to retrieve current chase, please try again later.")
            self.present(alert, animated: false, completion: nil)
        }
    }
}
