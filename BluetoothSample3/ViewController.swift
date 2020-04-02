//
//  ViewController.swift
//  BluetoothSample3
//
//  Created by Takuya Yokoyama on 2020/04/01.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import UIKit
import CoreBluetooth

let characteristic = CBMutableCharacteristic(
    type: CBUUID(string: "0001"),
    properties: [.notify, .read, .write],
    value: nil,
    permissions: [.readable, .writeable]
)

let service: CBMutableService = {
    let service = CBMutableService(type: CBUUID(string: "0000"), primary: true)
    service.characteristics = [characteristic]
    return service
}()

class ViewController: UIViewController {
    @IBAction func tapClientButton(_ sender: Any) {
        present(ClientViewController(), animated: true, completion: nil)
    }
    
    @IBAction func tapServerButton(_ sender: Any) {
        present(ServerViewController(), animated: true, completion: nil)
    }
    
    @IBAction func tapClientDemoButton(_ sender: Any) {
        present(ClientDemoViewController(), animated: true, completion: nil)
    }
    
    @IBAction func tapServerDemoButton(_ sender: Any) {
        present(ServerDemoViewController(), animated: true, completion: nil)
    }
}
