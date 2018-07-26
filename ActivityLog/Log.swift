//
//  Log.swift
//  ActivityLog
//
//  Created by Ziqi Li on 6/29/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import Foundation
import CoreLocation

class Log: NSObject {
    
    var time:String!
    var date: String!
    var activity: String!
    var lat:CLLocationDegrees!
    var lon:CLLocationDegrees!
    
    init(activity:String, time:String, date:String, lat:CLLocationDegrees, lon:CLLocationDegrees){
        self.activity = activity
        self.time = time
        self.date = date
        self.lon = lon
        self.lat = lat
    }
    
}
