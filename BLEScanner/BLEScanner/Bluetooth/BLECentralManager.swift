//
//  BluetoothManager.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 3/6/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit
import CoreBluetooth

typealias DidDiscoverServicesClosure = ([CBService]?, Error?) -> Void
typealias DidDiscoverCharacteristicsClosure = ([CBCharacteristic]?, Error?) -> Void
typealias DidConnectToPeripheralClosure = (CBPeripheral?, Error?) -> Void
typealias DidDiscoverPeripheralClosure = (CBPeripheral) -> Void
typealias DidUpdateValueForCharacterstic = (CBCharacteristic, Error?) -> Void

enum BluetoothError: Error, LocalizedError {
    case noConnectedPeripheral
    case poweredOff
    
    var errorDescription: String?{
        switch self {
        case .noConnectedPeripheral:
            return "No connected peripheral"
        case .poweredOff:
            return "Bluetooth is turned off"
        }
    }
}

class BLECentralManager: NSObject {
    
    private var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var peripherals = [CBPeripheral]()
    static let identifier = "CentralManagerIdentifier"
    
    static let instance = BLECentralManager()
    
    private var didDiscoverPeripheralClosure: DidDiscoverPeripheralClosure?
    private var didConnectToPeripheralClosure: DidConnectToPeripheralClosure?
    private var didDiscoveredServicesClosure: DidDiscoverServicesClosure?
    private var didDiscoveredCharacteristicsClosure: DidDiscoverCharacteristicsClosure?
    private var didUpdateValueForCharactersticClosure: DidUpdateValueForCharacterstic?
    
    var bleDataHandler: BLEDataHandlerProtocol? = BLEDataHandler()
    
    override private init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil,
                                          options: [CBCentralManagerOptionRestoreIdentifierKey: BLECentralManager.identifier])
    }
    
    func startScan(serviceUUIDs: [CBUUID]? = nil) {
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
    }
    
    func setDidDiscoverPeripheralClosure(closure: @escaping DidDiscoverPeripheralClosure){
        self.didDiscoverPeripheralClosure = closure
    }
    
    func connect(toPeripheral peripheral: CBPeripheral, completion: @escaping DidConnectToPeripheralClosure){
        guard isPoweredOn else {
            completion(nil, BluetoothError.poweredOff)
            return
        }
        if let connected = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connected)
        }
        self.didConnectToPeripheralClosure = completion
        centralManager.connect(peripheral, options: nil)
    }
    
    var isPoweredOn: Bool {
        return centralManager.state == .poweredOn
    }
    
    func discoverServices(serviceUUIDs: [CBUUID]? = nil, completion: @escaping DidDiscoverServicesClosure) {
        guard let connected = connectedPeripheral else {
            completion(nil, BluetoothError.noConnectedPeripheral)
            return
        }
        connected.discoverServices(serviceUUIDs)
        didDiscoveredServicesClosure = completion
    }
    
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]? = nil, forService service: CBService, completion: @escaping DidDiscoverCharacteristicsClosure) {
        guard let connected = connectedPeripheral else {
            completion(nil, BluetoothError.noConnectedPeripheral)
            return
        }
        didDiscoveredCharacteristicsClosure = completion
        connected.discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    func readCharactersitic(characteristic: CBCharacteristic, completion: @escaping DidUpdateValueForCharacterstic) {
        didUpdateValueForCharactersticClosure = completion
        connectedPeripheral?.readValue(for: characteristic)
    }
    
    func subscribeToCharacteristic(characteristicUUID: CBUUID, inService serviceUUID: CBUUID) {
        discoverServices(serviceUUIDs: [serviceUUID]) {[weak self] (services, error) in
            guard let strongSelf = self else { return }
            if let service = services?.filter({$0.uuid == serviceUUID}).first {
                strongSelf.discoverCharacteristics(characteristicUUIDs: [characteristicUUID],
                                                   forService: service, completion: { (characteristics, error) in
                                                    if let characteristic = characteristics?.filter({$0.uuid == characteristicUUID}).first {
                                                        strongSelf.connectedPeripheral?.setNotifyValue(true, for: characteristic)
                                                    }
                                                    
                })
            }
        }
    }
}

// MARK: CBCentralManagerDelegate conformance
extension BLECentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startScan(serviceUUIDs: [TestData.BLEData.MY_PERIPHERAL_TEST_SERVICE])
            Log.write("✅ BLE powered On")
        default:
            centralManager.stopScan()
            peripherals.removeAll()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let _ = peripheral.name {
            Log.write("✅ didDiscover peripheral")
            peripherals.append(peripheral)
            didDiscoverPeripheralClosure?(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Log.write("✅ didConnect peripheral")
        self.connectedPeripheral = peripheral
        didConnectToPeripheralClosure?(peripheral, nil)
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Log.write("⚠️⚠️ didFailToConnect peripheral")
        didConnectToPeripheralClosure?(nil, error)
        self.connectedPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Log.write("⚠️ didDisconnectPeripheral peripheral")
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        Log.write("✅central willRestoreState")
        Log.write("\(dict)")
        if let peripherls = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            Log.write("Restored: \(peripherls.count) peripherals")
            connectedPeripheral = peripherls.first
            connectedPeripheral?.delegate = self
            subscribeToCharacteristic(characteristicUUID: TestData.BLEData.MY_PERIPHERAL_TEST_SERVICE,
                                      inService: TestData.BLEData.MY_PERIPHERAL_TEST_SERVICE)
        }
    }
}

// MARK: CBPeripheralDelegate conformance
extension BLECentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Log.write("peripheral didDiscoverServices")
        didDiscoveredServicesClosure?(peripheral.services, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Log.write("peripheral didDiscoverCharacteristicsFor")
        didDiscoveredCharacteristicsClosure?(service.characteristics, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        didUpdateValueForCharactersticClosure?(characteristic, error)
        guard let value = characteristic.value else { return }
        Log.write("ℹ️ didUpdateValueFor characteristic: \(value.hexDescription)")
        bleDataHandler?.receivedNewPackage(data: value)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            Log.write("⚠️ didUpdateNotificationStateFor")
        } else {
            Log.write("✅ didUpdateNotificationStateFor")
        }
    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
