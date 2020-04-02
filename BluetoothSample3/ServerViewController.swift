//
//  ServerViewController.swift
//  BluetoothSample3
//
//  Created by Takuya Yokoyama on 2020/04/01.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import UIKit
import CoreBluetooth
import Combine

class BluetoothSession {
    static let shared = BluetoothSession()
    let server: Server
    let client: Client
    
    private init() {
        self.server = Server()
        self.client = Client()
        self.server.setUp()
        self.client.setUp()
    }
    
    class Server: NSObject {
        private var peripheralManager: CBPeripheralManager!
        let log = CurrentValueSubject<String, Never>("")
        
        func setUp() {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        }
        
        func add(_ service: CBMutableService) {
            peripheralManager.add(service)
        }
        
        func advertise() {
            peripheralManager.startAdvertising([
                CBAdvertisementDataLocalNameKey: UIDevice.current.name
            ])
        }
        
        func notifyToClient(message: String) {
            let data = message.data(using: .utf8)!
            peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
        }
    }
    
    class Client: NSObject {
        private var centralManager: CBCentralManager!
        private var peripheralManager: CBPeripheralManager!
        private var peripheral: CBPeripheral?
        let notifyValue = PassthroughSubject<String, Never>()
        let log = CurrentValueSubject<String, Never>("")
        
        func setUp() {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            peripheralManager = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
        }
        
        func scan() {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

extension BluetoothSession.Client: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {}
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "iPad" || peripheral.name == "俺のiPhone" {
            self.peripheral = peripheral
            central.stopScan()
            self.centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.value.append(contentsOf: "\(peripheral.name ?? "") にconnect成功\n")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log.value.append(contentsOf: "\(peripheral.name ?? "") からdisconnect\n")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log.value.append(contentsOf: "\(peripheral.name ?? "") にconnect失敗\n")
    }
}

extension BluetoothSession.Client: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { (service) in
            peripheral.discoverCharacteristics([], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { (characteristics) in
            peripheral.setNotifyValue(true, for: characteristics)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, let str = String(data: data, encoding: .utf8) else { return }
        notifyValue.send(str)
        log.value.append(contentsOf: "\(str)\n")
    }
}

extension BluetoothSession.Server: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {}
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        log.value.append(contentsOf: "\(error?.localizedDescription ?? "サービス追加成功") \n")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        log.value.append(contentsOf: "\(error?.localizedDescription ?? "アドバタイズ開始") \n")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        log.value.append(contentsOf: "didSubscribeTo \(characteristic.uuid) \n")
    }
}

class ServerViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BluetoothSession.shared.server.log
            .assign(to: \.text, on: textView)
            .store(in: &cancellables)
    }
    
    @IBAction func tapAddService(_ sender: Any) {
        BluetoothSession.shared.server.add(service)
    }
    
    @IBAction func tapAdvertise(_ sender: Any) {
        BluetoothSession.shared.server.advertise()
    }
    
    @IBAction func tapNotify(_ sender: Any) {
        BluetoothSession.shared.server.notifyToClient(message: Date().description)
    }
}
