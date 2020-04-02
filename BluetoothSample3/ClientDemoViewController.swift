//
//  ClientDemoViewController.swift
//  BluetoothSample3
//
//  Created by Takuya Yokoyama on 2020/04/01.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import UIKit
import Combine

class ClientDemoViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BluetoothSession.shared.client.notifyValue
            .sink { (text) in
                self.label.text = text
            }
            .store(in: &cancellables)
    }
}
