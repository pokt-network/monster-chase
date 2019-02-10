//
//  CompleteChaseViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/7/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SwiftHEXColors
import BigInt

class CompleteChaseViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var monsterBackground: UIImageView!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var monsterCountLabel: UILabel!
    @IBOutlet weak var chaseDetailLabel: UILabel!
    @IBOutlet weak var monsterNameLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    var locationManager = CLLocationManager()
    var currentUserLocation: CLLocation?
    var chaseAreaLocation: CLLocation?
    var chase: Chase?
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Map settings
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.isZoomEnabled = true
        
        // Location Manager settings
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Background settings
        monsterBackground.layer.cornerRadius = monsterBackground.frame.size.width / 2
        monsterBackground.clipsToBounds = true
        
        // Refresh view
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // UI Updates
//        let deviceName = UIDevice.modelName
//
//        if deviceName == "iPhone X" || deviceName == "iPhone XS" || deviceName == "iPhone XS Max" || deviceName == "Simulator iPhone X" || deviceName == "Simulator iPhone XS" || deviceName == "Simulator iPhone XS Max" {
//            let newSize = CGRect(x: mapView.frame.origin.x, y: mapView.frame.origin.y, width: mapView.frame.width, height: 470)
//            mapView.frame = newSize
//        }
    }
    
    override func refreshView() throws {
        // Details view
        
        // Number of Monsters
        let maxWinnersCount = Int(chase?.maxWinners ?? "0")
        
        if maxWinnersCount == 0 {
            monsterCountLabel.text = "INFINITE"
            monsterCountLabel.font = monsterCountLabel.font.withSize(14)
        }else {
            monsterCountLabel.text = "\(chase?.winnersAmount ?? "0")/\(chase?.maxWinners ?? "0")"
            monsterCountLabel.font = monsterCountLabel.font.withSize(17)
        }
        
        // Add color to the monster
        let monsterColor = UIColor(hexString: chase?.hexColor ?? "31AADE")
        monsterBackground.backgroundColor = monsterColor
        
        // Hint
        chaseDetailLabel.text = chase?.hint
        
        // Monster/Chase Name
        monsterNameLabel.text = chase?.name.uppercased()
        
        // Chase quadrant setup
        setChaseQuadrant()
        
        // Distance from quest
        if let playerLocation = currentUserLocation {
            let distanceMeters = LocationUtils.chaseDistanceToPlayerLocation(chase: chase!, playerLocation: playerLocation).magnitude
            let roundedDistanceMeters = Double(round(10*distanceMeters)/10)
            var distanceText = "?"
            
            if roundedDistanceMeters > 999 {
                let roundedDistanceKM = roundedDistanceMeters/1000
                if roundedDistanceKM > 999 {
                    distanceText = String.init(format: "%.1fK KM", (roundedDistanceKM/1000))
                } else {
                    distanceText = String.init(format: "%.1f KM", (roundedDistanceKM/1000))
                }
            } else {
                distanceText = String.init(format: "%.1f M", roundedDistanceMeters)
            }
            if let questDistanceLabel = self.distanceValueLabel {
                questDistanceLabel.text = distanceText
            }
        } else {
            if let questDistanceLabel = self.distanceValueLabel {
                questDistanceLabel.text = "?"
            }
        }
        
    }
    
    // MARK: Tools
    // Present Find Chase VC
    func presentFindChaseViewController(proof: ChaseProofSubmission) {
        do {
            let vc = try instantiateViewController(identifier: "findMonsterViewControllerID", storyboardName: "CompleteChase") as? FindMonsterViewController
            vc?.chaseProof = proof
            vc?.currentChase = chase
            vc?.currentUserLocation = currentUserLocation
            
            present(vc!, animated: false, completion: nil)
        } catch let error as NSError {
            print("Failed to instantiate CompleteChaseViewController with error: \(error)")
        }
    }
    
    // Check if the user is near quest banano
    func checkIfNearBanano() {
//        guard let merkle = ChaseMerkleTree.generateChaseProofSubmission(answer: currentUserLocation!, merkleBody: (chase?.merkleBody)!) else {
//            let alertView = monsterAlertView(title: "Not in range", message: "Sorry, the monster location isn't nearby")
//            present(alertView, animated: false, completion: nil)
//
//            return
//        }
        // Show the Banano :D
        let merkle = ChaseProofSubmission.init(answer: "", proof: [String]())
        presentFindChaseViewController(proof: merkle)
    }
    
    // Quest quadrant
    func setChaseQuadrant() {
        // Chase Quadrant
        if let corners = chase?.getQuadranHintCorners() {
            let location = LocationUtils.getRegularCentroid(points: corners)
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            // show quadrant on map
            let circle = MKCircle(center: center, radius: 200)
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.addOverlay(circle)
            
            chaseAreaLocation = location
            
        } else {
            print("Failed to get quest quadrant")
        }
    }
    
    // MARK: LocationManager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location update
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            let alertView = self.monsterAlertView(title: "Error", message: "Restricted by parental controls. User can't enable Location Services.")
            self.present(alertView, animated: false, completion: nil)
            
            print("restricted by e.g. parental controls. User can't enable Location Services")
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            let alertView = self.monsterAlertView(title: "Error", message: "User denied your app access to Location Services, but can grant access from Settings.app.")
            self.present(alertView, animated: false, completion: nil)
            
            print("user denied your app access to Location Services, but can grant access from Settings.app")
            break
        }
    }
    
    // MARK: MKMapView
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = AppColors.base.uiColor().withAlphaComponent(0.70)
        circleRenderer.strokeColor = AppColors.base.uiColor()
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        return nil
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        
        if let userLocation = mapView.userLocation.location {
            currentUserLocation = userLocation
        }
        
        if currentUserLocation == nil {
            let alertController = monsterAlertView(title: "Wait!", message: "Let the app get your current location :D")
            
            present(alertController, animated: false, completion: nil)
            return
        }
        // Check if near banano location
        checkIfNearBanano()
    }
}

