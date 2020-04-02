//
//  ClientViewController.swift
//  BluetoothSample3
//
//  Created by Takuya Yokoyama on 2020/04/01.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import UIKit
import CoreBluetooth
import Combine

class ClientViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BluetoothSession.shared.client.log
            .assign(to: \.text, on: textView)
            .store(in: &cancellables)
    }

    @IBAction func tapScan(_ sender: Any) {
        BluetoothSession.shared.client.scan()
    }
}
