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
    static let ConnectingToDeviceTitle = "Connecting to device..."
}

class PeripheralsVC: BluetoothSessionVC {
    
    @IBOutlet weak var table: UITableView!
    
    var peripherals = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleManager.setDidDiscoverPeripheralClosure { [weak self](peripheral) in
            guard let strongSelf = self else { return }
            if !strongSelf.peripherals.contains(peripheral){
                strongSelf.peripherals.append(peripheral)
                strongSelf.table.reloadData()
            }
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
        LoadingIndicatorView.show(.ConnectingToDeviceTitle)
        bleManager.connect(toPeripheral: peripheral) { [weak self](p, error) in
            if let error = error {
                LoadingIndicatorView.hide()
                self?.showAlert(title: error.localizedDescription, message: nil)
                return
            }
            self?.bleManager.discoverServices(completion: { (services, error) in
                LoadingIndicatorView.hide()
                if let error = error {
                    self?.showAlert(title: error.localizedDescription, message: nil)
                    return
                }
                if let services = services {
                    self?.performSegue(withIdentifier: .PeripheralsToServicesSegue, sender: services)
                }
            })
        }
    }
}
