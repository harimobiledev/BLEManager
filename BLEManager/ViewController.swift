//
//  ViewController.swift
//  BLEManager
//
//  Created by Hari Keerthipati on 29/06/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CentralManagerDelegate{


    var centralManager: CentralManager!
    var peripheralManager: PeripheralManager!
    
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        print("\(UIDevice.current.name, UIDevice.current.systemName, UIDevice.current.batteryLevel)")
        peripheralManager = PeripheralManager()
        centralManager = CentralManager(with: self)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        
        if let text = sender.titleLabel?.text
        {
            if var number = Int(text)
            {
                number += 1
                let string = "\(number)"
                sender.setTitle(string, for: .normal)
                peripheralManager.updateValue(string: string)
            }
        }
       
    }
    
    func updateValue(string: String) {
        textButton.setTitle(string, for: .normal)
    }
    
    func updateName(string: String) {
        nameLabel.text = string
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchAction(_ sender: UISwitch) {
        
        if sender.isOn
        {
            peripheralManager.startAdvertising()
        }
        else
        {
            peripheralManager.stopAdvertising()
        }
    }
}

