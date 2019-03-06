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
    static let PeripheralsToServicesSegue = "PeripheralsToServicesSegue"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let servicesVC = segue.destination as? ServicesVC, let services = sender as? [CBService] {
            servicesVC.services = services
        }
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
        let peripheral = peripherals[indexPath.row]
        bleManager.connect(toPeripheral: peripheral) { [weak self](p, error) in
            if let p = p {
                self?.bleManager.discoverServices(completion: { (services, error) in
                    if let services = services {
                        self?.performSegue(withIdentifier: .PeripheralsToServicesSegue, sender: services)
                    }
                })
            }
        }
    }
}
