//
//  DownloadAndUpdateChaseIsWinnerOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift

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
    public var isWinner: Bool?
    
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
        
        monsterToken.isWinner(chaseIndex: chaseIndex, address: alledgedWinner, handler: { (error, results) in
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
            
            self.isWinner = isWinnerBool

            do {
                let chaseContext = CoreDataUtils.createBackgroundPersistentContext()
                guard let chase = Chase.getchaseByIndex(chaseIndex: String.init(self.chaseIndex), context: chaseContext) else {
                    self.error = DownloadAndUpdateChaseIsWinnerOperationError.updating
                    self.finish()
                    return
                }
                
                // First update the chase
                chase.winner = isWinnerBool
                try chase.save()
                
                // Then update the monster
                let context = CoreDataUtils.createBackgroundPersistentContext()
                guard let chaseIndex = chase.index else {
                    self.error = DownloadAndUpdateChaseIsWinnerOperationError.resultParsing
                    self.finish()
                    return
                }
                
                let monsterExists = Monster.exists(monsterIndex: chaseIndex, context: context)
                
                if isWinnerBool == true && monsterExists == false {
                    // Create the monster once
                    let monster = try Monster.init(chase: chase, context: context)
                    try monster.save()
                } else if isWinnerBool == false && monsterExists == true {
                    do {
                        guard let monster = Monster.getMonsterByIndex(monsterIndex: chaseIndex, context: context) else {
                            self.error = DownloadAndUpdateChaseIsWinnerOperationError.resultParsing
                            self.finish()
                            return
                        }
                        try monster.delete()
                    } catch {
                        self.error = DownloadAndUpdateChaseIsWinnerOperationError.resultParsing
                        self.finish()
                        return
                    }
                    
                }
                self.finish()
            } catch {
                self.error = DownloadAndUpdateChaseIsWinnerOperationError.updating
                self.finish()
                return
            }
        })
    }
}
