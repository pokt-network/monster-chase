//
//  MenuViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var exploreLabel: UILabel!
    @IBOutlet weak var createChasingLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var howToPlayLabel: UIButton!
    @IBOutlet weak var leaderboardLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Background view styling
        backgroundView.backgroundColor = AppColors.neutral.uiColor()
        
        // Gesture for labels tap
        let exploreGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.exploreButtonTapped(_:)))
        let createChasingGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.createChaseButtonTapped(_:)))
        let profileGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.profileButtonTapped(_:)))
        let howToPlayGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.howToPlayButtonTapped(_:)))
        let leaderboardGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.leaderboardButtonTapped(_:)))
        
        // Set gesture delegates
        exploreGestureRecognizer.delegate = self
        createChasingGestureRecognizer.delegate = self
        profileGestureRecognizer.delegate = self
        howToPlayGestureRecognizer.delegate = self
        leaderboardGestureRecognizer.delegate = self
        
        // Add gestures to elements
        exploreLabel.addGestureRecognizer(exploreGestureRecognizer)
        createChasingLabel.addGestureRecognizer(createChasingGestureRecognizer)
        profileLabel.addGestureRecognizer(profileGestureRecognizer)
        howToPlayLabel.addGestureRecognizer(howToPlayGestureRecognizer)
        leaderboardLabel.addGestureRecognizer(leaderboardGestureRecognizer)
        
        // Gesture for tapping outside view
        let outsideGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.outsideTapped(_:)))
        
        outsideGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(outsideGestureRecognizer)
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func outsideTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
    }
    
    @IBAction func leaderboardButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "leaderboardViewControllerID", storyboardName: "Leaderboard") as? LeaderboardViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate LeaderboardViewController with error: \(error)")
        }
    }
    
    @IBAction func howToPlayButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "howToPlayViewControllerID", storyboardName: "Help") as? HowToPlayViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate HowToPlayViewController with error: \(error)")
        }
    }
    
    @IBAction func exploreButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "chasingViewControllerID", storyboardName: "Chasing") as? ChasingViewController
            
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate ChasingViewController with error: \(error)")
        }
    }
    
    @IBAction func createChaseButtonTapped(_ sender: Any) {
        
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "createChaseViewControllerID", storyboardName: "CreateChase") as? CreateChaseViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate ChasingViewController with error: \(error)")
        }
        
    }
    
    @IBAction func leaderBoardButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "leaderboardViewControllerID", storyboardName: "Leaderboard") as? LeaderboardViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate LeaderboardViewController with error: \(error)")
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "profileViewControllerID", storyboardName: "Profile") as? ProfileViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate ProfileViewController with error: \(error)")
        }
        
    }
    
    override func refreshView() throws {
        //
    }
    
}

