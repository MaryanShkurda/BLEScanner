//
//  PeripheralVC.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 5/23/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit

class PeripheralVC: UIViewController {

    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var startBtn: UIButton!
    
    var peripheralManager = PeripheralManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLog()
        logView.keyboardDismissMode = .interactive
        NotificationCenter.default.addObserver(self, selector: #selector(updateLog), name: .onLogWrite, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        peripheralManager.run()
    }
    @IBAction func _0Pressed(_ sender: UIButton) {
        peripheralManager.send(str: "0")
    }
    
    
    @IBAction func _1Pressed(_ sender: UIButton) {
        peripheralManager.send(str: "1")
    }
    
    @IBAction func clearLogPressed(_ sender: UIButton) {
        Log.clean()
    }
    
    @objc func updateLog() {
        logView.text = Log.read()
    }
}
