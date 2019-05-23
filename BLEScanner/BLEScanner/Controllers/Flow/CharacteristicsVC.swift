//
//  CharacteristicsVC.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 3/6/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit
import CoreBluetooth

private extension String {
    static let CharacteristicsCellID = "CharacteristicsCell"
}

class CharacteristicsVC: BluetoothSessionVC {

    @IBOutlet weak var table: UITableView!
    var characteristics = [CBCharacteristic]()

}

// MARK: UITableViewDataSource conformance
extension CharacteristicsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return characteristics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .CharacteristicsCellID, for: indexPath)
        let characteristic = self.characteristics[indexPath.section]
        cell.textLabel?.text = characteristic.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let characteristicName = self.characteristics[section].uuid.description
        return characteristicName
    }
}
