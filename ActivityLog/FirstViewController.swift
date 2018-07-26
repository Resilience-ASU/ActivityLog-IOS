//
//  FirstViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 5/14/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import Eureka
import MapKit
import TimelineTableViewCell
import CoreData
import SCLAlertView
import UserNotifications
import Parse
import CoreBluetooth

class FirstViewController: FormViewController, CLLocationManagerDelegate {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var managedObjectContext: NSManagedObjectContext? = nil
    let locationManager = CLLocationManager()
    var lastLoc = CLLocation()
    
    var kestrelPeripheral: CBPeripheral!
    var first: Bool!
    let kestrelServiceCBUUID = CBUUID(string: "0x181A")
    
    let tempUUID = CBUUID(string: "12630001-CC25-497D-9854-9B6C02C77054")
    let humidityUUID = CBUUID(string: "12630002-CC25-497D-9854-9B6C02C77054")
    let hsiUUID = CBUUID(string: "12630003-CC25-497D-9854-9B6C02C77054")
    
    @IBOutlet weak var submitBTN: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if !delegate.state.hasPrefix("Connected"){
            delegate.centralManager.scanForPeripherals(withServices: nil)
            delegate.state = "Disconnected and reconnecting"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        submitBTN.backgroundColor = UIColor.flatGray
        self.submitBTN.isEnabled = false
        
        self.view.addSubview(submitBTN)
        sendLocalNotiction()
        
        delegate.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        //locationManager.activityType = CLActivityType.fitness
        //locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        form +++ SelectableSection<ListCheckRow<String>>("Where are you now?", selectionType: .singleSelection(enableDeselection: true)){ section in
            section.header?.height = {35}
            section.footer?.height = {0}
        }
        
