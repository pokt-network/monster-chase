//
//  AnnotationView.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/7/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import SceneKit
import HDAugmentedReality

protocol AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}

class AnnotationView: ARAnnotationView {
    
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var sceneView: SCNView?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    func loadUI() {
        // We remove all elements from the superview
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        sceneView?.removeFromSuperview()
        
        // Title label
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        //        label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.yellow
        
        self.addSubview(label)
        self.titleLabel = label
        
        // Distance label
        let label2 = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
        
        label2.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label2.textColor = UIColor.green
        label2.font = UIFont.systemFont(ofSize: 12)
        
        self.addSubview(label2)
        self.distanceLabel = label2
        
        // Annotation setup
        if let annotation = annotation {
            // Quest Info
            titleLabel?.text = annotation.title
            distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
            titleLabel?.isHidden = true
            distanceLabel?.isHidden = true
            
            // Scene for 3d object
            let myView = SCNView(frame: CGRect(x: 10, y: 45, width: 240, height: 240), options: nil)
            
            let materialA = SCNMaterial()
            materialA.diffuse.contents = UIImage(named: "cascara.png")
            
            let materialB = SCNMaterial()
            materialB.normal.contents = UIImage(named: "cascaranormal.png")
            
            myView.scene = SCNScene.init(named: "banano.scn")
            myView.scene?.rootNode.geometry?.materials = [materialA, materialB]
            
            myView.allowsCameraControl = true
            myView.autoenablesDefaultLighting = true
            myView.backgroundColor = UIColor.clear
            
            self.addSubview(myView)
            sceneView = myView
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
        distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
        sceneView?.frame = CGRect(x: 10, y: 45, width: 240, height: 240)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
}
