//
//  BLEDataHandler.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 5/24/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import Foundation

protocol BLEDataHandlerProtocol {
    func receivedNewPackage(data: Data)
}

class BLEDataHandler: BLEDataHandlerProtocol {
    
    private var currentData = Data()
    private var transferringInProgress = false
    private var numberOfPackages = 0
    
    func receivedNewPackage(data: Data) {
        if data == BLEConstants.START_FLAG {
            transferringInProgress = true
            numberOfPackages = 0
            return
        }
        if data == BLEConstants.END_FLAG {
            transferringInProgress = false
            numberOfPackages = 0
            save()
            return
        }
        guard transferringInProgress else { return }
        
        currentData.append(data)
        numberOfPackages += 1
    }
    
    func save() {
        Log.write("✅ Received \(currentData.description) bytes")
        currentData = Data()
    }
    
}
