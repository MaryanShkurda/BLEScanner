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
}

class ServicesVC: BluetoothSessionVC {

    @IBOutlet weak var table: UITableView!
    var services = [CBService]()
    
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
        
    }
}