        let continents = ["Indoor", "Outdoor"]
        for option in continents {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = "1"
                listRow.value = nil

                if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                    case 1136:
                        listRow.cell.height = {40.0}
                    case 1334:
                        listRow.cell.height = {40.0}
                    case 1920, 2208:
                        print("iPhone 6+/6S+/7+/8+")
                    case 2436:
                        print("iPhone X")
                    default:
                        listRow.cell.height = {40.0}
                    }
                }
                
                
                }.onChange{ row in
                    var count = 0
                    for (_, value) in (self.form.values()) {
                        if (value != nil){
                            count = count + 1
                        }
                    }
                    if count < 2 {
                        self.submitBTN.isEnabled = false
                        self.submitBTN.backgroundColor = UIColor.flatGray
                    }
                    else {
                        self.submitBTN.isEnabled = true
                        self.submitBTN.backgroundColor = UIColor.flatGreen
                    }
            }
        }
        
        form +++ SelectableSection<ListCheckRow<String>>("Be More Specific", selectionType: .singleSelection(enableDeselection: true)){ section in
            section.header?.height = {20}
        }
        
        let continents2 = ["Home", "Work", "Transit", "Shopping", "Restaurants", "Exercise","Other"]
        for option in continents2 {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = "1"
                listRow.value = nil
                if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                    case 1136:
                        listRow.cell.height = {40.0}
                    case 1334:
                        listRow.cell.height = {40.0}
                    case 1920, 2208:
                        print("iPhone 6+/6S+/7+/8+")
                    case 2436:
                        print("iPhone X")
                    default:
                        listRow.cell.height = {40.0}
                    }
                }
                }.onChange{ row in
                    var count = 0
                    for (_, value) in (self.form.values()) {
                        if (value != nil){
                            count = count + 1
                        }
                    }
                    if count < 2 {
                        self.submitBTN.isEnabled = false
                        self.submitBTN.backgroundColor = UIColor.flatGray
                    }
                    else {
                        self.submitBTN.isEnabled = true
                        self.submitBTN.backgroundColor = UIColor.flatGreen
                    }
                }
        }
        form.last!
        <<< TextAreaRow("notes") {
            $0.placeholder = "Notes"
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
            }.cellUpdate{ cell, row in
                cell.textView.textColor = UIColor.flatGray
        }
        
        form
        +++ Section()
        +++ Section()
        
        
        
    }
    
    
    func sendLocalNotiction() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Log up!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Time to log activities.",arguments: nil)
        content.sound = UNNotificationSound.default()

        var notificationTrigger : UNCalendarNotificationTrigger!
        var request : UNNotificationRequest!
        for index in 0...6 {
            var dateComponents = DateComponents()
            dateComponents.hour = 8 + 2 * index
            dateComponents.timeZone = .current
            
            notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            request = UNNotificationRequest(identifier: "MorningAlarm" + String(index), content: content, trigger: notificationTrigger)
            
            center.add(request)
        }
    
    }
    
    func setUpLastUpdatedTime(){
        
        let longTitleLabel = UILabel()
        longTitleLabel.numberOfLines = 2
        longTitleLabel.font = UIFont.systemFont(ofSize: 8)
        longTitleLabel.sizeToFit()
        longTitleLabel.text = "Last Logged At \n" + "Never"
        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
        var CoreDataResultsList = [NSManagedObject]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try managedObjectContext!.fetch(fetchRequest)
            let CoreDataResultsList = results as! [NSManagedObject]
            if CoreDataResultsList.last != nil{
                let date = CoreDataResultsList.last?.value(forKey: "timestamp")! as! Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                longTitleLabel.text = "Last Logged At \n" + dateFormatter.string(from: date)
            }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    
    @IBAction func showIDBTN(_ sender: Any) {
        if (PFUser.current()?.username != nil) {
            SCLAlertView().showSuccess("Your ID is", subTitle:String((PFUser.current()?.username)!.prefix(10)))
        }
        else {
            SCLAlertView().showWarning("No ID yet", subTitle: "Your ID will show here soon.")
        }
        
    }
    
    
    
    @IBAction func submit(_ sender: Any) {
        if !delegate.state.hasPrefix("Connected"){
            delegate.centralManager.scanForPeripherals(withServices: nil)
            delegate.state = "Disconnected and reconnecting"
        }
        
        if (PFUser.current()?.username == nil) {
            SCLAlertView().showWarning("No ID yet", subTitle: "You need an assigned ID to submit Log, please connect to network.")
            return
        }
        
        //Parse Server
        var log = PFObject(className:"Logs")
        log["user"] = String((PFUser.current()?.username)!.prefix(10))
        log["BTstatus"] = delegate.state
        let row: TextAreaRow? = form.rowBy(tag: "notes")
        if row?.value != nil{
            print(row?.value)
            log["notes"] = row?.value
        }
        
        if locationManager.location != nil{
            let locValue: CLLocationCoordinate2D = (locationManager.location?.coordinate)!
            log["lat"] = locValue.latitude
            log["lon"] = locValue.longitude
        }
        else{
            log["lat"] = 0
            log["lon"] = 0
        }
        
        if self.form.values()["Outdoor"]! != nil{
            for (key, value) in (self.form.values()) {
                if (value != nil) && (key != "Outdoor"){
                    log["activity"] = "Outdoor - " + key
                    print(key)
                }
            }
            
            let dateFormatterGet2 = DateFormatter()
            dateFormatterGet2.dateFormat = "MM/dd"
            let dateStr = dateFormatterGet2.string(from: Date())
            log["date"] = dateStr
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "HH:mm"
            let timeStr = dateFormatterGet.string(from: Date())
            log["time"] = timeStr
            
            log["temptime"] = delegate.time
            log["humidity"] = delegate.humidity
            log["temperature"] = delegate.temp
            log["hsi"] = delegate.hsi
            
            log.saveEventually()
            //log.saveInBackground()
            log.pinInBackground()
            SCLAlertView().showSuccess("", subTitle:"Activity Logged!\nPlease come back later.")
            
        }
            
        else if self.form.values()["Indoor"]! != nil{
            for (key, value) in (self.form.values()) {
                if (value != nil) && (key != "Indoor"){
                    log["activity"] = "Indoor - " + key
                    print(key)
                }
            }
            
            let dateFormatterGet2 = DateFormatter()
            dateFormatterGet2.dateFormat = "MM/dd"
            let dateStr = dateFormatterGet2.string(from: Date())
            log["date"] = dateStr
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "HH:mm"
            let timeStr = dateFormatterGet.string(from: Date())
            log["time"] = timeStr
            
            log["temptime"] = delegate.time
            log["humidity"] = delegate.humidity
            log["temperature"] = delegate.temp
            log["hsi"] = delegate.hsi
            
            //log.saveInBackground()
            log.saveEventually()
            log.pinInBackground()
            SCLAlertView().showSuccess("", subTitle:"Activity Logged!\nPlease come back later.")
            
        }
        self.form.allRows.forEach({ (row) in
            if row.tag == "notes"{
                (row as! TextAreaRow).value = nil
            }
            else{
                (row as! ListCheckRow<String>).value = nil // add this line
            }
            row.updateCell()
        })
        //setUpLastUpdatedTime()
        
        //Core Data
        /*
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Log", in: context)
        let newLog = NSManagedObject(entity: entity!, insertInto: context)
        
        if locationManager.location != nil{
            let locValue: CLLocationCoordinate2D = (locationManager.location?.coordinate)!
            newLog.setValue(locValue.latitude, forKeyPath: "lat")
            newLog.setValue(locValue.longitude, forKeyPath: "lon")
            print("locations = \(locValue.latitude) \(locValue.longitude)")
        }
        
        if self.form.values()["Outdoor"]! != nil{
            
            for (key, value) in (self.form.values()) {
                if (value != nil) && (key != "Outdoor"){
                    newLog.setValue(key, forKeyPath: "act2")
                    print(key)
                }
            }
            
            newLog.setValue("Outdoor", forKeyPath: "act1")
            newLog.setValue(Date(), forKeyPath: "timestamp")
            
            let dateFormatterGet2 = DateFormatter()
            dateFormatterGet2.dateFormat = "MMM d"
            let dateStr = dateFormatterGet2.string(from: Date())
            newLog.setValue(dateStr, forKeyPath: "date")
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "HH:mm"
            let timeStr = dateFormatterGet.string(from: Date())
            newLog.setValue(timeStr, forKeyPath: "time")
            
            
            do {
                try context.save()
                SCLAlertView().showSuccess("", subTitle:"Activity Logged!\nPlease come back later.")
            } catch {
                print("Failed saving")
                SCLAlertView().showError("", subTitle:"Error, Please Try Again")
            }
            
        }
        else if self.form.values()["Indoor"]! != nil{
            
            for (key, value) in (self.form.values()) {
                if (value != nil) && (key != "Indoor"){
                    newLog.setValue(key, forKeyPath: "act2")
                    print(key)
                }
            }
            
            newLog.setValue("Indoor", forKeyPath: "act1")
            newLog.setValue(Date(), forKeyPath: "timestamp")
            
            let dateFormatterGet2 = DateFormatter()
            dateFormatterGet2.dateFormat = "MMM d"
            let dateStr = dateFormatterGet2.string(from: Date())
            newLog.setValue(dateStr, forKeyPath: "date")
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "HH:mm"
            let timeStr = dateFormatterGet.string(from: Date())
            newLog.setValue(timeStr, forKeyPath: "time")
            
            do {
                try context.save()
                SCLAlertView().showSuccess("", subTitle:"Activity Logged!\nPlease come back later.")
                
            } catch {
                print("Failed saving")
                SCLAlertView().showError("", subTitle:"Error, Please Try Again")
            }
        }
        
        self.form.allRows.forEach({ (row) in

            (row as! ListCheckRow<String>).value = nil // add this line
            row.updateCell()
        })
        setUpLastUpdatedTime()
        */
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let curLoc = locationManager.location {
            let calendar = Calendar.current
            let minutes = calendar.component(.minute, from: curLoc.timestamp)
            if (minutes == delegate.nextLogTime) {
                let track = PFObject(className:"Tracks")
                track["BTstatus"] = delegate.state
                track["user"] = String((PFUser.current()?.username)!.prefix(10))
                track["lat"] = curLoc.coordinate.latitude
                track["lon"] = curLoc.coordinate.longitude
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                track["loctime"] = formatter.string(from: Date())
                track.saveInBackground()
                delegate.nextLogTime = (delegate.nextLogTime + 10) % 60
                if delegate.state.hasPrefix("Connected"){
                    track["temptime"] = formatter.string(from: delegate.time)
                    track["temp"] = delegate.temp
                    track["humidity"] = delegate.humidity
                    track["hsi"] = delegate.hsi
                    track.saveInBackground()
                }
                else{
                    delegate.centralManager.connect(delegate.connectedDrop, options: nil)
                    //scanForPeripherals(withServices: nil)
                    delegate.state = "Disconnected and reconnecting"
                }
            }
        }
    }
}


