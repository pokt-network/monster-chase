//
//  UIApplication+extension.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

extension UIApplication{
    public typealias PresentVCCompletionHandler = (_: UIViewController?) -> Void
    
    class func getPresentedViewController(handler: @escaping PresentVCCompletionHandler) {
        
        DispatchQueue.main.async {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                if let _ = rootVC as? UINavigationController {
                    if let vc = rootVC.children.last {
                        handler(vc)
                    }
                }else {
                    handler(rootVC)
                }
            }else {
                handler(nil)
            }
        }
    }
}
