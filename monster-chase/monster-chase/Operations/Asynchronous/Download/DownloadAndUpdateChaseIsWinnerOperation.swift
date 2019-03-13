//
//  DownloadAndUpdateChaseIsWinnerOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import SwiftyJSON
import BigInt

public enum DownloadAndUpdateChaseIsWinnerOperationError: Error {
    case resultParsing
    case updating
    case monsterTokenInitError
}

public class DownloadAndUpdateChaseIsWinnerOperation: AsynchronousOperation {
    
    private var chaseIndex: BigInt
    private var alledgedWinner: String
    
    public init(chaseIndex: BigInt, alledgedWinner: String) {
        self.chaseIndex = chaseIndex
        self.alledgedWinner = alledgedWinner
        super.init()
    }
    
    open override func main() {
        // Init PocketAion instance
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = DownloadAndUpdateChaseIsWinnerOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        monsterToken.isWinner(chaseIndex: chaseIndex, address: alledgedWinner, handler: { (results, error) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            guard let isWinnerBool = results?.first as? Bool else {
                self.error = DownloadAndUpdateChaseIsWinnerOperationError.resultParsing
                self.finish()
                return
            }

            do {
                let context = CoreDataUtils.backgroundPersistentContext
                guard let chase = Chase.getchaseByIndex(chaseIndex: String.init(self.chaseIndex), context: context) else {
                    self.error = DownloadAndUpdateChaseIsWinnerOperationError.updating
                    self.finish()
                    return
                }

                if isWinnerBool == true {
                    guard let chaseIndex = chase.index else {
                        self.error = DownloadAndUpdateChaseIsWinnerOperationError.resultParsing
                        self.finish()
                        return
                    }
                    
                    if !Monster.exists(monsterIndex: chaseIndex, context: context) {
                        // Create the monster once
                        let monster = try Monster.init(chase: chase, context: context)
                        try monster.save()
                    } else {
                        print("Monster already exists")
                    }
                }

                chase.winner = isWinnerBool
                try chase.save()
                self.finish()
            } catch {
                self.error = DownloadAndUpdateChaseIsWinnerOperationError.updating
                self.finish()
                return
            }
        })
    }
}
