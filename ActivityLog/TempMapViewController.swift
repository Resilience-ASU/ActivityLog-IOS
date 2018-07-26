//
//  TempMapViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 7/25/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import MapKit
import Parse

class TempMapViewController: UIViewController,MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        addAnnotations()
    }
    
    //Get data from MongoDB
    func addAnnotations(){
        
        mapView?.delegate = self
        var locations = [CLLocationCoordinate2D]()
        var annos = [MKAnnotation]()

        let query = PFQuery(className:"Tracks")
        query.limit = 500
        query.fromLocalDatastore()
        //query.order(byDescending: "time")
        //query.whereKey("user", equalTo:PFUser.current()?.username?.prefix(10))
        //query.whereKey("user", equalTo: "5CDus8o97S")
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                let number = objects?.count as! Int
                for i in 0 ..< number {
                    let curTrack = objects?[i]
                    let timeString = curTrack?["loctime"] as! String
                    var temp = "N/A"
                    
                    if curTrack?["temp"] != nil {
                        temp = String(format: "%.1f", (curTrack?["temp"] as! Double)) + "°F"
                        print(temp)
                    }
                    if curTrack?["lon"] != nil {
                        let lon = curTrack?["lon"] as! CLLocationDegrees
                        let lat = curTrack?["lat"] as! CLLocationDegrees
                        let loc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        locations.append(loc)
                        let anno = MapPin(coordinate: loc, title: temp, subtitle: timeString)
                        annos.append(anno)
                    }

                }
                
                self.mapView.showsUserLocation = true
                self.mapView.showAnnotations(annos, animated: true)
            }
            
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
            
        }
        
        return MKOverlayRenderer()
    }

}
