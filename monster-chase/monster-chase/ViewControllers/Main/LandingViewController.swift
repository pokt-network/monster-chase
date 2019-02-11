//
//  LandingViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/23/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var footerImage: UIImageView!
    let websiteUrl = URL.init(string: "https://www.pokt.network/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.openPocketWebsite(_:)))
        
        gestureRecognizer.delegate = self
        
        // Add gesture to element
        footerImage.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func refreshView() throws {
        print("LandingViewController - refreshView()")
    }
    
    @objc func openPocketWebsite(_ sender: Any) {
        UIApplication.shared.open(websiteUrl!, options: [:]) { (bool) in
            if bool {
                print("Website launched.")
            }else{
                print("Failed to launch website.")
            }
        }
    }
    
    func launchChasing() {
        do {
             _ = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch PlayerPersistenceError.retrievalError {
            // Player doesn't exist, redirect to wallet creation flow
            launchWalletCreation()
            return
        } catch {
            // Show error
            self.present(self.monsterAlertView(title: "Error", message: "Error loading your account, please try again"), animated: true, completion: nil)
            print("\(error)")
            return
        }
        
        do {
            let vc = try self.instantiateViewController(identifier: "containerViewControllerID", storyboardName: "Chasing") as? ContainerViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        }catch let error as NSError {
            // Show error
            self.present(self.monsterAlertView(title: "Error", message: "Error loading chase list, please try again"), animated: true, completion: nil)
            print("\(error)")
            return
        }
    }
    
    func launchWalletCreation() {
        do {
            let vc = try self.instantiateViewController(identifier: "AccountCreationViewController", storyboardName: "CreateAccount") as? NewWalletViewController
            
            self.navigationController?.pushViewController(vc!, animated: false)
        }catch let error as NSError {
            print("Failed to instantiate NewWalletViewController with error: \(error)")
        }
    }
    
    func launchOnboarding() {
        // Instantiate onboarding storyboard flow
        do {
            guard let onboardingVC = try self.instantiateViewController(identifier: "onboardingViewControllerID", storyboardName: "Onboarding") as? OnboardingViewController else {
                print("Error displaying onboarding")
                return
            }
            
            onboardingVC.completionHandler = {
                onboardingVC.dismiss(animated: true, completion: nil)
                self.processNavigation()
            }
            
            self.navigationController?.present(onboardingVC, animated: true, completion: nil)
        } catch {
            print("Error displaying onboarding")
        }
    }
    
    func processNavigation() {
        if AppConfiguration.displayedOnboarding() {
            launchChasing()
        } else {
            launchOnboarding()
        }
    }
    
    // MARK: - Actions
    @IBAction func playNowPressed(_ sender: Any) {
        processNavigation()
    }

    
}

