//
//  TempViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 7/22/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import CoreBluetooth
import NVActivityIndicatorView
import StoreKit
class TempViewController: UIViewController {
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var rsLabel: UILabel!
    @IBOutlet weak var hsiLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var timer = Timer()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    //var centralManager: CBCentralManager!
    //var kestrelPeripheral: CBPeripheral!
    //let kestrelServiceCBUUID = CBUUID(string: "0x181A")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if !delegate.state.hasPrefix("Connected"){
            delegate.centralManager.scanForPeripherals(withServices: nil)
            delegate.state = "Disconnected and reconnecting"
        }
        
        reloadFromKestrel()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.reloadFromKestrel), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    @objc func reloadFromKestrel(){
        
        self.statusLabel.text = delegate.state
        if delegate.state.hasPrefix("Connected"){
            self.statusLabel.textColor = UIColor.white
            self.statusLabel.backgroundColor = UIColor.flatMint
            self.tempLabel.text = String(format: "%.1f", delegate.temp) + "°F"
            self.rsLabel.text = String(format: "%.1f", delegate.humidity) + "%"
            self.hsiLabel.text = String(format: "%.1f", delegate.hsi) + "°F"
        }
        else if delegate.state.hasPrefix("Disconnected") {
            self.statusLabel.textColor = UIColor.white
            self.statusLabel.backgroundColor = UIColor.flatRed
            self.tempLabel.text = "--"
            self.rsLabel.text = "--"
            self.hsiLabel.text = "--"
        }
        if delegate.centralManager.state == CBManagerState.poweredOff {
            self.statusLabel.textColor = UIColor.white
            self.statusLabel.text = "Bluetooth is Powered Off"
            self.statusLabel.backgroundColor = UIColor.flatYellow
            self.tempLabel.text = "--"
            self.rsLabel.text = "--"
            self.hsiLabel.text = "--"
        }
        
    }

}
/*
extension TempViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
                self.statusLabel.text = "Please turn on your bluetooth"
            case .poweredOn:
                print("central.state is .poweredOn")
                centralManager.scanForPeripherals(withServices: nil)
                self.statusLabel.text = "Scanning"
                self.startAnimating(CGSize(width: 25, height: 25), message: "Scanning")
                //centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if peripheral.name?.range(of:"Kestrel") != nil {
            kestrelPeripheral = peripheral
            //self.statusLabel.text = "Connecting to " + (kestrelPeripheral.name)!
            self.stopAnimating()
            self.startAnimating(CGSize(width: 25, height: 25), message: "Connecting to " + (kestrelPeripheral.name)!)
            centralManager.stopScan()
            centralManager.connect(kestrelPeripheral)
            kestrelPeripheral.delegate = self
            
        }
        
        
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        self.statusLabel.text = "Connected to " + (kestrelPeripheral.name)!
        self.statusLabel.textColor = UIColor.white
        self.statusLabel.backgroundColor = UIColor.flatMint
        self.stopAnimating()
        kestrelPeripheral.discoverServices(nil)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconncted!")
        self.statusLabel.text = "Disconnected"
        self.statusLabel.textColor = UIColor.white
        self.statusLabel.backgroundColor = UIColor.flatRed
    }
    
    
}

extension TempViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.uuid == CBUUID(string: "12630001-CC25-497D-9854-9B6C02C77054"){
                let data = characteristic.value?.advanced(by: 1)
                let value = data?.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
                    return ptr.pointee
                }
                self.tempLabel.text = String(format: "%.1f", Double(value!)/100*1.8+32) + "°F"
            }
            if characteristic.uuid == CBUUID(string: "12630002-CC25-497D-9854-9B6C02C77054"){
                let data = characteristic.value?.advanced(by: 1)
                let value = data?.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
                    return ptr.pointee
                }
                self.rsLabel.text = String(format: "%.1f", Double(value!)/100*1.8+32) + "%"
            }
            if characteristic.uuid == CBUUID(string: "12630003-CC25-497D-9854-9B6C02C77054"){
                let data = characteristic.value?.advanced(by: 1)
                let value = data?.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
                    return ptr.pointee
                }
                self.hsiLabel.text = String(format: "%.1f", Double(value!)/100*1.8+32) + "°F"
            }
        }
    }
}
*/
