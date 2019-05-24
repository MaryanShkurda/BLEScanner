//
//  CentralVC.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 5/23/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralVC: UIViewController {

    @IBOutlet weak var logView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateLog()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLog), name: .onLogWrite, object: nil)
        logView.keyboardDismissMode = .interactive
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var bleCentralManager = BLECentralManager.instance
    
    
    @IBAction func clearPressed(_ sender: UIButton) {
        Log.clean()
    }
    
    @IBAction func runPressed(_ sender: UIButton) {
        bleCentralManager.setDidDiscoverPeripheralClosure { [weak self](peripheral) in
            guard let strongSelf = self else { return }
            strongSelf.bleCentralManager.connect(toPeripheral: peripheral, completion: { (connected, error) in
                if let _ = connected {
                    strongSelf.bleCentralManager
                        .subscribeToCharacteristic(characteristicUUID: TestData.BLEData.MY_PERIPHERAL_TEST_CHARACTERISTIC, inService: TestData.BLEData.MY_PERIPHERAL_TEST_SERVICE)
                }
            })
        }
        bleCentralManager.startScan(serviceUUIDs: [TestData.BLEData.MY_PERIPHERAL_TEST_SERVICE])
    }
    
    @objc func updateLog() {
        logView.text = Log.read()
    }
}
