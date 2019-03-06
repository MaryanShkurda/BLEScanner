//
//  ServicesVC.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 3/6/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit
import CoreBluetooth

private extension String {
    static let ServiceCellID = "ServiceCell"
    static let ServicesToCharacteristics = "ServicesToCharacteristicsSegue"
}

class ServicesVC: BluetoothSessionVC {

    @IBOutlet weak var table: UITableView!
    var services = [CBService]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let characteristicsVC = segue.destination as? CharacteristicsVC, let characteristics = sender as? [CBCharacteristic] {
            characteristicsVC.characteristics = characteristics
        }
    }
}


// MARK: UITableViewDataSource conformance
extension ServicesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .ServiceCellID, for: indexPath)
        let service = self.services[indexPath.row]
        cell.textLabel?.text = service.uuid.description
        return cell
    }
}

// MARK: UITableViewDelegate conformance
extension ServicesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bleManager.discoverCharacteristics(forService: self.services[indexPath.row]) { [weak self](characteristics, error) in
            if let error = error {
                self?.showAlert(title: error.localizedDescription, message: nil)
                return
            }
            if let characteristics = characteristics {
                self?.performSegue(withIdentifier: .ServicesToCharacteristics, sender: characteristics)
            }
        }
    }
}

