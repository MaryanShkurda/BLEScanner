//
//  BLEConstants.swift
//  BLEScanner
//
//  Created by Marian Shkurda on 5/24/19.
//  Copyright © 2019 Marian Shkurda. All rights reserved.
//

import Foundation

enum BLEConstants {
    static let START_FLAG = "<BEG>".data(using: .utf8)!
    static let END_FLAG = "<END>".data(using: .utf8)!
    static let NOTIFY_MTU = 20
}
