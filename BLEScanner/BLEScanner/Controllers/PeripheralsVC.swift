//
//  PeripheralsVC.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 3/6/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit
import CoreBluetooth

private extension String {
    static let PeripheralCellID = "PeripheralCell"
}

class PeripheralsVC: BluetoothSessionVC {
    
    @IBOutlet weak var table: UITableView!
    
    var peripherals = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleManager.setDidDiscoverPeripheralClosure { [weak self](peripheral) in
            self?.peripherals.append(peripheral)
            self?.table.reloadData()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}

// MARK: UITableViewDataSource conformance
extension PeripheralsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .PeripheralCellID, for: indexPath)
        let peripheral = self.peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        return cell
    }
}

// MARK: UITableViewDelegate conformance
extension PeripheralsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
