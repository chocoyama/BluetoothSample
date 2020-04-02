//
//  ServerDemoViewController.swift
//  BluetoothSample3
//
//  Created by Takuya Yokoyama on 2020/04/01.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import UIKit

class ServerDemoViewController: UIViewController {
    @IBAction func tapPurchaseButton(_ sender: Any) {
        let value = (100..<10000).randomElement()!
        BluetoothSession.shared.server.notifyToClient(message: "\(value)")
    }
}