extension FirstViewController: CBCentralManagerDelegate {
    
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
            delegate.state = "Bluetooth is Powered Off"
        case .poweredOn:
            print("central.state is .poweredOn")
            delegate.centralManager.scanForPeripherals(withServices: nil)
            delegate.state = "Disconnected and reconnecting"
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name)
        if peripheral.name?.range(of:UserDefaults.standard.string(forKey: "dropid") ?? "") != nil {
            kestrelPeripheral = peripheral
            delegate.centralManager.stopScan()
            delegate.centralManager.connect(kestrelPeripheral)
            kestrelPeripheral.delegate = self
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        delegate.connectedDrop = peripheral
        delegate.state = "Connected to " + (peripheral.name)!
        kestrelPeripheral.discoverServices([CBUUID(string: "12630000-CC25-497D-9854-9B6C02C77054")])
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate.state =  "Disconnected and reconnecting"
        //delegate.centralManager.scanForPeripherals(withServices: nil)
        delegate.centralManager.connect(delegate.connectedDrop, options: nil)
    }
    
}

extension FirstViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service.uuid)
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        first = true
        for characteristic in characteristics {
            print(characteristic)
            switch characteristic.uuid {
            case tempUUID:
                peripheral.setNotifyValue(true, for: characteristic)
            case humidityUUID:
                peripheral.setNotifyValue(true, for: characteristic)
            case hsiUUID:
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        switch characteristic.uuid {
            case tempUUID:
                let data = characteristic.value?.advanced(by: 1)
                let value = data?.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
                    return ptr.pointee
                }
                delegate.temp = Double(value!)/100*1.8+32
                delegate.time = Date()
            case humidityUUID:
                let data = characteristic.value?.advanced(by: 1)
                let value = data?.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
                    return ptr.pointee
                }
                delegate.humidity = Double(value!)/100
            case hsiUUID:
                let data = characteristic.value?.advanced(by: 1)
                let value = data?.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
                    return ptr.pointee
                }
                delegate.hsi = Double(value!)/100*1.8+32
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
        if first {
            if let curLoc = locationManager.location {
                let calendar = Calendar.current
                let minutes = calendar.component(.minute, from: curLoc.timestamp)
                if (minutes == delegate.nextLogTime) {
                    let track = PFObject(className:"Tracks")
                    track["user"] = String((PFUser.current()?.username)!.prefix(10))
                    track["lat"] = curLoc.coordinate.latitude
                    track["lon"] = curLoc.coordinate.longitude
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    track["loctime"] = formatter.string(from: Date())
                    track["temptime"] = formatter.string(from: delegate.time)
                    track["temp"] = delegate.temp
                    track["humidity"] = delegate.humidity
                    track["hsi"] = delegate.hsi
                    track["BTstatus"] = delegate.state
                    track.saveInBackground()
                    delegate.nextLogTime = (delegate.nextLogTime + 10) % 60
                    first = false
                }
            }
        }
        
    }
}




