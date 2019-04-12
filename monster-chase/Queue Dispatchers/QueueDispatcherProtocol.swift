//
//  QueueDispatcherProtocol.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation

public typealias QueueDispatcherCompletionHandler = () -> Void

public protocol QueueDispatcherProtocol {
    
    func initDispatchSequence(completionHandler: QueueDispatcherCompletionHandler?)
    func isQueueFinished() -> Bool
    func cancelAllOperations()
}
