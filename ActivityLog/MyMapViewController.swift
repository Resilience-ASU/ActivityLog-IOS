//
//  MyMapViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 6/2/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Parse

class MyMapViewController: UIViewController,MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var logList:[Log] = []
    
    //var managedObjectContext: NSManagedObjectContext? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //managedObjectContext = appDelegate.persistentContainer.viewContext

    }
    
    override func viewWillAppear(_ animated: Bool) {
        addAnnotations()
    }
    

    //Get data from MongoDB
    func addAnnotations(){
        
        mapView?.delegate = self
        var locations = [CLLocationCoordinate2D]()
        var annos = [MKAnnotation]()
        
        self.logList.removeAll()
        let query = PFQuery(className:"Logs")
        query.limit = 200
        query.fromLocalDatastore()
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                let number = objects?.count as! Int
                for i in 0 ..< number {
                    let curLog = objects?[i]
                    let activity = curLog?["activity"] as! String
                    let lon = curLog?["lon"] as! CLLocationDegrees
                    let lat = curLog?["lat"] as! CLLocationDegrees
                    let time =  curLog?["time"] as! String
                    let date = curLog?["date"] as! String
                    let log = Log(activity: activity, time: time, date: date, lat: lat, lon: lon)
                    var loc = CLLocationCoordinate2D(latitude: log.lat, longitude: log.lon)
                    if loc.latitude != 0{
                        locations.append(loc)
                        annos.append(MapPin(coordinate: loc, title: log.activity, subtitle: log.time + " " + log.date))
                    }
                }
                let polyline = MKPolyline(coordinates: &locations, count: locations.count)
                self.mapView?.add(polyline)
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
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    /*
    func addAnnotations() {
     
        var CoreDataResultsList = [NSManagedObject]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results =
                try managedObjectContext!.fetch(fetchRequest)
            CoreDataResultsList = results as! [NSManagedObject]
            
            //var circles = [MKCircle]()
            var locations = [CLLocationCoordinate2D]()
            var annos = [MKAnnotation]()
            for object in CoreDataResultsList
            {
                print(object.value(forKey: "lat"),object.value(forKey: "lon"))
                var loc = CLLocationCoordinate2D(latitude: object.value(forKey: "lat")! as! CLLocationDegrees, longitude: object.value(forKey: "lon")! as! CLLocationDegrees)
                if loc.latitude != 0{
                    locations.append(loc)
                
                    annos.append(MapPin(coordinate: loc, title: ((object.value(forKey: "act1")! as! String) + " " + (object.value(forKey: "act2")! as! String)), subtitle: object.value(forKey: "date")! as! String))
                }
                //circles.append(MKCircle(center: loc, radius: 100))
                
            }
            
            let polyline = MKPolyline(coordinates: &locations, count: locations.count)
            mapView?.add(polyline)
            //mapView?.addOverlays(circles)
            mapView.showsUserLocation = true
            //mapView.addAnnotations([circles as! MKAnnotation])
            mapView.showAnnotations(annos, animated: true)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    */
    
    

    @IBAction func cancelBTN(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var color: MKPinAnnotationColor = MKPinAnnotationColor.red
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}


