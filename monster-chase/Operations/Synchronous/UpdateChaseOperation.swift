//
//  UpdateChaseOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import CoreData

public enum UpdateChaseOperationError: Error {
    case chaseFetchError
}

public class UpdateChaseOperation: SynchronousOperation {
    
    private var chaseDict: [AnyHashable: Any]
    private var chaseIndex: String
    
    public init(chaseDict: [AnyHashable: Any], chaseIndex: String) {
        self.chaseDict = chaseDict
        self.chaseIndex = chaseIndex
        super.init()
    }
    
    open override func main() {
        do {
            let context = CoreDataUtils.createBackgroundPersistentContext()
            let chase = try Chase.init(obj: chaseDict, context: context)
            try chase.save()
        } catch {
            self.error = error
            return
        }
    }
}
