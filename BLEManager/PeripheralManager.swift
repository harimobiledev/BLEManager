//
//  PeripheralManager.swift
//  BLEManager
//
//  Created by Hari Keerthipati on 29/06/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralManager: NSObject, CBPeripheralManagerDelegate {

    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var queue: DispatchQueue!
    override init() {
        super.init()
        queue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "com.sample.blemanager")")
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
    }
    
    func startAdvertising()
    {
        print("startAdvertising")
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [CBUUID(string: serviceUUID)], CBAdvertisementDataLocalNameKey: UIDevice.current.name])
    }
    
    func stopAdvertising()
    {
        peripheralManager.stopAdvertising()
    }
    
    func updateValue(string: String) {
        
        queue.async {
            self.peripheralManager.updateValue(string.data(using: .utf8)!, for: self.transferCharacteristic, onSubscribedCentrals: nil)
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state != .poweredOn
        {
            print("not powered on")
            return
        }
        print("created characteristic")
        transferCharacteristic = CBMutableCharacteristic(type: CBUUID(string: characteristicUUID), properties: .notify, value: nil, permissions: .writeable)
        let transferService = CBMutableService(type: CBUUID(string: serviceUUID), primary: true)
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.add(transferService)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        let data = "11".data(using: .utf8)
        let didSend = peripheralManager.updateValue(data!, for: transferCharacteristic, onSubscribedCentrals: nil)
        print("did send\(didSend)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("unsubsribed")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        
        let data = "updated Text".data(using: .utf8)
        let didSend = peripheralManager.updateValue(data!, for: transferCharacteristic, onSubscribedCentrals: nil)
        print("did send\(didSend)")
    }
}
