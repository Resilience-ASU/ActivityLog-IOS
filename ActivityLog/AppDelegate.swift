//
//  AppDelegate.swift
//  ActivityLog
//
//  Created by Ziqi Li on 5/14/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Parse
import CoreBluetooth
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var state : String!
    var temp: Double!
    var hsi: Double!
    var humidity: Double!
    var time: Date!
    var dropid: String!
    var nextLogTime: Int!
    var window : UIWindow?
    var connectedDrop: CBPeripheral!
    var centralManager: CBCentralManager!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Notification
        state = "Disconnected"
        temp = 0
        hsi = 0
        humidity = 0
        time = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: Date())
        nextLogTime = (Int(minutes/10)*10 + 10) % 60
        
        if !isKeyPresentInUserDefaults(key: "dropid"){
            UserDefaults.standard.set("No ID Yet", forKey: "dropid")
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        
        //Parse
        let configuration = ParseClientConfiguration {
            $0.applicationId = "ziqi.actlog"
            $0.server = "https://heatmappers-act-log.herokuapp.com/parse/"
            $0.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: configuration)
        PFUser.enableAutomaticUser()
        PFUser.current()?.incrementKey("RunCount")
        PFUser.current()!["platform"] = "ios"
        PFUser.current()?.saveInBackground()
        
        return true
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}


