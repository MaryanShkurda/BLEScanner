//
//  BluetoothManager.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 3/6/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import Foundation
import CoreBluetooth

typealias DidDiscoverServicesClosure = ([CBService]?, Error?) -> Void
typealias DidDiscoverCharacteristicsClosure = ([CBCharacteristic]?, Error?) -> Void
typealias DidConnectToPeripheralClosure = (CBPeripheral?, Error?) -> Void
typealias DidDiscoverPeripheralClosure = (CBPeripheral) -> Void

enum BluetoothError: Error {
    case noConnectedPeripheral
}

class BluetoothManager: NSObject {
    
    private var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var peripherals = [CBPeripheral]()
    
    static let shared = BluetoothManager()
    
    private var didDiscoverPeripheralClosure: DidDiscoverPeripheralClosure?
    private var didConnectToPeripheralClosure: DidConnectToPeripheralClosure?
    private var didDiscoveredServicesClosure: DidDiscoverServicesClosure?
    private var didDiscoveredCharacteristicsClosure: DidDiscoverCharacteristicsClosure?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func setDidDiscoverPeripheralClosure(closure: @escaping DidDiscoverPeripheralClosure){
        self.didDiscoverPeripheralClosure = closure
    }
    
    func connect(toPeripheral peripheral: CBPeripheral, completion: @escaping DidConnectToPeripheralClosure){
        if let connected = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connected)
        }
        self.didConnectToPeripheralClosure = completion
        centralManager.connect(peripheral, options: nil)
    }
    
    var isPoweredOn: Bool {
        return centralManager.state == .poweredOn
    }
    
    func discoverServices(completion: @escaping DidDiscoverServicesClosure) {
        guard let connected = connectedPeripheral else {
            completion(nil, BluetoothError.noConnectedPeripheral)
            return
        }
        connected.discoverServices(nil)
        didDiscoveredServicesClosure = completion
    }
    
    func discoverCharacteristics(forService service: CBService, completion: @escaping DidDiscoverCharacteristicsClosure) {
        guard let connected = connectedPeripheral else {
            completion(nil, BluetoothError.noConnectedPeripheral)
            return
        }
        didDiscoveredCharacteristicsClosure = completion
        connected.discoverCharacteristics(nil, for: service)
    }
}

// MARK: CBCentralManagerDelegate conformance
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("✅")
        switch central.state {
        case .poweredOn:
            print("central.state is .poweredOn")
            startScan()
        default:
            print("central.state is .poweredOff")
            centralManager.stopScan()
            peripherals.removeAll()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            peripherals.append(peripheral)
            didDiscoverPeripheralClosure?(peripheral)
            
            print(name)
            print("\n---\(advertisementData)\n")
            print("📶 RSSI: \(RSSI)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ didConnect: \(peripheral.name)")
        self.connectedPeripheral = peripheral
        didConnectToPeripheralClosure?(peripheral, nil)
        peripheral.delegate = self
        //peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❗️❗️didFailToConnect: \(peripheral.name)")
        didConnectToPeripheralClosure?(nil, error)
        self.connectedPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❗️didDisconnectPeripheral: \(peripheral.name)")
        self.connectedPeripheral = nil
    }
    
}

// MARK: CBPeripheralDelegate conformance
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        didDiscoveredServicesClosure?(peripheral.services, error)
        if let services = peripheral.services {
            for service in services {
                print("⚠️ service: \(service.uuid)")
                //peripheral.discoverCharacteristics(nil, for: service)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        didDiscoveredCharacteristicsClosure?(service.characteristics, error)
        if let characteristics = service.characteristics {
            print("⚠️⚠️ characteristics for \(service.uuid) : \n \(characteristics) \n---------\n")
        }
    }
}
