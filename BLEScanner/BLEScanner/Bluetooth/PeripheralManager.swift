//
//  PeripheralManager.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 5/23/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralManager: NSObject {
    
    private lazy var cbPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    private var readCharacteristic: CBMutableCharacteristic!
    private var service: CBMutableService!
    
    static let instance = PeripheralManager()
    
    override private init() {
        super.init()
        readCharacteristic = CBMutableCharacteristic(
            type: TestData.BLEData.MY_PERIPHERAL_TEST_CHARACTERISTIC,
            properties: [.read, .notify, .notifyEncryptionRequired, .indicateEncryptionRequired],
            value: nil,
            permissions: .readEncryptionRequired
        )
        service = CBMutableService(
            type: TestData.BLEData.MY_PERIPHERAL_TEST_SERVICE,
            primary: true
        )
        
        // Add the characteristic to the service
        service.characteristics = [readCharacteristic!]
    }
    
    func run() {
        if !cbPeripheralManager.isAdvertising {
            cbPeripheralManager.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey : [service.uuid],
                CBAdvertisementDataLocalNameKey : "_TEST_PERIPHERAL_"
                ])
        }
    }
    
    func send(str: String) {
        let didSend = cbPeripheralManager.updateValue(
            str.data(using: String.Encoding.utf8)!,
            for: readCharacteristic,
            onSubscribedCentrals: nil
        )
        Log.write("ℹ️ \(str) didSend: \(didSend)")
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn {
            cbPeripheralManager.add(service)
            run()
            Log.write("✅ Peripheral power on")
        } else {
            Log.write("⚠️⚠️ Peripheral power state: \(peripheral.state.rawValue)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        Log.write("✅ central subscribed to peripheral")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        Log.write("⚠️ unsubscribed")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        Log.write("ℹ️ startAdvertising")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        Log.write("ℹ️ didReceiveRead request")
    }
}
