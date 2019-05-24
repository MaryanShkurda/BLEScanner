//
//  Logger.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 5/22/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import UIKit

class Log {
    
    static let logURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
    
    static func write(_ string: String) {
        DispatchQueue.main.async {
            let line = "\(UIApplication.shared.applicationState.value)-[\(Date())]:\n\(string)\n------------\n"
            if let handle = try? FileHandle(forWritingTo: logURL) {
                handle.seekToEndOfFile()
                handle.write(line.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try? line.data(using: .utf8)?.write(to: logURL)
            }
            print(line)
            NotificationCenter.default.post(name: .onLogWrite, object: nil)
        }
    }
    
    static func read() -> String {
        return (try? String(contentsOf: logURL)) ?? ""
    }
    
    static func clean() {
        try? FileManager.default.removeItem(at: logURL)
        NotificationCenter.default.post(name: .onLogWrite, object: nil)
    }
}

extension Notification.Name {
    static let onLogWrite = Notification.Name("onLogWrite")
}

extension UIApplication.State {
    var value: String {
        switch self {
        case .background:
            return "BG"
        case .active:
            return "ACT"
        case .inactive:
            return "INACT"
        }
    }
}
