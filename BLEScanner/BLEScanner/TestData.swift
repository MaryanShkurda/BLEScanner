//
//  TestData.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 5/22/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import Foundation
import CoreBluetooth

struct TestData {
    struct BLEData {
        static let TEST_SERVICE_PLAYGROUND = CBUUID(string: "0x2FA2")
        static let TEST_CHARACTERISTIC_PLAYGROUND = CBUUID(string: "0x1a2b")
        
        static let MY_PERIPHERAL_TEST_SERVICE = CBUUID(string: "2F59057E-63FB-490E-BB16-B1630982A7D6")
        static let MY_PERIPHERAL_TEST_CHARACTERISTIC = CBUUID(string: "D194FA14-9266-42D6-A750-16EA9F314971")
    }
}

