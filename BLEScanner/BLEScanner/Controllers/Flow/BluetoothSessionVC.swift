//
//  ViewController.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 3/5/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit

class BluetoothSessionVC: UIViewController {
    
    var bleManager = BLECentralManager.instance
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

