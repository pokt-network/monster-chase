//
//  PushNotificationUtils.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

public enum PushNotificationUtilsError: Error {
    case permissionDenied
}

public struct PushNotificationUtils {
    
    public static func requestPermissions(successHandler: (() -> Void)?, errorHandler: ((Error) -> Void)?) {
        let center =  UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (result, error) in
            if let error = error {
                if let errorHandler = errorHandler {
                    errorHandler(error)
                }
            } else {
                if result {
                    if let successHandler = successHandler {
                        successHandler()
                    }
                } else {
                    if let errorHandler = errorHandler {
                        errorHandler(PushNotificationUtilsError.permissionDenied)
                    }
                }
            }
        }
    }
    
    public static func sendNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
