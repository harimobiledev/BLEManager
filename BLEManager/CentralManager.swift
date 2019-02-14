//
//  CentralManager.swift
//  BLEManager
//
//  Created by Hari Keerthipati on 29/06/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var delegate: CentralManagerDelegate!
    var backgroundQueue: DispatchQueue!
    var mainQueue: DispatchQueue!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    init(with centralDelegate: CentralManagerDelegate) {
        super.init()
        delegate = centralDelegate
        backgroundQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "com.sample.blemanager")")
        centralManager = CBCentralManager(delegate: self, queue: backgroundQueue)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn
        {
            startScaning()
        }
        else{
            print("something went wrong")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("discovered peripheral")
        if self.discoveredPeripheral != peripheral{
            discoveredPeripheral = peripheral
            if let name = advertisementData[CBAdvertisementDataLocalNameKey]
            {
                DispatchQueue.main.async {
                    self.delegate.updateName(string: name as! String)
                }
            }
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("fail to connect device")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("connected to peripheral")
        centralManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: serviceUUID)])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("discovered services")
        if let services = peripheral.services
        {
            for service in services{
                print("service uuid==\(service.uuid.uuidString, serviceUUID)")
                if service.uuid.uuidString == serviceUUID
                {
                    peripheral.discoverCharacteristics([CBUUID(string: characteristicUUID)], for: service)
                }
                else
                {
                    print("not looking for this service")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let data = characteristic.value
        {
            if let stringFromData = String(data: data, encoding: .utf8)
            {
                print("get value for characteristic===\(stringFromData))")
                DispatchQueue.main.async {
                    self.delegate.updateValue(string: stringFromData)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("discovered characterstics")
        if let characteristics = service.characteristics
        {
            for characteristic in characteristics
            {
                if characteristic.uuid.uuidString == characteristicUUID
                {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let peripheralError = error
        {
            print("didUpdateNotificationStateFor error==\(peripheralError.localizedDescription)")
        }
        if characteristic.isNotifying
        {
            print("notification", characteristic)
        }
        else
        {
            print("notification stopped for", characteristic)
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        discoveredPeripheral = nil
    }
    
    func startScaning()
    {
        print("started scanning")
        centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
}

protocol CentralManagerDelegate {
    
    func updateValue(string: String)
    func updateName(string: String)
}
