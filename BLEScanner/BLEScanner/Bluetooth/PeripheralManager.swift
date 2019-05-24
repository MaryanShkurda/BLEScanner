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
    
    private lazy var cbPeripheralManager = CBPeripheralManager(delegate: self, queue: queue)
    private var readCharacteristic: CBMutableCharacteristic!
    private var service: CBMutableService!
    
    private var queue = DispatchQueue(label: "BLECentralManager.queue", qos: .userInitiated)
    
    static let instance = PeripheralManager()
    
    private var isStartFlagSend = false
    private var sendingEOM = false
    private var sendDataIndex = 0
    private var dataToSend: Data?
    
    override private init() {
        super.init()
        readCharacteristic = CBMutableCharacteristic(
            type: TestData.BLEData.MY_PERIPHERAL_TEST_CHARACTERISTIC,
            properties: [.indicateEncryptionRequired], //[.read, .notify, .notifyEncryptionRequired, .indicateEncryptionRequired]
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
    
    func send(data: Data) {
        dataToSend = data
        send()
    }
    
    func send(){
        guard let data = dataToSend else { return }
        if !isStartFlagSend {
            isStartFlagSend = cbPeripheralManager
                .updateValue(BLEConstants.START_FLAG,
                             for: readCharacteristic,
                             onSubscribedCentrals: nil)
            Log.write("ℹ️ Start flag")
        }
        if sendingEOM {
            // send it
            let didSend = cbPeripheralManager
                .updateValue(BLEConstants.END_FLAG,
                             for: readCharacteristic,
                             onSubscribedCentrals: nil)
            // Did it send?
            if (didSend) {
                sendingCompleted()
            }
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return
        }
        
        guard sendDataIndex < data.count else {
            // No data left.  Do nothing
            return
        }
        
        var didSend = true
        
        while didSend {
            // Make the next chunk
            
            // Work out how big it should be
            var amountToSend = data.count - sendDataIndex;
            
            // Can't be longer than 20 bytes
            if (amountToSend > BLEConstants.NOTIFY_MTU) {
                amountToSend = BLEConstants.NOTIFY_MTU;
            }
            
            // Copy out the data we want
            let chunk = data.withUnsafeBytes{(body: UnsafePointer<UInt8>) in
                return Data(
                    bytes: body + sendDataIndex,
                    count: amountToSend
                )
            }
            // Send it
            didSend = cbPeripheralManager.updateValue(
                chunk,
                for: readCharacteristic,
                onSubscribedCentrals: nil
            )
            
            if (!didSend) {
                return
            }
            
            // It did send, so update our index
            sendDataIndex += amountToSend;
            
            // Was it the last one?
            if (sendDataIndex >= data.count) {
                // It was - send an EOM
                // Set this so if the send fails, we'll send it next time
                sendingEOM = true
                sendDataIndex = 0
                // Send it
                let eomSent = cbPeripheralManager.updateValue(
                    BLEConstants.END_FLAG,
                    for: readCharacteristic,
                    onSubscribedCentrals: nil
                )
                
                if (eomSent) {
                    sendingCompleted()
                    return
                }
            }
        }
    }
    
    func sendingCompleted() {
        isStartFlagSend = false
        sendingEOM = false
        sendDataIndex = 0
        dataToSend = nil
        Log.write("✅ EOM flag")
    }
}

//MARK: CBPeripheralManagerDelegate
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
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        send()
    }
}
